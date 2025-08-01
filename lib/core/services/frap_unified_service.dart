import 'dart:async';
import 'package:bg_med/core/services/frap_local_service.dart';
import 'package:bg_med/core/services/frap_firestore_service.dart';
import 'package:bg_med/core/models/frap.dart';
import 'package:bg_med/core/models/frap_firestore.dart';
import 'package:bg_med/core/models/patient.dart';
import 'package:bg_med/core/models/clinical_history.dart';
import 'package:bg_med/core/models/physical_exam.dart';
import 'package:bg_med/core/models/insumo.dart';
import 'package:bg_med/core/models/personal_medico.dart';
import 'package:bg_med/core/models/escalas_obstetricas.dart';
import 'package:bg_med/core/services/frap_data_validator.dart';
import 'package:bg_med/core/services/frap_conversion_logger.dart';
import 'package:bg_med/core/services/frap_migration_service.dart';
import 'package:bg_med/features/frap/presentation/providers/frap_data_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class FrapUnifiedService {
  final FrapLocalService _localService;
  final FrapFirestoreService _cloudService;
  final Connectivity _connectivity;
  late final FrapMigrationService _migrationService;

  FrapUnifiedService({
    required FrapLocalService localService,
    required FrapFirestoreService cloudService,
    Connectivity? connectivity,
  }) : _localService = localService,
       _cloudService = cloudService,
       _connectivity = connectivity ?? Connectivity() {
    _migrationService = FrapMigrationService(
      localService: _localService,
      cloudService: _cloudService,
    );
  }

  /// Obtener el servicio de migración
  FrapMigrationService get migrationService => _migrationService;

  // Verificar conectividad a internet
  Future<bool> hasInternetConnection() async {
    try {
      final connectivityResults = await _connectivity.checkConnectivity();
      return !connectivityResults.contains(ConnectivityResult.none);
    } catch (e) {
      return false;
    }
  }

  // Guardar registro unificado (local + nube si hay conexión)
  Future<UnifiedSaveResult> saveFrapRecord(FrapData frapData) async {
    final result = UnifiedSaveResult();
    
    try {
      FrapConversionLogger.logConversionStart('save_unified', 'new_record');
      
      // Siempre guardar localmente primero
      final localRecordId = await _localService.createFrapRecord(frapData: frapData);
      
      if (localRecordId != null) {
        result.localRecordId = localRecordId;
        result.savedLocally = true;
        
        // Intentar guardar en la nube si hay conexión
        final hasInternet = await hasInternetConnection();
        if (hasInternet) {
          try {
            final cloudRecordId = await _cloudService.createFrapRecord(frapData: frapData);
            if (cloudRecordId != null) {
              result.cloudRecordId = cloudRecordId;
              result.savedToCloud = true;
              
              // Marcar como sincronizado en local (si el método existe)
              try {
                await _localService.markAsSynced(localRecordId);
              } catch (e) {
                // Si el método no existe, ignorar el error
                print('Warning: markAsSynced method not available');
              }
            }
          } catch (e) {
            result.cloudError = e.toString();
            // El registro se mantiene local y se sincronizará después
          }
        } else {
          result.message = 'Guardado localmente. Se sincronizará cuando haya conexión.';
        }
        
        result.success = true;
        result.message = result.message.isNotEmpty 
            ? result.message 
            : 'Registro guardado exitosamente';
            
        FrapConversionLogger.logConversionSuccess('save_unified', localRecordId, {
          'savedLocally': result.savedLocally,
          'savedToCloud': result.savedToCloud,
          'hasInternet': hasInternet,
        });
      } else {
        throw Exception('No se pudo guardar localmente');
      }
    } catch (e) {
      result.success = false;
      result.message = 'Error al guardar: $e';
      result.errors.add(e.toString());
      
      FrapConversionLogger.logConversionError('save_unified', 'new_record', e.toString(), null);
    }

    return result;
  }

  // Obtener todos los registros (local + nube)
  Future<List<UnifiedFrapRecord>> getAllRecords() async {
    final List<UnifiedFrapRecord> unifiedRecords = [];
    
    try {
      FrapConversionLogger.logConversionStart('get_all_records', 'batch');
      
      // Obtener registros locales
      final localRecords = await _localService.getAllFrapRecords();
      
      // Obtener registros de la nube si hay conexión
      List<FrapFirestore> cloudRecords = [];
      if (await hasInternetConnection()) {
        try {
          cloudRecords = await _cloudService.getAllFrapRecords();
        } catch (e) {
          print('Error obteniendo registros de la nube: $e');
        }
      }

      // Procesar registros locales
      for (final localRecord in localRecords) {
        unifiedRecords.add(UnifiedFrapRecord.fromLocal(localRecord));
      }

      // Procesar registros de la nube
      for (final cloudRecord in cloudRecords) {
        // Verificar si ya existe en local
        final existingLocal = localRecords.where((r) => 
          _areRecordsEquivalent(r, cloudRecord)
        ).firstOrNull;

        if (existingLocal == null) {
          // Es un registro solo de la nube
          unifiedRecords.add(UnifiedFrapRecord.fromCloud(cloudRecord));
        } else {
          // Actualizar el registro local con datos de la nube si es más reciente
          if (cloudRecord.updatedAt.isAfter(existingLocal.updatedAt)) {
            try {
              final frapData = _localService.convertFrapToFrapData(existingLocal);
              await _localService.updateFrapRecord(
                frapId: existingLocal.id,
                frapData: frapData,
              );
              // Recargar el registro actualizado
              final updatedLocal = await _localService.getFrapRecord(existingLocal.id);
              if (updatedLocal != null) {
                final index = unifiedRecords.indexWhere((r) => r.localRecord?.id == existingLocal.id);
                if (index != -1) {
                  unifiedRecords[index] = UnifiedFrapRecord.fromLocal(updatedLocal);
                }
              }
            } catch (e) {
              print('Error actualizando registro local: $e');
            }
          }
        }
      }

      // Ordenar por fecha de creación (más recientes primero)
      unifiedRecords.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      FrapConversionLogger.logConversionSuccess('get_all_records', 'batch', {
        'localRecords': localRecords.length,
        'cloudRecords': cloudRecords.length,
        'unifiedRecords': unifiedRecords.length,
      });
      
    } catch (e) {
      print('Error obteniendo registros unificados: $e');
      FrapConversionLogger.logConversionError('get_all_records', 'batch', e.toString(), null);
    }

    return unifiedRecords;
  }

  // Verificar si dos registros son equivalentes
  bool _areRecordsEquivalent(Frap local, FrapFirestore cloud) {
    // Comparar por datos del paciente y fecha de creación
    final localPatientName = local.patient.fullName.toLowerCase();
    final cloudPatientName = cloud.patientName.toLowerCase();
    
    return localPatientName == cloudPatientName &&
           local.createdAt.difference(cloud.createdAt).abs().inMinutes < 5;
  }

  // Convertir registro de la nube a formato local con validación completa
  Frap _convertCloudToLocal(FrapFirestore cloud) {
    try {
      FrapConversionLogger.logConversionStart('cloud_to_local', cloud.id ?? 'unknown');
      
      // Validar y convertir datos del paciente
      final patientValidation = FrapDataValidator.validatePatientData(cloud.patientInfo);
      final patientData = patientValidation.cleanedData ?? {};
      
      FrapConversionLogger.logValidationResult('patient', patientValidation);
      
      // Validar y convertir historia clínica
      final clinicalValidation = FrapDataValidator.validateClinicalHistoryData(cloud.clinicalHistory);
      final clinicalData = clinicalValidation.cleanedData ?? {};
      
      FrapConversionLogger.logValidationResult('clinical_history', clinicalValidation);
      
      // Validar y convertir examen físico
      final examValidation = FrapDataValidator.validatePhysicalExamData(cloud.physicalExam);
      final examData = examValidation.cleanedData ?? {};
      
      FrapConversionLogger.logValidationResult('physical_exam', examValidation);

      // Crear un registro local basado en los datos de la nube
      final localFrap = Frap(
        id: cloud.id ?? 'cloud_${DateTime.now().millisecondsSinceEpoch}',
        patient: Patient(
          name: '${patientData['firstName'] ?? ''} ${patientData['paternalLastName'] ?? ''}',
          age: patientData['age'] ?? 0,
          sex: patientData['sex'] ?? '',
          address: patientData['address'] ?? '',
          firstName: patientData['firstName'] ?? '',
          paternalLastName: patientData['paternalLastName'] ?? '',
          maternalLastName: patientData['maternalLastName'] ?? '',
          phone: patientData['phone'] ?? '',
          street: patientData['street'] ?? '',
          exteriorNumber: patientData['exteriorNumber'] ?? '',
          interiorNumber: patientData['interiorNumber'],
          neighborhood: patientData['neighborhood'] ?? '',
          city: patientData['city'] ?? '',
          insurance: patientData['insurance'] ?? '',
          responsiblePerson: patientData['responsiblePerson'],
          gender: patientData['gender'] ?? '',
          entreCalles: patientData['entreCalles'] ?? '',
          tipoEntrega: patientData['tipoEntrega'] ?? '',
        ),
        clinicalHistory: ClinicalHistory(
          allergies: clinicalData['allergies'] ?? '',
          medications: clinicalData['medications'] ?? '',
          previousIllnesses: clinicalData['previousIllnesses'] ?? '',
        ),
        physicalExam: PhysicalExam(
          vitalSigns: examData['vitalSigns'] ?? '',
          head: examData['head'] ?? '',
          neck: examData['neck'] ?? '',
          thorax: examData['thorax'] ?? '',
          abdomen: examData['abdomen'] ?? '',
          extremities: examData['extremities'] ?? '',
          bloodPressure: examData['bloodPressure'] ?? '',
          heartRate: examData['heartRate'] ?? '',
          respiratoryRate: examData['respiratoryRate'] ?? '',
          temperature: examData['temperature'] ?? '',
          oxygenSaturation: examData['oxygenSaturation'] ?? '',
          neurological: examData['neurological'] ?? '',
        ),
        createdAt: cloud.createdAt,
        updatedAt: cloud.updatedAt,
        serviceInfo: _convertSectionData(cloud.serviceInfo),
        registryInfo: _convertSectionData(cloud.registryInfo),
        management: _convertSectionData(cloud.management),
        medications: _convertSectionData(cloud.medications),
        gynecoObstetric: _convertSectionData(cloud.gynecoObstetric),
        attentionNegative: _convertSectionData(cloud.attentionNegative),
        pathologicalHistory: _convertSectionData(cloud.pathologicalHistory),
        priorityJustification: _convertSectionData(cloud.priorityJustification),
        injuryLocation: _convertSectionData(cloud.injuryLocation),
        receivingUnit: _convertSectionData(cloud.receivingUnit),
        patientReception: _convertSectionData(cloud.patientReception),
        consentimientoServicio: '', // Campo específico del modelo local
        insumos: _convertInsumosFromCloud(cloud), // Convertir insumos si existen
        personalMedico: _convertPersonalMedicoFromCloud(cloud), // Convertir personal médico si existe
        escalasObstetricas: _convertEscalasObstetricasFromCloud(cloud), // Convertir escalas si existen
        isSynced: true,
      );

      FrapConversionLogger.logConversionSuccess('cloud_to_local', localFrap.id, {
        'patientFields': patientData.length,
        'clinicalFields': clinicalData.length,
        'examFields': examData.length,
        'insumos': localFrap.insumos.length,
        'personalMedico': localFrap.personalMedico.length,
      });

      return localFrap;
    } catch (e, stackTrace) {
      FrapConversionLogger.logConversionError('cloud_to_local', cloud.id ?? 'unknown', e.toString(), stackTrace);
      rethrow;
    }
  }

  // Convertir datos de sección con validación
  Map<String, dynamic> _convertSectionData(Map<String, dynamic> cloudSection) {
    if (cloudSection.isEmpty) return {};
    
    final validation = FrapDataValidator.validateSectionData(cloudSection);
    return validation.cleanedData ?? {};
  }

  // Convertir insumos desde datos de la nube
  List<Insumo> _convertInsumosFromCloud(FrapFirestore cloud) {
    // Buscar insumos en diferentes ubicaciones posibles
    final insumosData = cloud.serviceInfo['insumos'] ?? 
                       cloud.management['insumos'] ?? 
                       [];
    
    if (insumosData is List) {
      final validation = FrapDataValidator.validateInsumosData(insumosData);
      if (validation.isValid && validation.cleanedData != null) {
        final cleanedInsumos = validation.cleanedData!['insumos'] as List;
        return cleanedInsumos.map((insumoData) {
          return Insumo(
            cantidad: insumoData['cantidad'] ?? 0,
            articulo: insumoData['articulo'] ?? '',
          );
        }).toList();
      }
    }
    
    return [];
  }

  // Convertir personal médico desde datos de la nube
  List<PersonalMedico> _convertPersonalMedicoFromCloud(FrapFirestore cloud) {
    // Buscar personal médico en diferentes ubicaciones posibles
    final personalData = cloud.serviceInfo['personalMedico'] ?? 
                        cloud.management['personalMedico'] ?? 
                        [];
    
    if (personalData is List) {
      final validation = FrapDataValidator.validatePersonalMedicoData(personalData);
      if (validation.isValid && validation.cleanedData != null) {
        final cleanedPersonal = validation.cleanedData!['personalMedico'] as List;
        return cleanedPersonal.map((personalData) {
          return PersonalMedico(
            nombre: personalData['nombre'] ?? '',
            especialidad: personalData['especialidad'] ?? '',
            cedula: personalData['cedula'] ?? '',
          );
        }).toList();
      }
    }
    
    return [];
  }

  // Convertir escalas obstétricas desde datos de la nube
  EscalasObstetricas? _convertEscalasObstetricasFromCloud(FrapFirestore cloud) {
    // Buscar escalas obstétricas en diferentes ubicaciones posibles
    final escalasData = cloud.gynecoObstetric['escalasObstetricas'] ?? 
                       cloud.gynecoObstetric['escalas'] ?? 
                       {};
    
    if (escalasData is Map<String, dynamic>) {
      final validation = FrapDataValidator.validateEscalasObstetricasData(escalasData);
      if (validation.isValid && validation.cleanedData != null) {
        final cleanedData = validation.cleanedData!;
        return EscalasObstetricas(
          silvermanAnderson: Map<String, int>.from(cleanedData['silvermanAnderson'] ?? {}),
          apgar: Map<String, int>.from(cleanedData['apgar'] ?? {}),
          frecuenciaCardiacaFetal: cleanedData['frecuenciaCardiacaFetal'] ?? 0,
          contracciones: cleanedData['contracciones'] ?? '',
        );
      }
    }
    
    return null;
  }

  // Convertir registro local a formato nube
  FrapFirestore _convertLocalToCloud(Frap local) {
    try {
      FrapConversionLogger.logConversionStart('local_to_cloud', local.id);
      
      final cloudFrap = FrapFirestore(
        id: local.id,
        userId: '', // Se debe obtener del contexto de autenticación
        createdAt: local.createdAt,
        updatedAt: local.updatedAt,
        serviceInfo: local.serviceInfo,
        registryInfo: local.registryInfo,
        patientInfo: {
          'firstName': local.patient.firstName,
          'paternalLastName': local.patient.paternalLastName,
          'maternalLastName': local.patient.maternalLastName,
          'age': local.patient.age,
          'sex': local.patient.sex,
          'address': local.patient.address,
          'phone': local.patient.phone,
          'street': local.patient.street,
          'exteriorNumber': local.patient.exteriorNumber,
          'interiorNumber': local.patient.interiorNumber,
          'neighborhood': local.patient.neighborhood,
          'city': local.patient.city,
          'insurance': local.patient.insurance,
          'responsiblePerson': local.patient.responsiblePerson,
          'gender': local.patient.gender,
          'entreCalles': local.patient.entreCalles,
          'tipoEntrega': local.patient.tipoEntrega,
        },
        management: {
          ...local.management,
          'insumos': local.insumos.map((i) => i.toJson()).toList(),
          'personalMedico': local.personalMedico.map((p) => p.toJson()).toList(),
        },
        medications: local.medications,
        gynecoObstetric: {
          ...local.gynecoObstetric,
          'escalasObstetricas': local.escalasObstetricas?.toJson(),
        },
        attentionNegative: local.attentionNegative,
        pathologicalHistory: local.pathologicalHistory,
        clinicalHistory: {
          'allergies': local.clinicalHistory.allergies,
          'medications': local.clinicalHistory.medications,
          'previousIllnesses': local.clinicalHistory.previousIllnesses,
        },
        physicalExam: {
          'vitalSigns': local.physicalExam.vitalSigns,
          'head': local.physicalExam.head,
          'neck': local.physicalExam.neck,
          'thorax': local.physicalExam.thorax,
          'abdomen': local.physicalExam.abdomen,
          'extremities': local.physicalExam.extremities,
          'bloodPressure': local.physicalExam.bloodPressure,
          'heartRate': local.physicalExam.heartRate,
          'respiratoryRate': local.physicalExam.respiratoryRate,
          'temperature': local.physicalExam.temperature,
          'oxygenSaturation': local.physicalExam.oxygenSaturation,
          'neurological': local.physicalExam.neurological,
        },
        priorityJustification: local.priorityJustification,
        injuryLocation: local.injuryLocation,
        receivingUnit: local.receivingUnit,
        patientReception: local.patientReception,
      );

      FrapConversionLogger.logConversionSuccess('local_to_cloud', cloudFrap.id ?? '', {
        'patientFields': cloudFrap.patientInfo.length,
        'clinicalFields': cloudFrap.clinicalHistory.length,
        'examFields': cloudFrap.physicalExam.length,
        'insumos': local.insumos.length,
        'personalMedico': local.personalMedico.length,
      });

      return cloudFrap;
    } catch (e, stackTrace) {
      FrapConversionLogger.logConversionError('local_to_cloud', local.id, e.toString(), stackTrace);
      rethrow;
    }
  }

  // Sincronizar registros pendientes
  Future<SyncResult> syncPendingRecords() async {
    final result = SyncResult();
    
    try {
      if (!await hasInternetConnection()) {
        result.message = 'No hay conexión a internet';
        return result;
      }

      // Usar el servicio de migración para sincronización
      final migrationResult = await _migrationService.migrateBidirectional();
      
      result.success = migrationResult.success;
      result.message = migrationResult.message;
      result.successCount = migrationResult.migratedRecords;
      result.failedCount = migrationResult.failedRecords;
      result.errors = migrationResult.errors;
      
    } catch (e) {
      result.success = false;
      result.message = 'Error durante la sincronización: $e';
      result.errors.add(e.toString());
    }

    return result;
  }

  /// Obtener estadísticas de sincronización
  Future<Map<String, dynamic>> getSyncStats() async {
    return await _migrationService.getMigrationStats();
  }

  /// Limpiar recursos
  void dispose() {
    _migrationService.dispose();
  }
}

// Clase para representar un registro unificado
class UnifiedFrapRecord {
  final Frap? localRecord;
  final FrapFirestore? cloudRecord;
  final DateTime createdAt;
  final String patientName;
  final int patientAge;
  final String patientGender;
  final double completionPercentage;
  final bool isSynced;

  UnifiedFrapRecord({
    this.localRecord,
    this.cloudRecord,
    required this.createdAt,
    required this.patientName,
    required this.patientAge,
    required this.patientGender,
    required this.completionPercentage,
    required this.isSynced,
  });

  factory UnifiedFrapRecord.fromLocal(Frap local) {
    return UnifiedFrapRecord(
      localRecord: local,
      createdAt: local.createdAt,
      patientName: local.patient.fullName,
      patientAge: local.patient.age,
      patientGender: local.patient.sex,
      completionPercentage: local.completionPercentage,
      isSynced: local.isSynced,
    );
  }

  factory UnifiedFrapRecord.fromCloud(FrapFirestore cloud) {
    return UnifiedFrapRecord(
      cloudRecord: cloud,
      createdAt: cloud.createdAt,
      patientName: cloud.patientName,
      patientAge: cloud.patientAge,
      patientGender: cloud.patientGender,
      completionPercentage: cloud.completionPercentage,
      isSynced: true,
    );
  }
 
  // Propiedades adicionales
  bool get isLocal => localRecord != null;
  
  String get patientAddress {
    if (localRecord != null) {
      return localRecord!.patient.address;
    } else if (cloudRecord != null) {
      return cloudRecord!.patientInfo['address']?.toString() ?? '';
    }
    return '';
  }

  // Propiedad id para compatibilidad
  String get id {
    if (localRecord != null) {
      return localRecord!.id;
    } else if (cloudRecord != null) {
      return cloudRecord!.id ?? '';
    }
    return '';
  }

  // Método para obtener información detallada
  Map<String, dynamic> getDetailedInfo() {
    if (localRecord != null) {
      return _getDetailedInfoFromLocal(localRecord!);
    } else if (cloudRecord != null) {
      return _getDetailedInfoFromCloud(cloudRecord!);
    }
    return {};
  }

  Map<String, dynamic> _getDetailedInfoFromLocal(Frap local) {
    return {
      'serviceInfo': local.serviceInfo,
      'registryInfo': local.registryInfo,
      'patientInfo': {
        'name': local.patient.fullName,
        'age': local.patient.age,
        'sex': local.patient.sex,
        'address': local.patient.address,
        'phone': local.patient.phone,
        'insurance': local.patient.insurance,
        'responsiblePerson': local.patient.responsiblePerson,
        'gender': local.patient.gender,
        'firstName': local.patient.firstName,
        'paternalLastName': local.patient.paternalLastName,
        'maternalLastName': local.patient.maternalLastName,
        'street': local.patient.street,
        'exteriorNumber': local.patient.exteriorNumber,
        'interiorNumber': local.patient.interiorNumber,
        'neighborhood': local.patient.neighborhood,
        'city': local.patient.city,
        'entreCalles': local.patient.entreCalles,
        'tipoEntrega': local.patient.tipoEntrega,
      },
      'management': local.management,
      'medications': local.medications,
      'gynecoObstetric': local.gynecoObstetric,
      'attentionNegative': local.attentionNegative,
      'pathologicalHistory': local.pathologicalHistory,
      'clinicalHistory': {
        'allergies': local.clinicalHistory.allergies,
        'medications': local.clinicalHistory.medications,
        'previousIllnesses': local.clinicalHistory.previousIllnesses,
      },
      'physicalExam': {
        'vitalSigns': local.physicalExam.vitalSigns,
        'head': local.physicalExam.head,
        'neck': local.physicalExam.neck,
        'thorax': local.physicalExam.thorax,
        'abdomen': local.physicalExam.abdomen,
        'extremities': local.physicalExam.extremities,
        'bloodPressure': local.physicalExam.bloodPressure,
        'heartRate': local.physicalExam.heartRate,
        'respiratoryRate': local.physicalExam.respiratoryRate,
        'temperature': local.physicalExam.temperature,
        'oxygenSaturation': local.physicalExam.oxygenSaturation,
        'neurological': local.physicalExam.neurological,
        // Agregar signos vitales por columnas de tiempo si existen
        'T/A': {'1': local.physicalExam.bloodPressure},
        'FC': {'1': local.physicalExam.heartRate},
        'FR': {'1': local.physicalExam.respiratoryRate},
        'Temp.': {'1': local.physicalExam.temperature},
        'Sat. O2': {'1': local.physicalExam.oxygenSaturation},
        'LLC': {'1': ''},
        'Glu': {'1': ''},
        'Glasgow': {'1': ''},
      },
      'priorityJustification': local.priorityJustification,
      'injuryLocation': local.injuryLocation,
      'receivingUnit': local.receivingUnit,
      'patientReception': local.patientReception,
      'insumos': local.insumos.map((i) => i.toJson()).toList(),
      'personalMedico': local.personalMedico.map((p) => p.toJson()).toList(),
      'escalasObstetricas': local.escalasObstetricas?.toJson(),
    };
  }

  Map<String, dynamic> _getDetailedInfoFromCloud(FrapFirestore cloud) {
    return {
      'serviceInfo': cloud.serviceInfo,
      'registryInfo': cloud.registryInfo,
      'patientInfo': cloud.patientInfo,
      'management': cloud.management,
      'medications': cloud.medications,
      'gynecoObstetric': cloud.gynecoObstetric,
      'attentionNegative': cloud.attentionNegative,
      'pathologicalHistory': cloud.pathologicalHistory,
      'clinicalHistory': cloud.clinicalHistory,
      'physicalExam': cloud.physicalExam,
      'priorityJustification': cloud.priorityJustification,
      'injuryLocation': cloud.injuryLocation,
      'receivingUnit': cloud.receivingUnit,
      'patientReception': cloud.patientReception,
      'insumos': cloud.management['insumos'] ?? cloud.serviceInfo['insumos'] ?? [],
      'personalMedico': cloud.management['personalMedico'] ?? cloud.serviceInfo['personalMedico'] ?? [],
      'escalasObstetricas': cloud.gynecoObstetric['escalasObstetricas'] ?? cloud.gynecoObstetric['escalas'],
    };
  }
}

// Resultado de guardado unificado
class UnifiedSaveResult {
  bool success = false;
  String message = '';
  List<String> errors = [];
  String? localRecordId;
  String? cloudRecordId;
  bool savedLocally = false;
  bool savedToCloud = false;
  String? cloudError;
}

// Resultado de sincronización
class SyncResult {
  bool success = false;
  String message = '';
  List<String> errors = [];
  int successCount = 0;
  int failedCount = 0;
} 