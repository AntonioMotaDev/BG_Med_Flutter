import 'dart:async';
import 'package:bg_med/core/services/frap_local_service.dart';
import 'package:bg_med/core/services/frap_firestore_service.dart';
import 'package:bg_med/core/models/frap.dart';
import 'package:bg_med/core/models/frap_firestore.dart';
import 'package:bg_med/core/models/patient.dart';
import 'package:bg_med/core/models/clinical_history.dart';
import 'package:bg_med/core/models/physical_exam.dart';
import 'package:bg_med/features/frap/presentation/providers/frap_data_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class FrapUnifiedService {
  final FrapLocalService _localService;
  final FrapFirestoreService _cloudService;
  final Connectivity _connectivity;

  FrapUnifiedService({
    required FrapLocalService localService,
    required FrapFirestoreService cloudService,
    Connectivity? connectivity,
  }) : _localService = localService,
       _cloudService = cloudService,
       _connectivity = connectivity ?? Connectivity();

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
      } else {
        throw Exception('No se pudo guardar localmente');
      }
    } catch (e) {
      result.success = false;
      result.message = 'Error al guardar: $e';
      result.errors.add(e.toString());
    }

    return result;
  }

  // Obtener todos los registros (local + nube)
  Future<List<UnifiedFrapRecord>> getAllRecords() async {
    final List<UnifiedFrapRecord> unifiedRecords = [];
    
    try {
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
      
    } catch (e) {
      print('Error obteniendo registros unificados: $e');
    }

    return unifiedRecords;
  }

  // Verificar si dos registros son equivalentes
  bool _areRecordsEquivalent(Frap local, FrapFirestore cloud) {
    // Comparar por datos del paciente y fecha de creación
    final localPatientName = '${local.patient.firstName} ${local.patient.paternalLastName}';
    final cloudPatientName = '${cloud.patientInfo['firstName'] ?? ''} ${cloud.patientInfo['paternalLastName'] ?? ''}';
    
    return localPatientName.toLowerCase() == cloudPatientName.toLowerCase() &&
           local.createdAt.difference(cloud.createdAt).abs().inMinutes < 5;
  }

  // Convertir registro de la nube a formato local
  Frap _convertCloudToLocal(FrapFirestore cloud) {
    // Crear un registro local basado en los datos de la nube
    return Frap(
      id: cloud.id ?? 'cloud_${DateTime.now().millisecondsSinceEpoch}',
      patient: Patient(
        name: '${cloud.patientInfo['firstName'] ?? ''} ${cloud.patientInfo['paternalLastName'] ?? ''}',
        age: cloud.patientInfo['age'] ?? 0,
        sex: cloud.patientInfo['sex'] ?? '',
        address: cloud.patientInfo['address'] ?? '',
      ),
      clinicalHistory: ClinicalHistory(
        allergies: cloud.clinicalHistory['allergies'] ?? '',
        medications: cloud.clinicalHistory['medications'] ?? '',
        previousIllnesses: cloud.clinicalHistory['previousIllnesses'] ?? '',
      ),
      physicalExam: PhysicalExam(
        vitalSigns: cloud.physicalExam['vitalSigns'] ?? '',
        head: cloud.physicalExam['head'] ?? '',
        neck: cloud.physicalExam['neck'] ?? '',
        thorax: cloud.physicalExam['thorax'] ?? '',
        abdomen: cloud.physicalExam['abdomen'] ?? '',
        extremities: cloud.physicalExam['extremities'] ?? '',
        bloodPressure: cloud.physicalExam['bloodPressure'] ?? '',
        heartRate: cloud.physicalExam['heartRate'] ?? '',
        respiratoryRate: cloud.physicalExam['respiratoryRate'] ?? '',
        temperature: cloud.physicalExam['temperature'] ?? '',
        oxygenSaturation: cloud.physicalExam['oxygenSaturation'] ?? '',
        neurological: cloud.physicalExam['neurological'] ?? '',
      ),
      createdAt: cloud.createdAt,
      updatedAt: cloud.updatedAt,
      serviceInfo: cloud.serviceInfo,
      registryInfo: cloud.registryInfo,
      management: cloud.management,
      medications: cloud.medications,
      gynecoObstetric: cloud.gynecoObstetric,
      attentionNegative: cloud.attentionNegative,
      pathologicalHistory: cloud.pathologicalHistory,
      priorityJustification: cloud.priorityJustification,
      injuryLocation: cloud.injuryLocation,
      receivingUnit: cloud.receivingUnit,
      patientReception: cloud.patientReception,
      isSynced: true,
    );
  }

  // Sincronizar registros pendientes
  Future<SyncResult> syncPendingRecords() async {
    final result = SyncResult();
    
    try {
      if (!await hasInternetConnection()) {
        result.message = 'No hay conexión a internet';
        return result;
      }

      // Sincronizar locales a la nube
      final localToCloud = await _syncLocalToCloud();
      result.successCount += localToCloud.successCount;
      result.failedCount += localToCloud.failedCount;
      result.errors.addAll(localToCloud.errors);

      // Sincronizar nube a local
      final cloudToLocal = await _syncCloudToLocal();
      result.successCount += cloudToLocal.successCount;
      result.failedCount += cloudToLocal.failedCount;
      result.errors.addAll(cloudToLocal.errors);

      result.success = result.failedCount == 0;
      result.message = 'Sincronización completada. ${result.successCount} exitosos, ${result.failedCount} fallidos';
      
    } catch (e) {
      result.success = false;
      result.message = 'Error durante la sincronización: $e';
      result.errors.add(e.toString());
    }

    return result;
  }

  Future<SyncResult> _syncLocalToCloud() async {
    final result = SyncResult();
    
    try {
      final localRecords = await _localService.getUnsyncedRecords();
      
      for (final localRecord in localRecords) {
        try {
          final frapData = _localService.convertFrapToFrapData(localRecord);
          final cloudRecordId = await _cloudService.createFrapRecord(frapData: frapData);
          
          if (cloudRecordId != null) {
            // Intentar marcar como sincronizado (si el método existe)
            try {
              await _localService.markAsSynced(localRecord.id);
            } catch (e) {
              print('Warning: markAsSynced method not available');
            }
            result.successCount++;
          } else {
            result.failedCount++;
          }
        } catch (e) {
          result.failedCount++;
          result.errors.add('Error sincronizando ${localRecord.patient.name}: $e');
        }
      }
    } catch (e) {
      result.errors.add(e.toString());
    }

    return result;
  }

  Future<SyncResult> _syncCloudToLocal() async {
    final result = SyncResult();
    
    try {
      final cloudRecords = await _cloudService.getAllFrapRecords();
      final localRecords = await _localService.getAllFrapRecords();
      
      for (final cloudRecord in cloudRecords) {
        final existingLocal = localRecords.where((r) => 
          _areRecordsEquivalent(r, cloudRecord)
        ).firstOrNull;

        if (existingLocal == null) {
          // Crear nuevo registro local
          final newLocal = _convertCloudToLocal(cloudRecord);
          try {
            final frapData = _localService.convertFrapToFrapData(newLocal);
            await _localService.createFrapRecord(frapData: frapData);
            result.successCount++;
          } catch (e) {
            print('Error creando registro local: $e');
          }
        }
      }
    } catch (e) {
      result.errors.add(e.toString());
    }

    return result;
  }
}

// Clase para representar un registro unificado
class UnifiedFrapRecord {
  final Frap? localRecord;
  final FrapFirestore? cloudRecord;
  final DateTime createdAt;
  final bool isLocal;
  final bool isCloud;
  final bool isSynced;

  UnifiedFrapRecord.fromLocal(Frap local)
      : localRecord = local,
        cloudRecord = null,
        createdAt = local.createdAt,
        isLocal = true,
        isCloud = false,
        isSynced = local.isSynced;

  UnifiedFrapRecord.fromCloud(FrapFirestore cloud)
      : localRecord = null,
        cloudRecord = cloud,
        createdAt = cloud.createdAt,
        isLocal = false,
        isCloud = true,
        isSynced = true;

  // Getter para obtener el ID del registro
  String get id {
    if (isLocal && localRecord != null) {
      return localRecord!.id;
    } else if (isCloud && cloudRecord != null) {
      return cloudRecord!.id ?? '';
    }
    return '';
  }

  String get patientName {
    if (isLocal && localRecord != null) {
      return localRecord!.patient.name;
    } else if (isCloud && cloudRecord != null) {
      final firstName = cloudRecord!.patientInfo['firstName']?.toString() ?? '';
      final lastName = cloudRecord!.patientInfo['paternalLastName']?.toString() ?? '';
      return '$firstName $lastName'.trim();
    }
    return 'Sin nombre';
  }

  String get address {
    if (isLocal && localRecord != null) {
      return localRecord!.patient.address;
    } else if (isCloud && cloudRecord != null) {
      return cloudRecord!.patientInfo['address']?.toString() ?? '';
    }
    return '';
  }

  int get patientAge {
    if (isLocal && localRecord != null) {
      return localRecord!.patient.age;
    } else if (isCloud && cloudRecord != null) {
      return cloudRecord!.patientAge;
    }
    return 0;
  }

  String get patientGender {
    if (isLocal && localRecord != null) {
      return localRecord!.patient.sex;
    } else if (isCloud && cloudRecord != null) {
      return cloudRecord!.patientGender;
    }
    return '';
  }

  String get patientAddress {
    if (isLocal && localRecord != null) {
      return localRecord!.patient.address;
    } else if (isCloud && cloudRecord != null) {
      return cloudRecord!.patientInfo['address']?.toString() ?? '';
    }
    return '';
  }

  double get completionPercentage {
    if (isLocal && localRecord != null) {
      // Calcular porcentaje de completitud basado en campos llenos
      final info = getDetailedInfo();
      int filledFields = 0;
      int totalFields = 0;
      
      // Contar campos llenos en cada sección
      for (final section in info.values) {
        if (section is Map<String, dynamic>) {
          for (final field in section.values) {
            totalFields++;
            if (field != null && field.toString().isNotEmpty) {
              filledFields++;
            }
          }
        }
      }
      
      return totalFields > 0 ? (filledFields / totalFields) * 100 : 0.0;
    } else if (isCloud && cloudRecord != null) {
      // Para registros de la nube, asumir 100% completos
      return 100.0;
    }
    return 0.0;
  }

  Map<String, dynamic> getDetailedInfo() {
    if (isLocal && localRecord != null) {
      return {
        'serviceInfo': localRecord!.serviceInfo,
        'registryInfo': localRecord!.registryInfo,
        'patientInfo': {
          'name': localRecord!.patient.name,
          'age': localRecord!.patient.age,
          'sex': localRecord!.patient.sex,
          'address': localRecord!.patient.address,
        },
        'clinicalHistory': {
          'allergies': localRecord!.clinicalHistory.allergies,
          'medications': localRecord!.clinicalHistory.medications,
          'previousIllnesses': localRecord!.clinicalHistory.previousIllnesses,
        },
        'physicalExam': {
          'vitalSigns': localRecord!.physicalExam.vitalSigns,
          'head': localRecord!.physicalExam.head,
          'neck': localRecord!.physicalExam.neck,
          'thorax': localRecord!.physicalExam.thorax,
          'abdomen': localRecord!.physicalExam.abdomen,
          'extremities': localRecord!.physicalExam.extremities,
          'bloodPressure': localRecord!.physicalExam.bloodPressure,
          'heartRate': localRecord!.physicalExam.heartRate,
          'respiratoryRate': localRecord!.physicalExam.respiratoryRate,
          'temperature': localRecord!.physicalExam.temperature,
          'oxygenSaturation': localRecord!.physicalExam.oxygenSaturation,
          'neurological': localRecord!.physicalExam.neurological,
        },
        'management': localRecord!.management,
        'medications': localRecord!.medications,
        'gynecoObstetric': localRecord!.gynecoObstetric,
        'attentionNegative': localRecord!.attentionNegative,
        'pathologicalHistory': localRecord!.pathologicalHistory,
        'priorityJustification': localRecord!.priorityJustification,
        'injuryLocation': localRecord!.injuryLocation,
        'receivingUnit': localRecord!.receivingUnit,
        'patientReception': localRecord!.patientReception,
      };
    } else if (isCloud && cloudRecord != null) {
      return {
        'serviceInfo': cloudRecord!.serviceInfo,
        'registryInfo': cloudRecord!.registryInfo,
        'patientInfo': cloudRecord!.patientInfo,
        'clinicalHistory': cloudRecord!.clinicalHistory,
        'physicalExam': cloudRecord!.physicalExam,
        'management': cloudRecord!.management,
        'medications': cloudRecord!.medications,
        'gynecoObstetric': cloudRecord!.gynecoObstetric,
        'attentionNegative': cloudRecord!.attentionNegative,
        'pathologicalHistory': cloudRecord!.pathologicalHistory,
        'priorityJustification': cloudRecord!.priorityJustification,
        'injuryLocation': cloudRecord!.injuryLocation,
        'receivingUnit': cloudRecord!.receivingUnit,
        'patientReception': cloudRecord!.patientReception,
      };
    }
    return {};
  }
}

// Clases de resultado
class UnifiedSaveResult {
  bool success = false;
  String message = '';
  String? localRecordId;
  String? cloudRecordId;
  bool savedLocally = false;
  bool savedToCloud = false;
  String? cloudError;
  List<String> errors = [];
}

class SyncResult {
  bool success = false;
  String message = '';
  int successCount = 0;
  int failedCount = 0;
  List<String> syncedRecords = [];
  List<String> failedRecords = [];
  List<String> errors = [];
} 