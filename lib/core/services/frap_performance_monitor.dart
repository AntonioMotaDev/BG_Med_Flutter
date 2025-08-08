import 'dart:async';
import 'dart:developer' as developer;
import 'package:bg_med/core/services/frap_conversion_logger.dart';

/// Monitor de performance para operaciones FRAP
class FrapPerformanceMonitor {
  static const String _tag = 'FrapPerformance';
  
  static final Map<String, _OperationMetrics> _activeOperations = {};
  static final List<_PerformanceRecord> _performanceHistory = [];
  static const int _maxHistorySize = 100;

  /// Iniciar medición de una operación
  static String startOperation(String operationType, {Map<String, dynamic>? metadata}) {
    final operationId = '${operationType}_${DateTime.now().millisecondsSinceEpoch}';
    
    _activeOperations[operationId] = _OperationMetrics(
      id: operationId,
      type: operationType,
      startTime: DateTime.now(),
      metadata: metadata ?? {},
    );

    developer.log(
      'Iniciando medición de operación: $operationType (ID: $operationId)',
      name: _tag,
      level: 700,
    );

    return operationId;
  }

  /// Finalizar medición de una operación
  static void endOperation(String operationId, {
    bool success = true,
    String? errorMessage,
    Map<String, dynamic>? additionalMetrics,
  }) {
    final operation = _activeOperations.remove(operationId);
    if (operation == null) {
      developer.log(
        'Operación no encontrada: $operationId',
        name: _tag,
        level: 900,
      );
      return;
    }

    final endTime = DateTime.now();
    final duration = endTime.difference(operation.startTime);

    final record = _PerformanceRecord(
      operationId: operationId,
      operationType: operation.type,
      startTime: operation.startTime,
      endTime: endTime,
      duration: duration,
      success: success,
      errorMessage: errorMessage,
      metadata: {
        ...operation.metadata,
        ...?additionalMetrics,
      },
    );

    _addToHistory(record);
    _logPerformanceRecord(record);
  }

  /// Medir una operación async con callback
  static Future<T> measureOperation<T>(
    String operationType,
    Future<T> Function() operation, {
    Map<String, dynamic>? metadata,
  }) async {
    final operationId = startOperation(operationType, metadata: metadata);
    
    try {
      final result = await operation();
      endOperation(operationId, success: true, additionalMetrics: {
        'resultType': T.toString(),
      });
      return result;
    } catch (e, stackTrace) {
      endOperation(
        operationId,
        success: false,
        errorMessage: e.toString(),
        additionalMetrics: {
          'errorType': e.runtimeType.toString(),
          'stackTrace': stackTrace.toString(),
        },
      );
      rethrow;
    }
  }

  /// Medir una operación sync con callback
  static T measureSyncOperation<T>(
    String operationType,
    T Function() operation, {
    Map<String, dynamic>? metadata,
  }) {
    final operationId = startOperation(operationType, metadata: metadata);
    
    try {
      final result = operation();
      endOperation(operationId, success: true, additionalMetrics: {
        'resultType': T.toString(),
      });
      return result;
    } catch (e, stackTrace) {
      endOperation(
        operationId,
        success: false,
        errorMessage: e.toString(),
        additionalMetrics: {
          'errorType': e.runtimeType.toString(),
          'stackTrace': stackTrace.toString(),
        },
      );
      rethrow;
    }
  }

  /// Obtener métricas de performance por tipo de operación
  static Map<String, OperationStats> getPerformanceStats() {
    final Map<String, List<_PerformanceRecord>> groupedRecords = {};
    
    for (final record in _performanceHistory) {
      groupedRecords.putIfAbsent(record.operationType, () => []).add(record);
    }

    final Map<String, OperationStats> stats = {};
    
    for (final entry in groupedRecords.entries) {
      final records = entry.value;
      final durations = records.map((r) => r.duration.inMilliseconds).toList();
      final successCount = records.where((r) => r.success).length;
      
      durations.sort();
      
      stats[entry.key] = OperationStats(
        operationType: entry.key,
        totalOperations: records.length,
        successfulOperations: successCount,
        failedOperations: records.length - successCount,
        successRate: records.isNotEmpty ? (successCount / records.length) * 100 : 0.0,
        averageDurationMs: durations.isNotEmpty 
            ? durations.reduce((a, b) => a + b) / durations.length 
            : 0.0,
        minDurationMs: durations.isNotEmpty ? durations.first.toDouble() : 0.0,
        maxDurationMs: durations.isNotEmpty ? durations.last.toDouble() : 0.0,
        medianDurationMs: durations.isNotEmpty 
            ? durations[durations.length ~/ 2].toDouble() 
            : 0.0,
        p95DurationMs: durations.isNotEmpty 
            ? durations[(durations.length * 0.95).floor()].toDouble() 
            : 0.0,
        lastOperationTime: records.isNotEmpty 
            ? records.last.endTime 
            : null,
      );
    }

    return stats;
  }

  /// Obtener estadísticas específicas para conversiones
  static ConversionStats getConversionStats() {
    final conversionRecords = _performanceHistory.where((record) => 
      record.operationType.contains('conversion') || 
      record.operationType.contains('migrate') ||
      record.operationType.contains('cloud_to_local') ||
      record.operationType.contains('local_to_cloud')
    ).toList();

    if (conversionRecords.isEmpty) {
      return ConversionStats.empty();
    }

    final cloudToLocalRecords = conversionRecords.where((r) => 
      r.operationType.contains('cloud_to_local')).toList();
    final localToCloudRecords = conversionRecords.where((r) => 
      r.operationType.contains('local_to_cloud')).toList();

    return ConversionStats(
      totalConversions: conversionRecords.length,
      cloudToLocalConversions: cloudToLocalRecords.length,
      localToCloudConversions: localToCloudRecords.length,
      averageCloudToLocalMs: _calculateAverageDuration(cloudToLocalRecords),
      averageLocalToCloudMs: _calculateAverageDuration(localToCloudRecords),
      totalConversionTimeMs: conversionRecords.fold(0.0, (sum, record) => 
        sum + record.duration.inMilliseconds),
      lastConversionTime: conversionRecords.isNotEmpty 
          ? conversionRecords.last.endTime 
          : null,
    );
  }

  /// Obtener estadísticas específicas para sincronización
  static SyncStats getSyncStats() {
    final syncRecords = _performanceHistory.where((record) => 
      record.operationType.contains('sync') || 
      record.operationType.contains('migration')
    ).toList();

    if (syncRecords.isEmpty) {
      return SyncStats.empty();
    }

    final successfulSyncs = syncRecords.where((r) => r.success).length;
    final totalRecordsSynced = syncRecords.fold(0, (sum, record) {
      final recordCount = record.metadata['recordCount'] as int? ?? 0;
      return sum + recordCount;
    });

    return SyncStats(
      totalSyncs: syncRecords.length,
      successfulSyncs: successfulSyncs,
      failedSyncs: syncRecords.length - successfulSyncs,
      totalRecordsSynced: totalRecordsSynced,
      averageSyncTimeMs: _calculateAverageDuration(syncRecords),
      averageRecordsPerSync: syncRecords.isNotEmpty 
          ? totalRecordsSynced / syncRecords.length 
          : 0.0,
      lastSyncTime: syncRecords.isNotEmpty 
          ? syncRecords.last.endTime 
          : null,
    );
  }

  /// Obtener registros de performance recientes
  static List<PerformanceRecord> getRecentPerformanceRecords({int limit = 20}) {
    final records = _performanceHistory.reversed.take(limit).toList();
    return records.map((r) => PerformanceRecord(
      operationId: r.operationId,
      operationType: r.operationType,
      startTime: r.startTime,
      endTime: r.endTime,
      duration: r.duration,
      success: r.success,
      errorMessage: r.errorMessage,
      metadata: Map<String, dynamic>.from(r.metadata),
    )).toList();
  }

  /// Obtener operaciones activas (que aún no han terminado)
  static List<ActiveOperation> getActiveOperations() {
    return _activeOperations.values.map((op) => ActiveOperation(
      operationId: op.id,
      operationType: op.type,
      startTime: op.startTime,
      elapsed: DateTime.now().difference(op.startTime),
      metadata: Map<String, dynamic>.from(op.metadata),
    )).toList();
  }

  /// Detectar operaciones lentas
  static List<SlowOperation> detectSlowOperations({
    Duration threshold = const Duration(seconds: 5),
    int limit = 10,
  }) {
    final slowRecords = _performanceHistory
        .where((record) => record.duration > threshold)
        .toList()
      ..sort((a, b) => b.duration.compareTo(a.duration));

    return slowRecords.take(limit).map((record) => SlowOperation(
      operationType: record.operationType,
      duration: record.duration,
      operationTime: record.endTime,
      metadata: Map<String, dynamic>.from(record.metadata),
      errorMessage: record.errorMessage,
    )).toList();
  }

  /// Limpiar historial de performance
  static void clearHistory() {
    _performanceHistory.clear();
    developer.log('Historial de performance limpiado', name: _tag);
  }

  /// Exportar estadísticas para análisis
  static Map<String, dynamic> exportStats() {
    final stats = getPerformanceStats();
    final conversionStats = getConversionStats();
    final syncStats = getSyncStats();
    final activeOps = getActiveOperations();
    final slowOps = detectSlowOperations();

    return {
      'timestamp': DateTime.now().toIso8601String(),
      'performanceStats': stats.map((key, value) => MapEntry(key, value.toMap())),
      'conversionStats': conversionStats.toMap(),
      'syncStats': syncStats.toMap(),
      'activeOperations': activeOps.map((op) => op.toMap()).toList(),
      'slowOperations': slowOps.map((op) => op.toMap()).toList(),
      'totalHistoryRecords': _performanceHistory.length,
      'historyPeriod': _performanceHistory.isNotEmpty 
          ? {
              'earliest': _performanceHistory.first.startTime.toIso8601String(),
              'latest': _performanceHistory.last.endTime.toIso8601String(),
            }
          : null,
    };
  }

  // Métodos privados
  static void _addToHistory(_PerformanceRecord record) {
    _performanceHistory.add(record);
    
    // Mantener solo los últimos N registros
    if (_performanceHistory.length > _maxHistorySize) {
      _performanceHistory.removeRange(0, _performanceHistory.length - _maxHistorySize);
    }
  }

  static void _logPerformanceRecord(_PerformanceRecord record) {
    final status = record.success ? 'EXITOSA' : 'FALLIDA';
    
    FrapConversionLogger.logPerformanceMetrics(
      record.operationType,
      record.duration,
      {
        'status': status,
        'operationId': record.operationId,
        ...record.metadata,
      },
    );
  }

  static double _calculateAverageDuration(List<_PerformanceRecord> records) {
    if (records.isEmpty) return 0.0;
    
    final totalMs = records.fold(0, (sum, record) => sum + record.duration.inMilliseconds);
    return totalMs / records.length;
  }
}

// Clases de datos para métricas
class _OperationMetrics {
  final String id;
  final String type;
  final DateTime startTime;
  final Map<String, dynamic> metadata;

  _OperationMetrics({
    required this.id,
    required this.type,
    required this.startTime,
    required this.metadata,
  });
}

class _PerformanceRecord {
  final String operationId;
  final String operationType;
  final DateTime startTime;
  final DateTime endTime;
  final Duration duration;
  final bool success;
  final String? errorMessage;
  final Map<String, dynamic> metadata;

  _PerformanceRecord({
    required this.operationId,
    required this.operationType,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.success,
    this.errorMessage,
    required this.metadata,
  });
}

// Clases públicas para estadísticas
class OperationStats {
  final String operationType;
  final int totalOperations;
  final int successfulOperations;
  final int failedOperations;
  final double successRate;
  final double averageDurationMs;
  final double minDurationMs;
  final double maxDurationMs;
  final double medianDurationMs;
  final double p95DurationMs;
  final DateTime? lastOperationTime;

  OperationStats({
    required this.operationType,
    required this.totalOperations,
    required this.successfulOperations,
    required this.failedOperations,
    required this.successRate,
    required this.averageDurationMs,
    required this.minDurationMs,
    required this.maxDurationMs,
    required this.medianDurationMs,
    required this.p95DurationMs,
    this.lastOperationTime,
  });

  Map<String, dynamic> toMap() => {
    'operationType': operationType,
    'totalOperations': totalOperations,
    'successfulOperations': successfulOperations,
    'failedOperations': failedOperations,
    'successRate': successRate,
    'averageDurationMs': averageDurationMs,
    'minDurationMs': minDurationMs,
    'maxDurationMs': maxDurationMs,
    'medianDurationMs': medianDurationMs,
    'p95DurationMs': p95DurationMs,
    'lastOperationTime': lastOperationTime?.toIso8601String(),
  };
}

class ConversionStats {
  final int totalConversions;
  final int cloudToLocalConversions;
  final int localToCloudConversions;
  final double averageCloudToLocalMs;
  final double averageLocalToCloudMs;
  final double totalConversionTimeMs;
  final DateTime? lastConversionTime;

  ConversionStats({
    required this.totalConversions,
    required this.cloudToLocalConversions,
    required this.localToCloudConversions,
    required this.averageCloudToLocalMs,
    required this.averageLocalToCloudMs,
    required this.totalConversionTimeMs,
    this.lastConversionTime,
  });

  factory ConversionStats.empty() => ConversionStats(
    totalConversions: 0,
    cloudToLocalConversions: 0,
    localToCloudConversions: 0,
    averageCloudToLocalMs: 0.0,
    averageLocalToCloudMs: 0.0,
    totalConversionTimeMs: 0.0,
  );

  Map<String, dynamic> toMap() => {
    'totalConversions': totalConversions,
    'cloudToLocalConversions': cloudToLocalConversions,
    'localToCloudConversions': localToCloudConversions,
    'averageCloudToLocalMs': averageCloudToLocalMs,
    'averageLocalToCloudMs': averageLocalToCloudMs,
    'totalConversionTimeMs': totalConversionTimeMs,
    'lastConversionTime': lastConversionTime?.toIso8601String(),
  };
}

class SyncStats {
  final int totalSyncs;
  final int successfulSyncs;
  final int failedSyncs;
  final int totalRecordsSynced;
  final double averageSyncTimeMs;
  final double averageRecordsPerSync;
  final DateTime? lastSyncTime;

  SyncStats({
    required this.totalSyncs,
    required this.successfulSyncs,
    required this.failedSyncs,
    required this.totalRecordsSynced,
    required this.averageSyncTimeMs,
    required this.averageRecordsPerSync,
    this.lastSyncTime,
  });

  factory SyncStats.empty() => SyncStats(
    totalSyncs: 0,
    successfulSyncs: 0,
    failedSyncs: 0,
    totalRecordsSynced: 0,
    averageSyncTimeMs: 0.0,
    averageRecordsPerSync: 0.0,
  );

  Map<String, dynamic> toMap() => {
    'totalSyncs': totalSyncs,
    'successfulSyncs': successfulSyncs,
    'failedSyncs': failedSyncs,
    'totalRecordsSynced': totalRecordsSynced,
    'averageSyncTimeMs': averageSyncTimeMs,
    'averageRecordsPerSync': averageRecordsPerSync,
    'lastSyncTime': lastSyncTime?.toIso8601String(),
  };
}

class PerformanceRecord {
  final String operationId;
  final String operationType;
  final DateTime startTime;
  final DateTime endTime;
  final Duration duration;
  final bool success;
  final String? errorMessage;
  final Map<String, dynamic> metadata;

  PerformanceRecord({
    required this.operationId,
    required this.operationType,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.success,
    this.errorMessage,
    required this.metadata,
  });
}

class ActiveOperation {
  final String operationId;
  final String operationType;
  final DateTime startTime;
  final Duration elapsed;
  final Map<String, dynamic> metadata;

  ActiveOperation({
    required this.operationId,
    required this.operationType,
    required this.startTime,
    required this.elapsed,
    required this.metadata,
  });

  Map<String, dynamic> toMap() => {
    'operationId': operationId,
    'operationType': operationType,
    'startTime': startTime.toIso8601String(),
    'elapsedMs': elapsed.inMilliseconds,
    'metadata': metadata,
  };
}

class SlowOperation {
  final String operationType;
  final Duration duration;
  final DateTime operationTime;
  final Map<String, dynamic> metadata;
  final String? errorMessage;

  SlowOperation({
    required this.operationType,
    required this.duration,
    required this.operationTime,
    required this.metadata,
    this.errorMessage,
  });

  Map<String, dynamic> toMap() => {
    'operationType': operationType,
    'durationMs': duration.inMilliseconds,
    'operationTime': operationTime.toIso8601String(),
    'metadata': metadata,
    'errorMessage': errorMessage,
  };
} 