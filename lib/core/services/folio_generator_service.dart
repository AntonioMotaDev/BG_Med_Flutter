import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bg_med/core/services/frap_firestore_service.dart';
import 'package:bg_med/core/services/frap_local_service.dart';

class FolioGeneratorService {
  static const String _collectionName = 'preHospitalRecords';
  static const String _countersCollectionName = 'patientCounters';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FrapFirestoreService _cloudService = FrapFirestoreService();
  final FrapLocalService _localService = FrapLocalService();

  // Referencia a la colección
  CollectionReference get _collection => _firestore.collection(_collectionName);
  CollectionReference get _countersCollection =>
      _firestore.collection(_countersCollectionName);

  // Obtener el ID del usuario actual
  String? get _currentUserId => _auth.currentUser?.uid;

  // Generar folio con iniciales del paciente
  Future<String> generatePatientFolio(String patientName) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      final initials = _extractInitials(patientName);
      final year = DateTime.now().year;

      // Intentar usar contador atómico si hay conexión
      try {
        final counter = await _getPatientYearCounterAtomically(
          initials,
          year,
          userId,
        );
        return '$initials-$year-${counter.toString().padLeft(4, '0')}';
      } catch (e) {
        // Si falla, usar contador local
        final localCounter = await _getPatientYearCounterLocal(initials, year);
        return '$initials-$year-${localCounter.toString().padLeft(4, '0')}';
      }
    } catch (e) {
      // Fallback con timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final initials = _extractInitials(patientName);
      return '$initials-${DateTime.now().year}-$timestamp';
    }
  }

  // Extraer iniciales del nombre del paciente
  String _extractInitials(String fullName) {
    if (fullName.trim().isEmpty) {
      return 'SN'; // Sin Nombre
    }

    // Limpiar y normalizar el nombre
    final cleanName = fullName.trim().toUpperCase();

    // Dividir por espacios y filtrar palabras vacías
    final words =
        cleanName.split(' ').where((word) => word.isNotEmpty).toList();

    if (words.isEmpty) {
      return 'SN';
    }

    // Extraer iniciales (máximo 4 caracteres)
    String initials = '';
    for (int i = 0; i < words.length && initials.length < 4; i++) {
      final word = words[i];
      if (word.isNotEmpty) {
        initials += word[0];
      }
    }

    // Si no hay iniciales válidas
    if (initials.isEmpty) {
      return 'SN';
    }

    return initials;
  }

  // Obtener contador atómico para paciente y año
  Future<int> _getPatientYearCounterAtomically(
    String initials,
    int year,
    String userId,
  ) async {
    final counterKey = '$initials-$year';

    return await _firestore.runTransaction<int>((transaction) async {
      // Referencia al documento del contador
      final counterRef = _countersCollection.doc(counterKey);

      // Leer el documento actual
      final counterDoc = await transaction.get(counterRef);

      int currentCounter = 1;
      if (counterDoc.exists) {
        final data = counterDoc.data() as Map<String, dynamic>;
        currentCounter = (data['counter'] ?? 0) + 1;
      }

      // Actualizar el contador
      transaction.set(counterRef, {
        'counter': currentCounter,
        'lastUpdated': FieldValue.serverTimestamp(),
        'userId': userId,
        'initials': initials,
        'year': year,
      });

      return currentCounter;
    });
  }

  // Obtener contador local para paciente y año
  Future<int> _getPatientYearCounterLocal(String initials, int year) async {
    try {
      // Intentar obtener desde registros locales
      final localRecords = await _localService.getAllFrapRecords();

      // Filtrar registros del mismo paciente y año
      final patientRecords =
          localRecords.where((record) {
            final recordFolio = record.registryInfo['folio']?.toString() ?? '';
            return recordFolio.startsWith('$initials-$year-');
          }).toList();

      return patientRecords.length + 1;
    } catch (e) {
      // Si falla, usar timestamp como contador
      return DateTime.now().millisecondsSinceEpoch % 1000;
    }
  }

  // Generar folio automático (método original para compatibilidad)
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
      final querySnapshot =
          await _collection.where('userId', isEqualTo: userId).get();

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
      final querySnapshot =
          await _collection
              .where('userId', isEqualTo: userId)
              .where('registryInfo.folio', isEqualTo: folio)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        return true;
      }

      // Buscar en registros locales
      final localRecords = await _localService.getAllFrapRecords();
      return localRecords.any(
        (record) => record.registryInfo['folio'] == folio,
      );
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
      final randomSuffix = (DateTime.now().millisecondsSinceEpoch % 1000)
          .toString()
          .padLeft(3, '0');
      folio = '${folio.split('-').take(3).join('-')}-$randomSuffix';
    }

    return folio;
  }

  // Generar folio único con iniciales del paciente
  Future<String> generateUniquePatientFolio(String patientName) async {
    String folio = await generatePatientFolio(patientName);
    int attempts = 0;
    const maxAttempts = 10;

    while (await isFolioExists(folio) && attempts < maxAttempts) {
      attempts++;
      // Agregar sufijo aleatorio si hay duplicado
      final randomSuffix = (DateTime.now().millisecondsSinceEpoch % 1000)
          .toString()
          .padLeft(3, '0');
      folio = '${folio.split('-').take(3).join('-')}-$randomSuffix';
    }

    return folio;
  }

  // Obtener el siguiente folio disponible
  Future<String> getNextAvailableFolio() async {
    return await generateUniqueFolio();
  }

  // Obtener el siguiente folio disponible con iniciales del paciente
  Future<String> getNextAvailablePatientFolio(String patientName) async {
    return await generateUniquePatientFolio(patientName);
  }
}
