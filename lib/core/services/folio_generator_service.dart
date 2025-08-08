import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bg_med/core/services/frap_local_service.dart';

class FolioGeneratorService {
  static const String _collectionName = 'preHospitalRecords';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FrapLocalService _localService = FrapLocalService();

  // Referencia a la colección
  CollectionReference get _collection => _firestore.collection(_collectionName);

  // Obtener el ID del usuario actual
  String? get _currentUserId => _auth.currentUser?.uid;

  // Generar folio con iniciales del paciente y fecha/hora
  Future<String> generatePatientFolio(String patientName) async {
    try {
      final initials = _extractInitials(patientName);
      final now = DateTime.now();
      final year = now.year;

      // Formato: DDMMHHMM (día, mes, hora, minuto)
      final day = now.day.toString().padLeft(2, '0');
      final month = now.month.toString().padLeft(2, '0');
      final hour = now.hour.toString().padLeft(2, '0');
      final minute = now.minute.toString().padLeft(2, '0');

      final dateTimeCode = '$day$month$hour$minute';

      return '$initials-$year-$dateTimeCode';
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
    const maxAttempts = 5;

    while (await isFolioExists(folio) && attempts < maxAttempts) {
      attempts++;
      // Agregar segundos como sufijo si hay duplicado
      final now = DateTime.now();
      final seconds = now.second.toString().padLeft(2, '0');
      final milliseconds = (now.millisecondsSinceEpoch % 100)
          .toString()
          .padLeft(2, '0');

      // Extraer las partes del folio original
      final parts = folio.split('-');
      if (parts.length >= 3) {
        final initials = parts[0];
        final year = parts[1];
        final dateTimeCode = parts[2];

        // Agregar segundos y milisegundos como sufijo
        folio = '$initials-$year-$dateTimeCode$seconds$milliseconds';
      } else {
        // Si el formato no es el esperado, usar timestamp
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final initials = _extractInitials(patientName);
        folio = '$initials-${DateTime.now().year}-$timestamp';
      }
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
