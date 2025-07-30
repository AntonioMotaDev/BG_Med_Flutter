import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bg_med/core/services/frap_firestore_service.dart';
import 'package:bg_med/core/services/frap_local_service.dart';

class FolioGeneratorService {
  static const String _collectionName = 'preHospitalRecords';
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FrapFirestoreService _cloudService = FrapFirestoreService();
  final FrapLocalService _localService = FrapLocalService();

  // Referencia a la colección
  CollectionReference get _collection => _firestore.collection(_collectionName);

  // Obtener el ID del usuario actual
  String? get _currentUserId => _auth.currentUser?.uid;

  // Generar folio automático
  Future<String> generateAutomaticFolio() async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      // Obtener el conteo total de registros del usuario
      final totalRecords = await _getTotalRecordsCount(userId);
      
      // Generar folio con formato: FRAP-YYYY-XXXX
      final currentYear = DateTime.now().year;
      final folioNumber = (totalRecords + 1).toString().padLeft(4, '0');
      
      return 'FRAP-$currentYear-$folioNumber';
    } catch (e) {
      // En caso de error, generar folio con timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      return 'FRAP-${DateTime.now().year}-$timestamp';
    }
  }

  // Obtener el conteo total de registros del usuario
  Future<int> _getTotalRecordsCount(String userId) async {
    try {
      // Intentar obtener desde Firestore primero
      final querySnapshot = await _collection
          .where('userId', isEqualTo: userId)
          .get();
      
      return querySnapshot.docs.length;
    } catch (e) {
      // Si falla Firestore, intentar con registros locales
      try {
        final localRecords = await _localService.getAllFrapRecords();
        return localRecords.length;
      } catch (localError) {
        // Si ambos fallan, devolver 0
        print('Error obteniendo conteo de registros: $e');
        return 0;
      }
    }
  }

  // Verificar si un folio ya existe
  Future<bool> isFolioExists(String folio) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        return false;
      }

      // Buscar en Firestore
      final querySnapshot = await _collection
          .where('userId', isEqualTo: userId)
          .where('registryInfo.folio', isEqualTo: folio)
          .get();
      
      if (querySnapshot.docs.isNotEmpty) {
        return true;
      }

      // Buscar en registros locales
      final localRecords = await _localService.getAllFrapRecords();
      return localRecords.any((record) => 
          record.registryInfo['folio'] == folio);
    } catch (e) {
      print('Error verificando folio: $e');
      return false;
    }
  }

  // Generar folio único (evita duplicados)
  Future<String> generateUniqueFolio() async {
    String folio = await generateAutomaticFolio();
    int attempts = 0;
    const maxAttempts = 10;

    while (await isFolioExists(folio) && attempts < maxAttempts) {
      attempts++;
      // Agregar sufijo aleatorio si hay duplicado
      final randomSuffix = (DateTime.now().millisecondsSinceEpoch % 1000).toString().padLeft(3, '0');
      folio = '${folio.split('-').take(3).join('-')}-$randomSuffix';
    }

    return folio;
  }

  // Obtener el siguiente folio disponible
  Future<String> getNextAvailableFolio() async {
    return await generateUniqueFolio();
  }
} 