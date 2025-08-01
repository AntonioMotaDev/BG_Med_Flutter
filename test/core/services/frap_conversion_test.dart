import 'package:flutter_test/flutter_test.dart';
import 'package:bg_med/core/models/frap.dart';
import 'package:bg_med/core/models/frap_firestore.dart';
import 'package:bg_med/core/models/patient.dart';
import 'package:bg_med/core/models/clinical_history.dart';
import 'package:bg_med/core/models/physical_exam.dart';
import 'package:bg_med/core/models/insumo.dart';
import 'package:bg_med/core/models/personal_medico.dart';
import 'package:bg_med/core/models/escalas_obstetricas.dart';
import 'package:bg_med/core/models/frap_transition_model.dart';
import 'package:bg_med/core/services/frap_data_validator.dart';
import 'package:bg_med/core/services/frap_conversion_mapping.dart';
import 'package:bg_med/features/frap/presentation/adapters/frap_form_adapters.dart';

void main() {
  group('FRAP Conversion Tests', () {
    late Frap sampleLocalRecord;
    late FrapFirestore sampleCloudRecord;

    setUp(() {
      // Crear registro local de ejemplo
      sampleLocalRecord = Frap(
        id: 'test_local_001',
        patient: const Patient(
          name: 'Juan Pérez García',
          age: 35,
          sex: 'Masculino',
          address: 'Calle Ejemplo #123',
          firstName: 'Juan',
          paternalLastName: 'Pérez',
          maternalLastName: 'García',
          phone: '555-0123',
          street: 'Calle Ejemplo',
          exteriorNumber: '123',
          neighborhood: 'Centro',
          city: 'Ciudad de México',
          insurance: 'IMSS',
          gender: 'Masculino',
          entreCalles: 'Entre Reforma y Juárez',
          tipoEntrega: 'Hospital',
        ),
        clinicalHistory: const ClinicalHistory(
          allergies: 'Penicilina',
          medications: 'Paracetamol 500mg',
          previousIllnesses: 'Diabetes tipo 2',
        ),
        physicalExam: const PhysicalExam(
          vitalSigns: 'Estables',
          head: 'Normal',
          neck: 'Sin alteraciones',
          thorax: 'Murmullo vesicular conservado',
          abdomen: 'Blando, depresible',
          extremities: 'Sin edema',
          bloodPressure: '120/80',
          heartRate: '72',
          respiratoryRate: '16',
          temperature: '36.5',
          oxygenSaturation: '98',
          neurological: 'Glasgow 15/15',
        ),
        createdAt: DateTime(2024, 1, 15, 10, 30),
        updatedAt: DateTime(2024, 1, 15, 10, 35),
        serviceInfo: {
          'horaLlamada': '10:00',
          'horaArribo': '10:15',
          'tipoServicio': 'Urgencia',
        },
        management: {
          'procedimientos': 'Toma de signos vitales',
          'observaciones': 'Paciente estable',
        },
        medications: {
          'medicationsList': [
            {
              'medicamento': 'Paracetamol',
              'dosis': '500mg',
              'viaAdministracion': 'Oral',
              'hora': '10:30',
              'medicoIndico': 'Dr. García',
            }
          ],
        },
        consentimientoServicio: 'signature_data_base64',
        insumos: const [
          Insumo(cantidad: 2, articulo: 'Gasas estériles'),
          Insumo(cantidad: 1, articulo: 'Termómetro digital'),
        ],
        personalMedico: const [
          PersonalMedico(
            nombre: 'Dr. Juan García',
            especialidad: 'Medicina de Emergencias',
            cedula: '12345678',
          ),
        ],
        escalasObstetricas: const EscalasObstetricas(
          silvermanAnderson: {'minuto': 2, '5min': 1},
          apgar: {'minuto': 8, '5min': 9},
          frecuenciaCardiacaFetal: 140,
          contracciones: 'Irregulares, 3 en 10 minutos',
        ),
        isSynced: false,
      );

      // Crear registro de nube de ejemplo
      sampleCloudRecord = FrapFirestore(
        id: 'test_cloud_001',
        userId: 'user_123',
        createdAt: DateTime(2024, 1, 15, 10, 30),
        updatedAt: DateTime(2024, 1, 15, 10, 35),
        serviceInfo: {
          'horaLlamada': '10:00',
          'horaArribo': '10:15',
          'tipoServicio': 'Urgencia',
          'consentimientoSignature': 'cloud_signature_data',
        },
        patientInfo: {
          'firstName': 'María',
          'paternalLastName': 'López',
          'maternalLastName': 'Hernández',
          'age': 28,
          'sex': 'Femenino',
          'phone': '555-9876',
          'street': 'Av. Insurgentes',
          'exteriorNumber': '456',
          'city': 'Guadalajara',
          'insurance': 'ISSSTE',
        },
        management: {
          'procedimientos': 'Evaluación inicial',
          'insumos': [
            {'cantidad': 3, 'articulo': 'Vendas elásticas'},
            {'cantidad': 1, 'articulo': 'Oxímetro'},
          ],
          'personalMedico': [
            {
              'nombre': 'Dra. Ana Martínez',
              'especialidad': 'Paramédico',
              'cedula': '87654321',
            },
          ],
        },
        clinicalHistory: {
          'allergies': 'Ninguna conocida',
          'medications': 'Aspirina 100mg',
          'previousIllnesses': 'Hipertensión',
        },
        physicalExam: {
          'vitalSigns': 'Estables',
          'bloodPressure': '130/85',
          'heartRate': '80',
          'temperature': '37.0',
        },
        gynecoObstetric: {
          'escalasObstetricas': {
            'apgar': {'minuto': 7, '5min': 8},
            'frecuenciaCardiacaFetal': 150,
          },
        },
      );
    });

    group('Data Validation Tests', () {
      test('should validate patient data correctly', () {
        final patientData = {
          'firstName': 'Juan',
          'age': 35,
          'sex': 'Masculino',
          'phone': '555-0123',
        };

        final result = FrapDataValidator.validatePatientData(patientData);

        expect(result.isValid, isTrue);
        expect(result.errors, isEmpty);
        expect(result.cleanedData!['firstName'], equals('Juan'));
        expect(result.cleanedData!['age'], equals(35));
      });

      test('should detect invalid patient data', () {
        final patientData = {
          'firstName': '', // Vacío
          'age': -5, // Inválido
          'phone': '123', // Muy corto
        };

        final result = FrapDataValidator.validatePatientData(patientData);

        expect(result.isValid, isFalse);
        expect(result.errors, isNotEmpty);
        expect(result.warnings, isNotEmpty);
      });

      test('should validate insumos data correctly', () {
        final insumosData = [
          {'cantidad': 2, 'articulo': 'Gasas'},
          {'cantidad': 1, 'articulo': 'Termómetro'},
        ];

        final result = FrapDataValidator.validateInsumosData(insumosData);

        expect(result.isValid, isTrue);
        expect(result.errors, isEmpty);
        expect(result.cleanedData!['insumos'], hasLength(2));
      });

      test('should validate personal medico data correctly', () {
        final personalData = [
          {
            'nombre': 'Dr. García',
            'especialidad': 'Emergencias',
            'cedula': '12345678',
          },
        ];

        final result = FrapDataValidator.validatePersonalMedicoData(personalData);

        expect(result.isValid, isTrue);
        expect(result.errors, isEmpty);
        expect(result.cleanedData!['personalMedico'], hasLength(1));
      });
    });

    group('Conversion Mapping Tests', () {
      test('should identify local-only fields correctly', () {
        expect(FrapConversionMapping.localOnlyFields, contains('consentimientoServicio'));
        expect(FrapConversionMapping.localOnlyFields, contains('insumos'));
        expect(FrapConversionMapping.localOnlyFields, contains('personalMedico'));
        expect(FrapConversionMapping.localOnlyFields, contains('escalasObstetricas'));
        expect(FrapConversionMapping.localOnlyFields, contains('isSynced'));
      });

      test('should identify cloud-only fields correctly', () {
        expect(FrapConversionMapping.cloudOnlyFields, contains('userId'));
      });

      test('should validate field mapping correctly', () {
        expect(FrapConversionMapping.isLocalField('consentimientoServicio'), isTrue);
        expect(FrapConversionMapping.isLocalField('userId'), isFalse);
        expect(FrapConversionMapping.isCloudField('userId'), isTrue);
        expect(FrapConversionMapping.isCloudField('consentimientoServicio'), isFalse);
      });

      test('should generate difference report', () {
        final report = FrapConversionMapping.generateDifferenceReport();

        expect(report['localOnlyFields'], isNotEmpty);
        expect(report['cloudOnlyFields'], isNotEmpty);
        expect(report['commonSections'], isNotEmpty);
        expect(report['totalLocalFields'], greaterThan(0));
        expect(report['totalCloudFields'], greaterThan(0));
      });
    });

    group('Form Adapters Tests', () {
      test('should adapt insumos from local model', () {
        final result = FrapFormAdapters.adaptInsumos(sampleLocalRecord.insumos, isFromCloud: false);

        expect(result['totalInsumos'], equals(2));
        expect(result['totalCantidad'], equals(3));
        expect(result['insumosList'], hasLength(2));
        expect(result['insumos'], contains('Gasas estériles'));
      });

      test('should adapt insumos from cloud model', () {
        final result = FrapFormAdapters.adaptInsumos(sampleCloudRecord.management, isFromCloud: true);

        expect(result['totalInsumos'], equals(2));
        expect(result['totalCantidad'], equals(4));
        expect(result['insumosList'], hasLength(2));
        expect(result['insumos'], contains('Vendas elásticas'));
      });

      test('should adapt personal medico from local model', () {
        final result = FrapFormAdapters.adaptPersonalMedico(sampleLocalRecord.personalMedico, isFromCloud: false);

        expect(result['totalPersonal'], equals(1));
        expect(result['personalMedicoList'], hasLength(1));
        expect(result['personalMedico'], contains('Dr. Juan García'));
      });

      test('should adapt escalas obstetricas from local model', () {
        final result = FrapFormAdapters.adaptEscalasObstetricas(sampleLocalRecord.escalasObstetricas, isFromCloud: false);

        expect(result['hasEscalas'], isTrue);
        expect(result['frecuenciaCardiacaFetal'], equals(140));
        expect(result['apgar']['minuto'], equals(8));
      });

      test('should adapt complete FRAP record from local', () {
        final result = FrapFormAdapters.adaptFrapRecord(sampleLocalRecord);

        expect(result['isLocal'], isTrue);
        expect(result['isCloud'], isFalse);
        expect(result['isSynced'], isFalse);
        expect(result['insumos']['totalInsumos'], equals(2));
        expect(result['personalMedico']['totalPersonal'], equals(1));
        expect(result['escalasObstetricas']['hasEscalas'], isTrue);
      });

      test('should adapt complete FRAP record from cloud', () {
        final result = FrapFormAdapters.adaptFrapRecord(sampleCloudRecord);

        expect(result['isLocal'], isFalse);
        expect(result['isCloud'], isTrue);
        expect(result['isSynced'], isTrue);
        expect(result['userId'], equals('user_123'));
        expect(result['insumos']['totalInsumos'], equals(2));
      });

      test('should detect data origin correctly', () {
        expect(FrapFormAdapters.detectDataOrigin(sampleLocalRecord), equals(DataOrigin.local));
        expect(FrapFormAdapters.detectDataOrigin(sampleCloudRecord), equals(DataOrigin.cloud));

        final hybridModel = FrapTransitionModel.fromLocal(sampleLocalRecord);
        expect(FrapFormAdapters.detectDataOrigin(hybridModel), equals(DataOrigin.hybrid));
      });

      test('should identify missing fields for conversion', () {
        final cloudData = FrapFormAdapters.adaptFrapRecord(sampleCloudRecord);
        final missingForLocal = FrapFormAdapters.getMissingFields(cloudData, DataOrigin.local);

        // El campo userId no debería estar en la lista de faltantes para local
        expect(missingForLocal, isNot(contains('userId')));

        final localData = FrapFormAdapters.adaptFrapRecord(sampleLocalRecord);
        final missingForCloud = FrapFormAdapters.getMissingFields(localData, DataOrigin.cloud);

        // El campo userId debería estar en la lista de faltantes para nube
        expect(missingForCloud, contains('userId'));
      });
    });

    group('Transition Model Tests', () {
      test('should create transition model from local', () {
        final transition = FrapTransitionModel.fromLocal(sampleLocalRecord);

        expect(transition.localModel, isNotNull);
        expect(transition.cloudModel, isNull);
        expect(transition.needsMigration, isFalse);
        expect(transition.migrationStatus, equals(MigrationStatus.completed));
      });

      test('should create transition model from cloud', () {
        final transition = FrapTransitionModel.fromCloud(sampleCloudRecord);

        expect(transition.localModel, isNull);
        expect(transition.cloudModel, isNotNull);
        expect(transition.needsMigration, isTrue);
        expect(transition.migrationStatus, equals(MigrationStatus.pending));
      });

      test('should migrate cloud to local standard', () {
        final transition = FrapTransitionModel.fromCloud(sampleCloudRecord);
        final localRecord = transition.migrateToLocalStandard();

        expect(localRecord.id, equals(sampleCloudRecord.id));
        expect(localRecord.patient.firstName, equals('María'));
        expect(localRecord.patient.paternalLastName, equals('López'));
        expect(localRecord.insumos, hasLength(2));
        expect(localRecord.personalMedico, hasLength(1));
        expect(localRecord.isSynced, isTrue);
      });

      test('should migrate local to cloud standard', () {
        final transition = FrapTransitionModel.fromLocal(sampleLocalRecord);
        final cloudRecord = transition.migrateToCloudStandard();

        expect(cloudRecord.id, equals(sampleLocalRecord.id));
        expect(cloudRecord.patientInfo['firstName'], equals('Juan'));
        expect(cloudRecord.management['insumos'], hasLength(2));
        expect(cloudRecord.management['personalMedico'], hasLength(1));
      });

      test('should detect equivalent models', () {
        // Crear modelos equivalentes
        final localCopy = sampleLocalRecord.copyWith(
          patient: sampleLocalRecord.patient.copyWith(
            firstName: 'Juan',
            paternalLastName: 'Pérez',
          ),
        );

        final cloudCopy = sampleCloudRecord.copyWith(
          patientInfo: {
            ...sampleCloudRecord.patientInfo,
            'firstName': 'Juan',
            'paternalLastName': 'Pérez',
          },
        );

        final transition = FrapTransitionModel.hybrid(
          local: localCopy,
          cloud: cloudCopy,
          lastSync: DateTime.now(),
        );

        expect(transition.needsMigration, isFalse);
        expect(transition.migrationStatus, equals(MigrationStatus.completed));
      });
    });

    group('Integration Tests', () {
      test('should perform complete round-trip conversion', () {
        // Local -> Cloud -> Local
        final transition1 = FrapTransitionModel.fromLocal(sampleLocalRecord);
        final cloudRecord = transition1.migrateToCloudStandard();
        
        final transition2 = FrapTransitionModel.fromCloud(cloudRecord);
        final localRecord = transition2.migrateToLocalStandard();

        // Verificar que los datos críticos se preservan
        expect(localRecord.patient.firstName, equals(sampleLocalRecord.patient.firstName));
        expect(localRecord.patient.age, equals(sampleLocalRecord.patient.age));
        expect(localRecord.createdAt, equals(sampleLocalRecord.createdAt));
        expect(localRecord.insumos.length, equals(sampleLocalRecord.insumos.length));
        expect(localRecord.personalMedico.length, equals(sampleLocalRecord.personalMedico.length));
      });

      test('should handle missing data gracefully', () {
        // Crear registro de nube con datos mínimos
        final minimalCloud = FrapFirestore(
          userId: 'test_user',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          patientInfo: {
            'firstName': 'Test',
            'age': 30,
            'sex': 'Masculino',
          },
        );

        final transition = FrapTransitionModel.fromCloud(minimalCloud);
        final localRecord = transition.migrateToLocalStandard();

        expect(localRecord.patient.firstName, equals('Test'));
        expect(localRecord.insumos, isEmpty);
        expect(localRecord.personalMedico, isEmpty);
        expect(localRecord.escalasObstetricas, isNull);
        expect(localRecord.consentimientoServicio, isEmpty);
      });

      test('should validate adapted data consistency', () {
        final adaptedLocal = FrapFormAdapters.adaptFrapRecord(sampleLocalRecord);
        final adaptedCloud = FrapFormAdapters.adaptFrapRecord(sampleCloudRecord);

        // Verificar estructura consistente
        expect(adaptedLocal.keys, contains('patientInfo'));
        expect(adaptedLocal.keys, contains('insumos'));
        expect(adaptedLocal.keys, contains('personalMedico'));
        expect(adaptedLocal.keys, contains('escalasObstetricas'));

        expect(adaptedCloud.keys, contains('patientInfo'));
        expect(adaptedCloud.keys, contains('insumos'));
        expect(adaptedCloud.keys, contains('personalMedico'));
        expect(adaptedCloud.keys, contains('escalasObstetricas'));

        // Verificar tipos de datos
        expect(adaptedLocal['insumos'], isA<Map<String, dynamic>>());
        expect(adaptedCloud['insumos'], isA<Map<String, dynamic>>());
      });
    });
  });
} 