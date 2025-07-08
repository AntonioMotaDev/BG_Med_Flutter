import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bg_med/core/services/frap_firestore_service.dart';
import 'package:bg_med/core/models/frap_firestore.dart';
import 'package:bg_med/features/frap/presentation/providers/frap_data_provider.dart';

class FrapDebugHelper {
  static final FrapFirestoreService _service = FrapFirestoreService();
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Debug: Verificar el estado de autenticación
  static Future<void> checkAuthStatus() async {
    print('=== DEBUG: Estado de Autenticación ===');
    
    final user = _auth.currentUser;
    if (user == null) {
      print('❌ Usuario NO autenticado');
      return;
    }
    
    print('✅ Usuario autenticado:');
    print('  - UID: ${user.uid}');
    print('  - Email: ${user.email}');
    print('  - Email verificado: ${user.emailVerified}');
    print('  - Nombre: ${user.displayName ?? 'Sin nombre'}');
  }

  /// Debug: Verificar conexión a Firestore
  static Future<void> checkFirestoreConnection() async {
    print('\n=== DEBUG: Conexión a Firestore ===');
    
    try {
      // Intentar hacer una consulta simple
      final testDoc = await _firestore.collection('test').limit(1).get();
      print('✅ Conexión a Firestore exitosa');
      print('  - Documentos encontrados: ${testDoc.docs.length}');
    } catch (e) {
      print('❌ Error de conexión a Firestore: $e');
    }
  }

  /// Debug: Verificar la colección preHospitalRecords
  static Future<void> checkPreHospitalRecordsCollection() async {
    print('\n=== DEBUG: Colección preHospitalRecords ===');
    
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('❌ Usuario no autenticado');
        return;
      }

      // Verificar todos los documentos en la colección
      final allDocs = await _firestore.collection('preHospitalRecords').get();
      print('📊 Total de documentos en la colección: ${allDocs.docs.length}');
      
      if (allDocs.docs.isNotEmpty) {
        print('📋 Primeros 5 documentos:');
        for (int i = 0; i < allDocs.docs.length && i < 5; i++) {
          final doc = allDocs.docs[i];
          final data = doc.data();
          print('  ${i + 1}. ID: ${doc.id}');
          print('     - userId: ${data['userId'] ?? 'N/A'}');
          print('     - createdAt: ${data['createdAt'] ?? 'N/A'}');
          print('     - patientInfo: ${data['patientInfo'] ?? 'N/A'}');
        }
      }

      // Verificar documentos del usuario actual
      final userDocs = await _firestore
          .collection('preHospitalRecords')
          .where('userId', isEqualTo: user.uid)
          .get();
      
      print('\n👤 Documentos del usuario actual (${user.uid}): ${userDocs.docs.length}');
      
      if (userDocs.docs.isNotEmpty) {
        print('📋 Registros del usuario:');
        for (int i = 0; i < userDocs.docs.length; i++) {
          final doc = userDocs.docs[i];
          final data = doc.data();
          final patientInfo = data['patientInfo'] as Map<String, dynamic>? ?? {};
          final patientName = '${patientInfo['firstName'] ?? ''} ${patientInfo['paternalLastName'] ?? ''} ${patientInfo['maternalLastName'] ?? ''}'.trim();
          
          print('  ${i + 1}. ID: ${doc.id}');
          print('     - Paciente: ${patientName.isEmpty ? 'Sin nombre' : patientName}');
          print('     - Edad: ${patientInfo['age'] ?? 'N/A'}');
          print('     - Creado: ${data['createdAt'] ?? 'N/A'}');
        }
      }
      
    } catch (e) {
      print('❌ Error al verificar la colección: $e');
    }
  }

  /// Debug: Crear un registro de prueba
  static Future<void> createTestRecord() async {
    print('\n=== DEBUG: Crear Registro de Prueba ===');
    
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('❌ Usuario no autenticado');
        return;
      }

      final testFrapData = FrapData();
      testFrapData.updateSectionData('patient_info', {
        'firstName': 'Juan',
        'paternalLastName': 'Pérez',
        'maternalLastName': 'González',
        'age': 35,
        'sex': 'Masculino',
        'phone': '555-1234',
        'street': 'Calle Test',
        'exteriorNumber': '123',
        'neighborhood': 'Colonia Test',
        'city': 'Ciudad Test',
        'insurance': 'IMSS',
        'currentCondition': 'Dolor de cabeza',
      });

      testFrapData.updateSectionData('service_info', {
        'serviceType': 'Emergencia',
        'ambulanceNumber': 'AMB-001',
        'crew': 'Equipo A',
        'date': DateTime.now().toIso8601String(),
      });

      final recordId = await _service.createFrapRecord(frapData: testFrapData);
      
      if (recordId != null) {
        print('✅ Registro de prueba creado exitosamente');
        print('  - ID: $recordId');
        print('  - Usuario: ${user.uid}');
      } else {
        print('❌ Error: No se pudo crear el registro');
      }
      
    } catch (e) {
      print('❌ Error al crear registro de prueba: $e');
    }
  }

  /// Debug: Obtener todos los registros
  static Future<void> getAllRecords() async {
    print('\n=== DEBUG: Obtener Todos los Registros ===');
    
    try {
      final records = await _service.getAllFrapRecords();
      print('📊 Total de registros obtenidos: ${records.length}');
      
      if (records.isNotEmpty) {
        print('📋 Registros:');
        for (int i = 0; i < records.length; i++) {
          final record = records[i];
          print('  ${i + 1}. ${record.patientName} (${record.patientAge} años)');
          print('     - ID: ${record.id}');
          print('     - Completitud: ${record.completionPercentage.toStringAsFixed(1)}%');
          print('     - Creado: ${record.createdAt}');
        }
      }
      
    } catch (e) {
      print('❌ Error al obtener registros: $e');
    }
  }

  /// Debug: Probar stream de registros
  static Future<void> testRecordsStream() async {
    print('\n=== DEBUG: Probar Stream de Registros ===');
    
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('❌ Usuario no autenticado');
        return;
      }

      print('🔄 Iniciando stream de registros...');
      
      final stream = _service.getFrapRecordsStream();
      
      // Escuchar el stream por 5 segundos
      final subscription = stream.listen(
        (records) {
          print('📡 Stream recibió ${records.length} registros');
          for (int i = 0; i < records.length && i < 3; i++) {
            final record = records[i];
            print('  ${i + 1}. ${record.patientName} (${record.patientAge} años)');
          }
        },
        onError: (error) {
          print('❌ Error en el stream: $error');
        },
      );
      
      // Esperar 5 segundos y cancelar
      await Future.delayed(const Duration(seconds: 5));
      await subscription.cancel();
      print('🔄 Stream cancelado');
      
    } catch (e) {
      print('❌ Error al probar stream: $e');
    }
  }

  /// Debug: Verificar reglas de seguridad de Firestore
  static Future<void> checkFirestoreSecurityRules() async {
    print('\n=== DEBUG: Verificar Reglas de Seguridad ===');
    
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('❌ Usuario no autenticado');
        return;
      }

      // Intentar leer sin filtro de usuario (debería fallar si las reglas están bien configuradas)
      try {
        final allDocs = await _firestore.collection('preHospitalRecords').limit(1).get();
        print('⚠️ ADVERTENCIA: Se pudo leer la colección sin filtro de usuario');
        print('  - Esto podría indicar reglas de seguridad permisivas');
      } catch (e) {
        print('✅ Reglas de seguridad funcionando: $e');
      }

      // Intentar leer con filtro de usuario (debería funcionar)
      try {
        final userDocs = await _firestore
            .collection('preHospitalRecords')
            .where('userId', isEqualTo: user.uid)
            .limit(1)
            .get();
        print('✅ Lectura con filtro de usuario exitosa');
        print('  - Documentos encontrados: ${userDocs.docs.length}');
      } catch (e) {
        print('❌ Error al leer con filtro de usuario: $e');
      }
      
    } catch (e) {
      print('❌ Error al verificar reglas de seguridad: $e');
    }
  }

  /// Debug: Ejecutar todas las pruebas
  static Future<void> runAllDebugTests() async {
    print('🔍 INICIANDO DIAGNÓSTICO COMPLETO DE FRAP FIRESTORE');
    print('=' * 60);
    
    await checkAuthStatus();
    await checkFirestoreConnection();
    await checkPreHospitalRecordsCollection();
    await checkFirestoreSecurityRules();
    await getAllRecords();
    await testRecordsStream();
    
    print('\n' + '=' * 60);
    print('🏁 DIAGNÓSTICO COMPLETO TERMINADO');
  }

  /// Debug: Crear múltiples registros de prueba
  static Future<void> createMultipleTestRecords() async {
    print('\n=== DEBUG: Crear Múltiples Registros de Prueba ===');
    
    final testPatients = [
      {'firstName': 'María', 'paternalLastName': 'García', 'maternalLastName': 'López', 'age': 28, 'sex': 'Femenino'},
      {'firstName': 'Carlos', 'paternalLastName': 'Rodríguez', 'maternalLastName': 'Martínez', 'age': 45, 'sex': 'Masculino'},
      {'firstName': 'Ana', 'paternalLastName': 'Hernández', 'maternalLastName': 'Jiménez', 'age': 32, 'sex': 'Femenino'},
      {'firstName': 'Luis', 'paternalLastName': 'González', 'maternalLastName': 'Ruiz', 'age': 55, 'sex': 'Masculino'},
    ];

    for (int i = 0; i < testPatients.length; i++) {
      try {
        final patient = testPatients[i];
        final testFrapData = FrapData();
        
        testFrapData.updateSectionData('patient_info', {
          'firstName': patient['firstName'],
          'paternalLastName': patient['paternalLastName'],
          'maternalLastName': patient['maternalLastName'],
          'age': patient['age'],
          'sex': patient['sex'],
          'phone': '555-${1000 + i}',
          'street': 'Calle ${i + 1}',
          'exteriorNumber': '${100 + i}',
          'neighborhood': 'Colonia ${i + 1}',
          'city': 'Ciudad Test',
          'insurance': 'IMSS',
          'currentCondition': 'Condición de prueba ${i + 1}',
        });

        testFrapData.updateSectionData('service_info', {
          'serviceType': 'Emergencia',
          'ambulanceNumber': 'AMB-00${i + 1}',
          'crew': 'Equipo ${String.fromCharCode(65 + i)}',
          'date': DateTime.now().subtract(Duration(days: i)).toIso8601String(),
        });

        final recordId = await _service.createFrapRecord(frapData: testFrapData);
        
        if (recordId != null) {
          print('✅ Registro ${i + 1} creado: ${patient['firstName']} ${patient['paternalLastName']}');
        } else {
          print('❌ Error al crear registro ${i + 1}');
        }
        
        // Esperar un poco entre creaciones
        await Future.delayed(const Duration(milliseconds: 500));
        
      } catch (e) {
        print('❌ Error al crear registro ${i + 1}: $e');
      }
    }
  }

  /// Debug: Limpiar registros de prueba
  static Future<void> cleanupTestRecords() async {
    print('\n=== DEBUG: Limpiar Registros de Prueba ===');
    
    try {
      final records = await _service.getAllFrapRecords();
      int deleted = 0;
      
      for (final record in records) {
        // Eliminar registros que contengan "Test" o sean de prueba
        if (record.patientName.contains('Test') || 
            record.patientName.contains('María García') ||
            record.patientName.contains('Carlos Rodríguez') ||
            record.patientName.contains('Ana Hernández') ||
            record.patientName.contains('Luis González') ||
            record.patientName.contains('Juan Pérez')) {
          
          await _service.deleteFrapRecord(record.id!);
          deleted++;
          print('🗑️ Eliminado: ${record.patientName}');
        }
      }
      
      print('✅ Se eliminaron $deleted registros de prueba');
      
    } catch (e) {
      print('❌ Error al limpiar registros: $e');
    }
  }
} 