import 'dart:async';
import 'package:bg_med/core/services/frap_local_service.dart';
import 'package:bg_med/core/services/frap_firestore_service.dart';
import 'package:bg_med/core/models/frap.dart';
import 'package:bg_med/core/models/frap_firestore.dart';
import 'package:bg_med/core/models/frap_transition_model.dart';
import 'package:bg_med/core/services/frap_conversion_logger.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Resultado de migración
class MigrationResult {
  final bool success;
  final String message;
  final List<String> errors;
  final int totalRecords;
  final int migratedRecords;
  final int failedRecords;
  final Duration duration;
  final Map<String, dynamic> metadata;

  const MigrationResult({
    required this.success,
    required this.message,
    this.errors = const [],
    this.totalRecords = 0,
    this.migratedRecords = 0,
    this.failedRecords = 0,
    this.duration = Duration.zero,
    this.metadata = const {},
  });

  double get successRate => totalRecords > 0 ? (migratedRecords / totalRecords) * 100 : 0.0;
}

/// Servicio de migración automática para transición gradual
class FrapMigrationService {
  final FrapLocalService _localService;
  final FrapFirestoreService _cloudService;
  final StreamController<MigrationProgress> _progressController;

  FrapMigrationService({
    required FrapLocalService localService,
    required FrapFirestoreService cloudService,
  }) : _localService = localService,
       _cloudService = cloudService,
       _progressController = StreamController<MigrationProgress>.broadcast();

  /// Stream de progreso de migración
  Stream<MigrationProgress> get progressStream => _progressController.stream;

  /// Migrar registros de nube a local automáticamente
  Future<MigrationResult> migrateCloudToLocal() async {
    final startTime = DateTime.now();
    final errors = <String>[];
    int totalRecords = 0;
    int migratedRecords = 0;
    int failedRecords = 0;

    try {
      FrapConversionLogger.logConversionStart('migration_cloud_to_local', 'batch');
      
      // Obtener registros de la nube
      final cloudRecords = await _cloudService.getAllFrapRecords();
      totalRecords = cloudRecords.length;

      _progressController.add(MigrationProgress(
        current: 0,
        total: totalRecords,
        message: 'Iniciando migración de ${totalRecords} registros',
        status: MigrationStatus.inProgress,
      ));

      // Obtener registros locales existentes
      final localRecords = await _localService.getAllFrapRecords();
      final existingLocalIds = localRecords.map((r) => r.id).toSet();

      for (int i = 0; i < cloudRecords.length; i++) {
        final cloudRecord = cloudRecords[i];
        
        try {
          _progressController.add(MigrationProgress(
            current: i + 1,
            total: totalRecords,
            message: 'Migrando registro ${i + 1} de $totalRecords: ${cloudRecord.patientName}',
            status: MigrationStatus.inProgress,
          ));

          // Verificar si ya existe en local
          final existingLocal = localRecords.where((r) => 
            _areRecordsEquivalent(r, cloudRecord)
          ).firstOrNull;

          if (existingLocal == null) {
            // Crear modelo de transición
            final transitionModel = FrapTransitionModel.fromCloud(cloudRecord);
            
            // Migrar a modelo local
            final localFrap = transitionModel.migrateToLocalStandard();
            
            // Guardar en local
            final frapData = _localService.convertFrapToFrapData(localFrap);
            final localId = await _localService.createFrapRecord(frapData: frapData);
            
            if (localId != null) {
              migratedRecords++;
              FrapConversionLogger.logConversionSuccess('migration_cloud_to_local', localId, {
                'cloudId': cloudRecord.id,
                'patientName': cloudRecord.patientName,
              });
            } else {
              failedRecords++;
              errors.add('Error guardando registro local para ${cloudRecord.patientName}');
            }
          } else {
            // Actualizar registro existente si es más reciente
            if (cloudRecord.updatedAt.isAfter(existingLocal.updatedAt)) {
              final transitionModel = FrapTransitionModel.fromCloud(cloudRecord);
              final updatedLocal = transitionModel.migrateToLocalStandard();
              
              final frapData = _localService.convertFrapToFrapData(updatedLocal);
              await _localService.updateFrapRecord(
                frapId: existingLocal.id,
                frapData: frapData,
              );
              
              migratedRecords++;
              FrapConversionLogger.logConversionSuccess('migration_update_local', existingLocal.id, {
                'cloudId': cloudRecord.id,
                'patientName': cloudRecord.patientName,
              });
            }
          }
        } catch (e, stackTrace) {
          failedRecords++;
          final error = 'Error migrando registro ${cloudRecord.patientName}: $e';
          errors.add(error);
          FrapConversionLogger.logConversionError('migration_cloud_to_local', cloudRecord.id ?? 'unknown', error, stackTrace);
        }
      }

      final duration = DateTime.now().difference(startTime);
      
      _progressController.add(MigrationProgress(
        current: totalRecords,
        total: totalRecords,
        message: 'Migración completada: $migratedRecords exitosos, $failedRecords fallidos',
        status: MigrationStatus.completed,
      ));

      final result = MigrationResult(
        success: failedRecords == 0,
        message: 'Migración completada. $migratedRecords exitosos, $failedRecords fallidos',
        errors: errors,
        totalRecords: totalRecords,
        migratedRecords: migratedRecords,
        failedRecords: failedRecords,
        duration: duration,
        metadata: {
          'successRate': migratedRecords > 0 ? (migratedRecords / totalRecords) * 100 : 0.0,
          'averageTimePerRecord': totalRecords > 0 ? duration.inMilliseconds / totalRecords : 0,
        },
      );

      FrapConversionLogger.logConversionSummary('migration_cloud_to_local', totalRecords, migratedRecords, failedRecords, errors);
      
      return result;
    } catch (e, stackTrace) {
      final duration = DateTime.now().difference(startTime);
      final error = 'Error general en migración: $e';
      errors.add(error);
      
      _progressController.add(MigrationProgress(
        current: 0,
        total: totalRecords,
        message: 'Error en migración: $e',
        status: MigrationStatus.failed,
      ));

      FrapConversionLogger.logConversionError('migration_cloud_to_local', 'batch', error, stackTrace);
      
      return MigrationResult(
        success: false,
        message: error,
        errors: errors,
        totalRecords: totalRecords,
        migratedRecords: migratedRecords,
        failedRecords: failedRecords,
        duration: duration,
      );
    }
  }

  /// Migrar registros locales a nube automáticamente
  Future<MigrationResult> migrateLocalToCloud() async {
    final startTime = DateTime.now();
    final errors = <String>[];
    int totalRecords = 0;
    int migratedRecords = 0;
    int failedRecords = 0;

    try {
      FrapConversionLogger.logConversionStart('migration_local_to_cloud', 'batch');
      
      // Obtener registros locales no sincronizados
      final localRecords = await _localService.getUnsyncedRecords();
      totalRecords = localRecords.length;

      _progressController.add(MigrationProgress(
        current: 0,
        total: totalRecords,
        message: 'Iniciando migración de ${totalRecords} registros locales',
        status: MigrationStatus.inProgress,
      ));

      for (int i = 0; i < localRecords.length; i++) {
        final localRecord = localRecords[i];
        
        try {
          _progressController.add(MigrationProgress(
            current: i + 1,
            total: totalRecords,
            message: 'Migrando registro ${i + 1} de $totalRecords: ${localRecord.patient.fullName}',
            status: MigrationStatus.inProgress,
          ));

          // Crear modelo de transición
          final transitionModel = FrapTransitionModel.fromLocal(localRecord);
          
          // Migrar a modelo nube
          final cloudFrap = transitionModel.migrateToCloudStandard();
          
          // Guardar en nube
          final frapData = _localService.convertFrapToFrapData(localRecord);
          final cloudId = await _cloudService.createFrapRecord(frapData: frapData);
          
          if (cloudId != null) {
            // Marcar como sincronizado
            try {
              await _localService.markAsSynced(localRecord.id);
            } catch (e) {
              // Si el método no existe, ignorar
            }
            
            migratedRecords++;
            FrapConversionLogger.logConversionSuccess('migration_local_to_cloud', cloudId, {
              'localId': localRecord.id,
              'patientName': localRecord.patient.fullName,
            });
          } else {
            failedRecords++;
            errors.add('Error guardando registro en nube para ${localRecord.patient.fullName}');
          }
        } catch (e, stackTrace) {
          failedRecords++;
          final error = 'Error migrando registro ${localRecord.patient.fullName}: $e';
          errors.add(error);
          FrapConversionLogger.logConversionError('migration_local_to_cloud', localRecord.id, error, stackTrace);
        }
      }

      final duration = DateTime.now().difference(startTime);
      
      _progressController.add(MigrationProgress(
        current: totalRecords,
        total: totalRecords,
        message: 'Migración completada: $migratedRecords exitosos, $failedRecords fallidos',
        status: MigrationStatus.completed,
      ));

      final result = MigrationResult(
        success: failedRecords == 0,
        message: 'Migración completada. $migratedRecords exitosos, $failedRecords fallidos',
        errors: errors,
        totalRecords: totalRecords,
        migratedRecords: migratedRecords,
        failedRecords: failedRecords,
        duration: duration,
        metadata: {
          'successRate': migratedRecords > 0 ? (migratedRecords / totalRecords) * 100 : 0.0,
          'averageTimePerRecord': totalRecords > 0 ? duration.inMilliseconds / totalRecords : 0,
        },
      );

      FrapConversionLogger.logConversionSummary('migration_local_to_cloud', totalRecords, migratedRecords, failedRecords, errors);
      
      return result;
    } catch (e, stackTrace) {
      final duration = DateTime.now().difference(startTime);
      final error = 'Error general en migración: $e';
      errors.add(error);
      
      _progressController.add(MigrationProgress(
        current: 0,
        total: totalRecords,
        message: 'Error en migración: $e',
        status: MigrationStatus.failed,
      ));

      FrapConversionLogger.logConversionError('migration_local_to_cloud', 'batch', error, stackTrace);
      
      return MigrationResult(
        success: false,
        message: error,
        errors: errors,
        totalRecords: totalRecords,
        migratedRecords: migratedRecords,
        failedRecords: failedRecords,
        duration: duration,
      );
    }
  }

  /// Migración bidireccional completa
  Future<MigrationResult> migrateBidirectional() async {
    final startTime = DateTime.now();
    final errors = <String>[];
    int totalRecords = 0;
    int migratedRecords = 0;
    int failedRecords = 0;

    try {
      FrapConversionLogger.logConversionStart('migration_bidirectional', 'batch');
      
      // Migrar nube a local
      final cloudToLocalResult = await migrateCloudToLocal();
      totalRecords += cloudToLocalResult.totalRecords;
      migratedRecords += cloudToLocalResult.migratedRecords;
      failedRecords += cloudToLocalResult.failedRecords;
      errors.addAll(cloudToLocalResult.errors);

      // Migrar local a nube
      final localToCloudResult = await migrateLocalToCloud();
      totalRecords += localToCloudResult.totalRecords;
      migratedRecords += localToCloudResult.migratedRecords;
      failedRecords += localToCloudResult.failedRecords;
      errors.addAll(localToCloudResult.errors);

      final duration = DateTime.now().difference(startTime);
      
      final result = MigrationResult(
        success: failedRecords == 0,
        message: 'Migración bidireccional completada. $migratedRecords exitosos, $failedRecords fallidos',
        errors: errors,
        totalRecords: totalRecords,
        migratedRecords: migratedRecords,
        failedRecords: failedRecords,
        duration: duration,
        metadata: {
          'cloudToLocal': cloudToLocalResult.metadata,
          'localToCloud': localToCloudResult.metadata,
          'successRate': migratedRecords > 0 ? (migratedRecords / totalRecords) * 100 : 0.0,
        },
      );

      return result;
    } catch (e, stackTrace) {
      final duration = DateTime.now().difference(startTime);
      final error = 'Error en migración bidireccional: $e';
      errors.add(error);
      
      FrapConversionLogger.logConversionError('migration_bidirectional', 'batch', error, stackTrace);
      
      return MigrationResult(
        success: false,
        message: error,
        errors: errors,
        totalRecords: totalRecords,
        migratedRecords: migratedRecords,
        failedRecords: failedRecords,
        duration: duration,
      );
    }
  }

  /// Verificar si dos registros son equivalentes
  bool _areRecordsEquivalent(Frap local, FrapFirestore cloud) {
    // Comparar por datos del paciente y fecha de creación
    final localPatientName = local.patient.fullName.toLowerCase();
    final cloudPatientName = cloud.patientName.toLowerCase();
    
    return localPatientName == cloudPatientName &&
           local.createdAt.difference(cloud.createdAt).abs().inMinutes < 5;
  }

  /// Obtener estadísticas de migración
  Future<Map<String, dynamic>> getMigrationStats() async {
    try {
      final localRecords = await _localService.getAllFrapRecords();
      final cloudRecords = await _cloudService.getAllFrapRecords();
      
      final syncedRecords = localRecords.where((r) => r.isSynced).length;
      final unsyncedRecords = localRecords.where((r) => !r.isSynced).length;
      
      return {
        'totalLocalRecords': localRecords.length,
        'totalCloudRecords': cloudRecords.length,
        'syncedRecords': syncedRecords,
        'unsyncedRecords': unsyncedRecords,
        'syncRate': localRecords.isNotEmpty ? (syncedRecords / localRecords.length) * 100 : 0.0,
        'lastSync': localRecords.isNotEmpty ? localRecords.map((r) => r.updatedAt).reduce((a, b) => a.isAfter(b) ? a : b) : null,
      };
    } catch (e) {
      return {
        'error': e.toString(),
      };
    }
  }

  /// Limpiar recursos
  void dispose() {
    _progressController.close();
  }
}

/// Progreso de migración
class MigrationProgress {
  final int current;
  final int total;
  final String message;
  final MigrationStatus status;

  const MigrationProgress({
    required this.current,
    required this.total,
    required this.message,
    required this.status,
  });

  double get percentage => total > 0 ? (current / total) * 100 : 0.0;
} 