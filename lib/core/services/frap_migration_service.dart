import 'dart:async';
import 'package:bg_med/core/services/frap_local_service.dart';
import 'package:bg_med/core/services/frap_firestore_service.dart';
import 'package:bg_med/core/models/frap.dart';
import 'package:bg_med/core/models/frap_firestore.dart';
import 'package:bg_med/core/models/frap_transition_model.dart';
import 'package:bg_med/core/services/frap_conversion_logger.dart';
import 'package:bg_med/features/frap/presentation/providers/frap_data_provider.dart';

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

  double get successRate =>
      totalRecords > 0 ? (migratedRecords / totalRecords) * 100 : 0.0;
}

/// Configuración para migración
class MigrationConfig {
  final bool skipExisting;
  final bool validateData;
  final int batchSize;
  final Duration timeout;
  final int maxRetries;
  final bool enableLogging;

  const MigrationConfig({
    this.skipExisting = true,
    this.validateData = true,
    this.batchSize = 50,
    this.timeout = const Duration(minutes: 5),
    this.maxRetries = 3,
    this.enableLogging = true,
  });
}

/// Métricas detalladas de migración
class MigrationMetrics {
  final int recordsProcessed;
  final int recordsSkipped;
  final int recordsUpdated;
  final int recordsCreated;
  final Duration averageTimePerRecord;
  final Map<String, int> errorsByType;
  final double successRate;
  final Duration totalDuration;

  const MigrationMetrics({
    required this.recordsProcessed,
    required this.recordsSkipped,
    required this.recordsUpdated,
    required this.recordsCreated,
    required this.averageTimePerRecord,
    required this.errorsByType,
    required this.successRate,
    required this.totalDuration,
  });

  Map<String, dynamic> toMap() {
    return {
      'recordsProcessed': recordsProcessed,
      'recordsSkipped': recordsSkipped,
      'recordsUpdated': recordsUpdated,
      'recordsCreated': recordsCreated,
      'averageTimePerRecord': averageTimePerRecord.inMilliseconds,
      'errorsByType': errorsByType,
      'successRate': successRate,
      'totalDuration': totalDuration.inMilliseconds,
    };
  }
}

/// Servicio de migración automática para transición gradual
class FrapMigrationService {
  final FrapLocalService _localService;
  final FrapFirestoreService _cloudService;
  final StreamController<MigrationProgress> _progressController;
  final MigrationConfig _config;
  bool _isCancelled = false;

  FrapMigrationService({
    required FrapLocalService localService,
    required FrapFirestoreService cloudService,
    MigrationConfig config = const MigrationConfig(),
  }) : _localService = localService,
       _cloudService = cloudService,
       _config = config,
       _progressController = StreamController<MigrationProgress>.broadcast();

  /// Stream de progreso de migración
  Stream<MigrationProgress> get progressStream => _progressController.stream;

  /// Cancelar migración en curso
  void cancelMigration() {
    _isCancelled = true;
  }

  /// Verificar si la migración fue cancelada
  bool get isCancelled => _isCancelled;

  /// Operación con reintentos automáticos
  Future<T> _retryOperation<T>(
    Future<T> Function() operation,
    String operationName,
  ) async {
    for (int i = 0; i < _config.maxRetries; i++) {
      try {
        return await operation();
      } catch (e) {
        if (i == _config.maxRetries - 1) {
          if (_config.enableLogging) {
            FrapConversionLogger.logConversionError(
              'retry_operation_failed',
              operationName,
              'Máximo de reintentos alcanzado: $e',
              StackTrace.current,
            );
          }
          rethrow;
        }

        await Future.delayed(Duration(seconds: 1 << i));
      }
    }
    throw Exception(
      'Operación falló después de ${_config.maxRetries} reintentos',
    );
  }

  /// Migrar registros de nube a local automáticamente
  Future<MigrationResult> migrateCloudToLocal() async {
    final startTime = DateTime.now();
    final errors = <String>[];
    int totalRecords = 0;
    int migratedRecords = 0;
    int failedRecords = 0;

    try {
      FrapConversionLogger.logConversionStart(
        'migration_cloud_to_local',
        'batch',
      );

      // Obtener registros de la nube
      final cloudRecords = await _cloudService.getAllFrapRecords();
      totalRecords = cloudRecords.length;

      _progressController.add(
        MigrationProgress(
          current: 0,
          total: totalRecords,
          message: 'Iniciando migración de $totalRecords registros',
          status: MigrationStatus.inProgress,
        ),
      );

      // Obtener registros locales existentes
      final localRecords = await _localService.getAllFrapRecords();

      for (int i = 0; i < cloudRecords.length; i++) {
        // Verificar si la migración fue cancelada
        if (_isCancelled) {
          _progressController.add(
            MigrationProgress(
              current: i,
              total: totalRecords,
              message: 'Migración cancelada por el usuario',
              status: MigrationStatus.failed,
            ),
          );
          throw Exception('Migración cancelada por el usuario');
        }

        final cloudRecord = cloudRecords[i];

        try {
          _progressController.add(
            MigrationProgress(
              current: i + 1,
              total: totalRecords,
              message:
                  'Migrando registro ${i + 1} de $totalRecords: ${cloudRecord.patientName}',
              status: MigrationStatus.inProgress,
            ),
          );

          // Verificar si ya existe en local
          final existingLocal =
              localRecords
                  .where((r) => _areRecordsEquivalent(r, cloudRecord))
                  .firstOrNull;

          if (existingLocal == null) {
            // Crear modelo de transición
            final transitionModel = FrapTransitionModel.fromCloud(cloudRecord);

            // Migrar a modelo local
            final localFrap = transitionModel.migrateToLocalStandard();

            // Guardar en local
            final frapData = _localService.convertFrapToFrapData(localFrap);
            final localId = await _retryOperation(
              () => _localService.createFrapRecord(frapData: frapData),
              'create_local_record',
            );

            if (localId != null) {
              migratedRecords++;
              FrapConversionLogger.logConversionSuccess(
                'migration_cloud_to_local',
                localId,
                {
                  'cloudId': cloudRecord.id,
                  'patientName': cloudRecord.patientName,
                },
              );
            } else {
              failedRecords++;
              errors.add(
                'Error guardando registro local para ${cloudRecord.patientName}',
              );
            }
          } else {
            // Actualizar registro existente si es más reciente
            if (cloudRecord.updatedAt.isAfter(existingLocal.updatedAt)) {
              final transitionModel = FrapTransitionModel.fromCloud(
                cloudRecord,
              );
              final updatedLocal = transitionModel.migrateToLocalStandard();

              final frapData = _localService.convertFrapToFrapData(
                updatedLocal,
              );
              await _retryOperation(
                () => _localService.updateFrapRecord(
                  frapId: existingLocal.id,
                  frapData: frapData,
                ),
                'update_local_record',
              );

              migratedRecords++;
              FrapConversionLogger.logConversionSuccess(
                'migration_update_local',
                existingLocal.id,
                {
                  'cloudId': cloudRecord.id,
                  'patientName': cloudRecord.patientName,
                },
              );
            }
          }
        } catch (e, stackTrace) {
          failedRecords++;
          final error =
              'Error migrando registro ${cloudRecord.patientName}: $e';
          errors.add(error);
          FrapConversionLogger.logConversionError(
            'migration_cloud_to_local',
            cloudRecord.id ?? 'unknown',
            error,
            stackTrace,
          );
        }
      }

      final duration = DateTime.now().difference(startTime);

      _progressController.add(
        MigrationProgress(
          current: totalRecords,
          total: totalRecords,
          message:
              'Migración completada: $migratedRecords exitosos, $failedRecords fallidos',
          status: MigrationStatus.completed,
        ),
      );

      final result = MigrationResult(
        success: failedRecords == 0,
        message:
            'Migración completada. $migratedRecords exitosos, $failedRecords fallidos',
        errors: errors,
        totalRecords: totalRecords,
        migratedRecords: migratedRecords,
        failedRecords: failedRecords,
        duration: duration,
        metadata: {
          'successRate':
              migratedRecords > 0
                  ? (migratedRecords / totalRecords) * 100
                  : 0.0,
          'averageTimePerRecord':
              totalRecords > 0 ? duration.inMilliseconds / totalRecords : 0,
        },
      );

      FrapConversionLogger.logConversionSummary(
        'migration_cloud_to_local',
        totalRecords,
        migratedRecords,
        failedRecords,
        errors,
      );

      return result;
    } catch (e, stackTrace) {
      final duration = DateTime.now().difference(startTime);
      final error = 'Error general en migración: $e';
      errors.add(error);

      _progressController.add(
        MigrationProgress(
          current: 0,
          total: totalRecords,
          message: 'Error en migración: $e',
          status: MigrationStatus.failed,
        ),
      );

      FrapConversionLogger.logConversionError(
        'migration_cloud_to_local',
        'batch',
        error,
        stackTrace,
      );

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
      FrapConversionLogger.logConversionStart(
        'migration_local_to_cloud',
        'batch',
      );

      // Obtener registros locales no sincronizados
      final localRecords = await _localService.getUnsyncedRecords();
      totalRecords = localRecords.length;

      _progressController.add(
        MigrationProgress(
          current: 0,
          total: totalRecords,
          message: 'Iniciando migración de $totalRecords registros locales',
          status: MigrationStatus.inProgress,
        ),
      );

      for (int i = 0; i < localRecords.length; i++) {
        // Verificar si la migración fue cancelada
        if (_isCancelled) {
          _progressController.add(
            MigrationProgress(
              current: i,
              total: totalRecords,
              message: 'Migración cancelada por el usuario',
              status: MigrationStatus.failed,
            ),
          );
          throw Exception('Migración cancelada por el usuario');
        }

        final localRecord = localRecords[i];

        try {
          _progressController.add(
            MigrationProgress(
              current: i + 1,
              total: totalRecords,
              message:
                  'Migrando registro ${i + 1} de $totalRecords: ${localRecord.patient.fullName}',
              status: MigrationStatus.inProgress,
            ),
          );

          // Crear modelo de transición
          final transitionModel = FrapTransitionModel.fromLocal(localRecord);

          // Migrar a modelo nube
          final cloudFrap = transitionModel.migrateToCloudStandard();

          // Convertir a FrapData para guardar en nube
          final frapData = FrapData(
            serviceInfo: cloudFrap.serviceInfo,
            registryInfo: cloudFrap.registryInfo,
            patientInfo: cloudFrap.patientInfo,
            management: cloudFrap.management,
            medications: cloudFrap.medications,
            gynecoObstetric: cloudFrap.gynecoObstetric,
            attentionNegative: cloudFrap.attentionNegative,
            pathologicalHistory: cloudFrap.pathologicalHistory,
            clinicalHistory: cloudFrap.clinicalHistory,
            physicalExam: cloudFrap.physicalExam,
            priorityJustification: cloudFrap.priorityJustification,
            injuryLocation: cloudFrap.injuryLocation,
            receivingUnit: cloudFrap.receivingUnit,
            patientReception: cloudFrap.patientReception,
          );

          final cloudId = await _retryOperation(
            () => _cloudService.createFrapRecord(frapData: frapData),
            'create_cloud_record',
          );

          if (cloudId != null) {
            // Marcar como sincronizado
            try {
              await _retryOperation(
                () => _localService.markAsSynced(localRecord.id),
                'mark_as_synced',
              );
            } catch (e) {
              if (_config.enableLogging) {
                FrapConversionLogger.logConversionError(
                  'mark_as_synced_failed',
                  localRecord.id,
                  'No se pudo marcar como sincronizado: $e',
                  StackTrace.current,
                );
              }
            }

            migratedRecords++;
            FrapConversionLogger.logConversionSuccess(
              'migration_local_to_cloud',
              cloudId,
              {
                'localId': localRecord.id,
                'patientName': localRecord.patient.fullName,
              },
            );
          } else {
            failedRecords++;
            errors.add(
              'Error guardando registro en nube para ${localRecord.patient.fullName}',
            );
          }
        } catch (e, stackTrace) {
          failedRecords++;
          final error =
              'Error migrando registro ${localRecord.patient.fullName}: $e';
          errors.add(error);
          FrapConversionLogger.logConversionError(
            'migration_local_to_cloud',
            localRecord.id,
            error,
            stackTrace,
          );
        }
      }

      final duration = DateTime.now().difference(startTime);

      _progressController.add(
        MigrationProgress(
          current: totalRecords,
          total: totalRecords,
          message:
              'Migración completada: $migratedRecords exitosos, $failedRecords fallidos',
          status: MigrationStatus.completed,
        ),
      );

      final result = MigrationResult(
        success: failedRecords == 0,
        message:
            'Migración completada. $migratedRecords exitosos, $failedRecords fallidos',
        errors: errors,
        totalRecords: totalRecords,
        migratedRecords: migratedRecords,
        failedRecords: failedRecords,
        duration: duration,
        metadata: {
          'successRate':
              migratedRecords > 0
                  ? (migratedRecords / totalRecords) * 100
                  : 0.0,
          'averageTimePerRecord':
              totalRecords > 0 ? duration.inMilliseconds / totalRecords : 0,
        },
      );

      FrapConversionLogger.logConversionSummary(
        'migration_local_to_cloud',
        totalRecords,
        migratedRecords,
        failedRecords,
        errors,
      );

      return result;
    } catch (e, stackTrace) {
      final duration = DateTime.now().difference(startTime);
      final error = 'Error general en migración: $e';
      errors.add(error);

      _progressController.add(
        MigrationProgress(
          current: 0,
          total: totalRecords,
          message: 'Error en migración: $e',
          status: MigrationStatus.failed,
        ),
      );

      FrapConversionLogger.logConversionError(
        'migration_local_to_cloud',
        'batch',
        error,
        stackTrace,
      );

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
      FrapConversionLogger.logConversionStart(
        'migration_bidirectional',
        'batch',
      );

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
        message:
            'Migración bidireccional completada. $migratedRecords exitosos, $failedRecords fallidos',
        errors: errors,
        totalRecords: totalRecords,
        migratedRecords: migratedRecords,
        failedRecords: failedRecords,
        duration: duration,
        metadata: {
          'cloudToLocal': cloudToLocalResult.metadata,
          'localToCloud': localToCloudResult.metadata,
          'successRate':
              migratedRecords > 0
                  ? (migratedRecords / totalRecords) * 100
                  : 0.0,
        },
      );

      return result;
    } catch (e, stackTrace) {
      final duration = DateTime.now().difference(startTime);
      final error = 'Error en migración bidireccional: $e';
      errors.add(error);

      FrapConversionLogger.logConversionError(
        'migration_bidirectional',
        'batch',
        error,
        stackTrace,
      );

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
        'syncRate':
            localRecords.isNotEmpty
                ? (syncedRecords / localRecords.length) * 100
                : 0.0,
        'lastSync':
            localRecords.isNotEmpty
                ? localRecords
                    .map((r) => r.updatedAt)
                    .reduce((a, b) => a.isAfter(b) ? a : b)
                : null,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// Obtener métricas detalladas de migración
  Future<MigrationMetrics> getDetailedMetrics() async {
    try {
      final localRecords = await _localService.getAllFrapRecords();
      final cloudRecords = await _cloudService.getAllFrapRecords();

      final syncedRecords = localRecords.where((r) => r.isSynced).length;
      final unsyncedRecords = localRecords.where((r) => !r.isSynced).length;

      final errorsByType = <String, int>{};
      // Aquí se podrían agregar más análisis de errores si se implementa tracking

      return MigrationMetrics(
        recordsProcessed: localRecords.length + cloudRecords.length,
        recordsSkipped: 0, // Se calcularía durante la migración
        recordsUpdated: syncedRecords,
        recordsCreated: unsyncedRecords,
        averageTimePerRecord:
            Duration.zero, // Se calcularía durante la migración
        errorsByType: errorsByType,
        successRate:
            localRecords.isNotEmpty
                ? (syncedRecords / localRecords.length) * 100
                : 0.0,
        totalDuration: Duration.zero, // Se calcularía durante la migración
      );
    } catch (e) {
      return MigrationMetrics(
        recordsProcessed: 0,
        recordsSkipped: 0,
        recordsUpdated: 0,
        recordsCreated: 0,
        averageTimePerRecord: Duration.zero,
        errorsByType: {'error': 1},
        successRate: 0.0,
        totalDuration: Duration.zero,
      );
    }
  }

  /// Limpiar recursos
  void dispose() {
    _isCancelled = true;
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

/*
/// Ejemplo de uso del servicio mejorado:

// 1. Crear servicio con configuración personalizada
final migrationService = FrapMigrationService(
  localService: frapLocalService,
  cloudService: frapFirestoreService,
  config: MigrationConfig(
    skipExisting: true,
    validateData: true,
    batchSize: 25,
    timeout: Duration(minutes: 10),
    maxRetries: 5,
    enableLogging: true,
  ),
);

// 2. Escuchar progreso en tiempo real
migrationService.progressStream.listen((progress) {
  print('Progreso: ${progress.percentage.toStringAsFixed(1)}%');
  print('Estado: ${progress.message}');
});

// 3. Ejecutar migración con manejo de cancelación
try {
  final result = await migrationService.migrateBidirectional();
  
  if (result.success) {
    print('✅ Migración exitosa: ${result.migratedRecords} registros');
    print('📊 Tasa de éxito: ${result.successRate.toStringAsFixed(1)}%');
  } else {
    print('❌ Errores: ${result.errors.join(', ')}');
  }
} catch (e) {
  if (e.toString().contains('cancelada')) {
    print('🛑 Migración cancelada por el usuario');
  } else {
    print('💥 Error inesperado: $e');
  }
}

// 4. Obtener métricas detalladas
final metrics = await migrationService.getDetailedMetrics();
print('📈 Métricas: ${metrics.toMap()}');

// 5. Cancelar migración si es necesario
migrationService.cancelMigration();

// 6. Limpiar recursos
migrationService.dispose();
*/
