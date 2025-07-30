import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bg_med/core/models/frap.dart';
import 'package:bg_med/core/models/frap_firestore.dart';
import 'package:bg_med/features/frap/presentation/providers/frap_local_provider.dart';
import 'package:bg_med/features/frap/presentation/providers/frap_firestore_provider.dart';
import 'package:bg_med/core/services/frap_cleanup_service.dart';
import 'package:bg_med/core/services/data_cleanup_service.dart';
import 'package:intl/intl.dart'; // Added for DateFormat
import 'package:bg_med/core/services/frap_unified_service.dart';
import 'package:bg_med/features/frap/presentation/providers/frap_data_provider.dart';
import 'package:bg_med/core/services/frap_local_service.dart';
import 'package:bg_med/core/services/frap_firestore_service.dart';

// Estados de sincronización
enum SyncStatus {
  notSynced,    // Solo local
  synced,       // Solo nube
  duplicate,    // Existe en ambos
  conflict      // Diferentes versiones
}

// Modelo unificado para representar registros FRAP de cualquier fuente
// Usar la definición del servicio unificado en lugar de duplicar

// Estado unificado para registros FRAP
class UnifiedFrapState {
  final List<UnifiedFrapRecord> records;
  final bool isLoadingLocal;
  final bool isLoadingCloud;
  final String? errorLocal;
  final String? errorCloud;
  final Map<String, dynamic>? statistics;
  
  // Información de duplicados
  final int duplicateCount;
  final int localDuplicatesCount;
  final Map<String, dynamic>? cleanupStatistics;

  const UnifiedFrapState({
    this.records = const [],
    this.isLoadingLocal = false,
    this.isLoadingCloud = false,
    this.errorLocal,
    this.errorCloud,
    this.statistics,
    this.duplicateCount = 0,
    this.localDuplicatesCount = 0,
    this.cleanupStatistics,
  });

  bool get isLoading => isLoadingLocal || isLoadingCloud;
  String? get error => errorLocal ?? errorCloud;

  UnifiedFrapState copyWith({
    List<UnifiedFrapRecord>? records,
    bool? isLoadingLocal,
    bool? isLoadingCloud,
    String? errorLocal,
    String? errorCloud,
    Map<String, dynamic>? statistics,
    int? duplicateCount,
    int? localDuplicatesCount,
    Map<String, dynamic>? cleanupStatistics,
  }) {
    return UnifiedFrapState(
      records: records ?? this.records,
      isLoadingLocal: isLoadingLocal ?? this.isLoadingLocal,
      isLoadingCloud: isLoadingCloud ?? this.isLoadingCloud,
      errorLocal: errorLocal,
      errorCloud: errorCloud,
      statistics: statistics ?? this.statistics,
      duplicateCount: duplicateCount ?? this.duplicateCount,
      localDuplicatesCount: localDuplicatesCount ?? this.localDuplicatesCount,
      cleanupStatistics: cleanupStatistics ?? this.cleanupStatistics,
    );
  }
}

// Notifier para manejar el estado unificado
class UnifiedFrapNotifier extends StateNotifier<UnifiedFrapState> {
  final FrapLocalNotifier _localNotifier;
  final FrapFirestoreNotifier _cloudNotifier;
  final FrapCleanupService _cleanupService = FrapCleanupService(
    dataCleanupService: DataCleanupService(
      localService: FrapLocalService(),
      cloudService: FrapFirestoreService(),
    ),
    localService: FrapLocalService(),
    cloudService: FrapFirestoreService(),
  );
  bool _isUpdating = false; // Flag para evitar actualizaciones múltiples

  UnifiedFrapNotifier(this._localNotifier, this._cloudNotifier) : super(const UnifiedFrapState()) {
    // Cargar datos iniciales
    loadAllRecords();
  }

  // Cargar todos los registros (locales y de la nube)
  Future<void> loadAllRecords() async {
    if (_isUpdating) return; // Evitar múltiples cargas simultáneas
    _isUpdating = true;

    state = state.copyWith(
      isLoadingLocal: true,
      isLoadingCloud: true,
      errorLocal: null,
      errorCloud: null,
    );

    try {
      // Cargar registros locales y de la nube en paralelo
      await Future.wait([
        _loadLocalRecords(),
        _loadCloudRecords(),
      ]);

      _combineRecords();
    } finally {
      _isUpdating = false;
    }
  }

  Future<void> _loadLocalRecords() async {
    try {
      await _localNotifier.loadLocalFrapRecords();
      state = state.copyWith(isLoadingLocal: false, errorLocal: null);
    } catch (e) {
      state = state.copyWith(isLoadingLocal: false, errorLocal: e.toString());
    }
  }

  Future<void> _loadCloudRecords() async {
    try {
      await _cloudNotifier.loadFrapRecords();
      state = state.copyWith(isLoadingCloud: false, errorCloud: null);
    } catch (e) {
      state = state.copyWith(isLoadingCloud: false, errorCloud: e.toString());
    }
  }

  void _combineRecords() {
    final localRecords = _localNotifier.state.records
        .map((frap) => UnifiedFrapRecord.fromLocal(frap))
        .toList();

    final cloudRecords = _cloudNotifier.state.records
        .map((frap) => UnifiedFrapRecord.fromCloud(frap))
        .toList();

    // Crear mapa de registros únicos, priorizando registros de la nube
    final Map<String, UnifiedFrapRecord> uniqueRecords = {};
    final List<String> duplicateLocalIds = [];
    
    // Primero agregar todos los registros de la nube
    for (final cloudRecord in cloudRecords) {
      uniqueRecords['cloud_${cloudRecord.cloudRecord?.id ?? DateTime.now().millisecondsSinceEpoch}'] = cloudRecord;
    }
    
    // Luego procesar registros locales
    for (final localRecord in localRecords) {
      bool isDuplicate = false;
      
      // Verificar si es duplicado comparando con registros de la nube
      for (final cloudRecord in cloudRecords) {
        if (_areRecordsEquivalent(localRecord, cloudRecord)) {
          isDuplicate = true;
          duplicateLocalIds.add(localRecord.localRecord?.id ?? '');
          break;
        }
      }
      
      if (!isDuplicate) {
        uniqueRecords['local_${localRecord.localRecord?.id ?? DateTime.now().millisecondsSinceEpoch}'] = localRecord;
      }
    }
    
    final allRecords = uniqueRecords.values.toList();
    
    // Ordenar por fecha de creación descendente
    allRecords.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    state = state.copyWith(records: allRecords);
    _updateStatistics();
    
    // Debug en desarrollo
    if (localRecords.isNotEmpty || cloudRecords.isNotEmpty) {
      debugRecordUnification();
      
      // Mostrar información de duplicados detectados
      if (duplicateLocalIds.isNotEmpty) {
        print('=== DUPLICADOS DETECTADOS ===');
        print('Total de duplicados: ${duplicateLocalIds.length}');
        print('Registros locales marcados para eliminación: ${duplicateLocalIds.length}');
        print('=== FIN DUPLICADOS ===\n');
      }
    }
  }

  bool _areRecordsEquivalent(UnifiedFrapRecord local, UnifiedFrapRecord cloud) {
    // Comparar por datos del paciente y fecha de creación
    final localPatientName = local.patientName;
    final cloudPatientName = cloud.patientName;
    
    return localPatientName.toLowerCase() == cloudPatientName.toLowerCase() &&
           local.createdAt.difference(cloud.createdAt).abs().inMinutes < 5;
  }

  void _updateStatistics() {
    final totalRecords = state.records.length;
    final localCount = state.records.where((r) => r.isLocal).length;
    final cloudCount = state.records.where((r) => !r.isLocal).length;
    final duplicateCount = 0; // Ya no tenemos esta propiedad
    final localDuplicatesCount = 0; // Ya no tenemos esta propiedad
    
    final unifiedStats = {
      'total': totalRecords,
      'local': localCount,
      'cloud': cloudCount,
      'today': _getTodayCount(),
      'thisWeek': _getWeekCount(),
      'thisMonth': _getMonthCount(),
      'averageCompletion': _getAverageCompletion(),
      'localOnlyCount': localCount, // Registros que solo existen localmente
      'cloudOnlyCount': cloudCount, // Registros que solo existen en la nube
      'syncedCount': totalRecords, // Registros sincronizados
      'duplicateCount': duplicateCount,
      'localDuplicatesCount': localDuplicatesCount,
    };

    state = state.copyWith(
      statistics: unifiedStats,
      duplicateCount: duplicateCount,
      localDuplicatesCount: localDuplicatesCount,
    );
  }

  int _getTodayCount() {
    final today = DateTime.now();
    return state.records.where((record) {
      final recordDate = record.createdAt;
      return recordDate.day == today.day &&
             recordDate.month == today.month &&
             recordDate.year == today.year;
    }).length;
  }

  int _getWeekCount() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    
    return state.records.where((record) {
      return record.createdAt.isAfter(weekStart) &&
             record.createdAt.isBefore(weekEnd.add(const Duration(days: 1)));
    }).length;
  }

  int _getMonthCount() {
    final now = DateTime.now();
    return state.records.where((record) {
      return record.createdAt.month == now.month &&
             record.createdAt.year == now.year;
    }).length;
  }

  double _getAverageCompletion() {
    if (state.records.isEmpty) return 0.0;
    // Calcular un promedio simple basado en si el registro tiene datos
    double total = 0.0;
    for (final record in state.records) {
      final info = record.getDetailedInfo();
      if (info.isNotEmpty) {
        total += 1.0;
      }
    }
    return total / state.records.length;
  }

  // Buscar registros por nombre de paciente
  Future<void> searchRecords(String patientName) async {
    if (patientName.isEmpty) {
      await loadAllRecords();
      return;
    }

    if (_isUpdating) return;
    _isUpdating = true;

    try {
      // Buscar en ambas fuentes
      await Future.wait([
        _localNotifier.searchLocalFrapRecords(patientName),
        _cloudNotifier.searchFrapRecords(patientName),
      ]);

      _combineRecords();
    } finally {
      _isUpdating = false;
    }
  }

  // Filtrar registros por rango de fechas
  Future<void> filterByDateRange(DateTime startDate, DateTime endDate) async {
    if (_isUpdating) return;
    _isUpdating = true;

    try {
      await Future.wait([
        _localNotifier.getLocalFrapRecordsByDateRange(startDate, endDate),
        _cloudNotifier.getFrapRecordsByDateRange(startDate, endDate),
      ]);

      _combineRecords();
    } finally {
      _isUpdating = false;
    }
  }

  // Eliminar un registro
  Future<bool> deleteRecord(UnifiedFrapRecord record) async {
    bool success;
    if (record.isLocal) {
      success = await _localNotifier.deleteLocalFrapRecord(record.id);
    } else {
      success = await _cloudNotifier.deleteFrapRecord(record.id);
    }
    
    if (success) {
      // Actualizar la lista local sin recargar todo
      final updatedRecords = state.records.where((r) => r.id != record.id).toList();
      state = state.copyWith(records: updatedRecords);
      _updateStatistics();
    }
    
    return success;
  }

  // Duplicar un registro
  Future<String?> duplicateRecord(UnifiedFrapRecord record) async {
    String? newRecordId;
    if (record.isLocal) {
      newRecordId = await _localNotifier.duplicateLocalFrapRecord(record.id);
    } else {
      newRecordId = await _cloudNotifier.duplicateFrapRecord(record.id);
    }
    
    if (newRecordId != null) {
      // Recargar solo los datos necesarios
      await loadAllRecords();
    }
    
    return newRecordId;
  }

  // Sincronizar registros locales a la nube
  Future<void> syncLocalToCloud() async {
    try {
      await _cloudNotifier.syncWithLocalRecords();
      await loadAllRecords();
    } catch (e) {
      state = state.copyWith(errorCloud: e.toString());
    }
  }

  // Limpiar errores
  void clearErrors() {
    state = state.copyWith(errorLocal: null, errorCloud: null);
  }

  // Método de debug para entender la unificación de registros
  void debugRecordUnification() {
    final localRecords = _localNotifier.state.records;
    final cloudRecords = _cloudNotifier.state.records;
    
    print('=== DEBUG RECORD UNIFICATION ===');
    print('Local records count: ${localRecords.length}');
    print('Cloud records count: ${cloudRecords.length}');
    print('Unified records count: ${state.records.length}');
    
    print('\nLocal records:');
    for (final record in localRecords) {
      final unified = UnifiedFrapRecord.fromLocal(record);
      print('  - ${record.patient.name} (${record.patient.age}) | Created: ${record.createdAt}');
    }
    
    print('\nCloud records:');
    for (final record in cloudRecords) {
      final unified = UnifiedFrapRecord.fromCloud(record);
      print('  - ${record.patientName} (${record.patientAge}) | Created: ${record.createdAt}');
    }
    
    print('\nUnified records:');
    for (final record in state.records) {
      print('  - ${record.patientName} | ${record.isLocal ? 'LOCAL' : 'CLOUD'} | Created: ${record.createdAt}');
    }
    print('=== END DEBUG ===\n');
  }

  // Actualizar registros cuando cambian los providers subyacentes
  void updateFromProviders(FrapLocalState localState, FrapFirestoreState cloudState) {
    if (_isUpdating) return; // Evitar actualizaciones múltiples
    
    // Solo actualizar si hay cambios reales en los datos
    bool hasLocalChanges = localState.records.length != 
        (state.records.where((r) => r.isLocal).length);
    bool hasCloudChanges = cloudState.records.length != 
        (state.records.where((r) => !r.isLocal).length);
    
    if (!hasLocalChanges && !hasCloudChanges) {
      return; // No hay cambios reales, no actualizar
    }
    
    // Actualizar estados de carga
    state = state.copyWith(
      isLoadingLocal: localState.isLoading,
      isLoadingCloud: cloudState.isLoading,
      errorLocal: localState.error,
      errorCloud: cloudState.error,
    );

    // Recombinar registros solo si no están cargando y hay cambios
    if (!localState.isLoading && !cloudState.isLoading) {
      _combineRecords();
    }
  }

  // Limpiar registros duplicados
  Future<Map<String, dynamic>> cleanupDuplicateRecords() async {
    try {
      state = state.copyWith(isLoadingLocal: true);
      
      final result = await _cleanupService.cleanupDuplicateRecordsWithConfirmation(state.records);
      
      if (result['success'] == true) {
        // Recargar registros después de la limpieza
        await loadAllRecords();
        
        state = state.copyWith(
          isLoadingLocal: false,
          errorLocal: null,
        );
      } else {
        state = state.copyWith(
          isLoadingLocal: false,
          errorLocal: result['message'],
        );
      }
      
      return result;
    } catch (e) {
      state = state.copyWith(
        isLoadingLocal: false,
        errorLocal: e.toString(),
      );
      return {
        'success': false,
        'message': 'Error durante la limpieza: $e',
        'removedCount': 0,
        'statistics': {},
      };
    }
  }

  // Sincronizar y limpiar duplicados
  Future<Map<String, dynamic>> syncAndCleanup() async {
    try {
      state = state.copyWith(
        isLoadingLocal: true,
        isLoadingCloud: true,
        errorLocal: null,
        errorCloud: null,
      );

      // 1. Sincronizar registros locales a la nube
      await _cloudNotifier.syncWithLocalRecords();
      
      // 2. Recargar todos los registros
      await loadAllRecords();
      
      // 3. Limpiar duplicados
      final cleanupResult = await cleanupDuplicateRecords();
      
      // 4. Recargar una vez más después de la limpieza
      await loadAllRecords();
      
      return {
        'success': true,
        'message': 'Sincronización y limpieza completadas',
        'syncSuccess': true,
        'cleanupResult': cleanupResult,
      };
    } catch (e) {
      state = state.copyWith(
        isLoadingLocal: false,
        isLoadingCloud: false,
        errorLocal: e.toString(),
      );
      return {
        'success': false,
        'message': 'Error durante sincronización y limpieza: $e',
        'syncSuccess': false,
        'cleanupResult': {
          'success': false,
          'message': 'No se pudo completar la limpieza',
          'removedCount': 0,
          'statistics': {},
        },
      };
    }
  }

  // Obtener estadísticas de limpieza
  Future<Map<String, dynamic>> getCleanupStatistics() async {
    try {
      return await _cleanupService.getCleanupStatistics(state.records);
    } catch (e) {
      return {
        'error': e.toString(),
        'totalLocal': 0,
        'totalCloud': 0,
        'totalDuplicates': 0,
        'localDuplicates': 0,
        'estimatedSpaceFreedKB': 0,
        'estimatedSpaceFreedMB': '0.00',
      };
    }
  }

  // Crear backup antes de limpiar
  Future<List<Map<String, dynamic>>> createBackupBeforeCleanup() async {
    try {
      return await _cleanupService.createBackupBeforeCleanup();
    } catch (e) {
      throw Exception('Error al crear backup: $e');
    }
  }
}

// Provider principal unificado
final unifiedFrapProvider = StateNotifierProvider<UnifiedFrapNotifier, UnifiedFrapState>((ref) {
  final localNotifier = ref.watch(frapLocalProvider.notifier);
  final cloudNotifier = ref.watch(frapFirestoreProvider.notifier);
  
  final unifiedNotifier = UnifiedFrapNotifier(localNotifier, cloudNotifier);
  
  // Escuchar cambios en los providers subyacentes con debounce
  ref.listen<FrapLocalState>(frapLocalProvider, (previous, next) {
    if (previous != next && !next.isLoading) {
      // Solo actualizar si el estado cambió y no está cargando
      // Aumentar debounce para evitar actualizaciones muy frecuentes
      Future.delayed(const Duration(milliseconds: 300), () {
        unifiedNotifier.updateFromProviders(next, ref.read(frapFirestoreProvider));
      });
    }
  });
  
  ref.listen<FrapFirestoreState>(frapFirestoreProvider, (previous, next) {
    if (previous != next && !next.isLoading) {
      // Solo actualizar si el estado cambió y no está cargando
      // Aumentar debounce para evitar actualizaciones muy frecuentes
      Future.delayed(const Duration(milliseconds: 300), () {
        unifiedNotifier.updateFromProviders(ref.read(frapLocalProvider), next);
      });
    }
  });
  
  return unifiedNotifier;
});

// Provider para estadísticas unificadas
final unifiedFrapStatisticsProvider = Provider<Map<String, dynamic>>((ref) {
  final state = ref.watch(unifiedFrapProvider);
  return state.statistics ?? {};
});

// Provider para obtener un registro específico por ID
final unifiedFrapRecordProvider = Provider.family<UnifiedFrapRecord?, String>((ref, recordId) {
  final state = ref.watch(unifiedFrapProvider);
  try {
    return state.records.firstWhere((record) => record.id == recordId);
  } catch (e) {
    return null;
  }
}); 

// Provider para el servicio unificado
final frapUnifiedServiceProvider = Provider<FrapUnifiedService>((ref) {
  final localService = ref.watch(frapLocalServiceProvider);
  final cloudService = ref.watch(frapFirestoreServiceProvider);
  
  return FrapUnifiedService(
    localService: localService,
    cloudService: cloudService,
  );
});

// Provider para los registros unificados
final unifiedRecordsProvider = FutureProvider<List<UnifiedFrapRecord>>((ref) async {
  final unifiedService = ref.watch(frapUnifiedServiceProvider);
  return await unifiedService.getAllRecords();
});

// Provider para guardar registros
final saveFrapRecordProvider = FutureProvider.family<UnifiedSaveResult, FrapData>((ref, frapData) async {
  final unifiedService = ref.watch(frapUnifiedServiceProvider);
  return await unifiedService.saveFrapRecord(frapData);
});

// Provider para sincronizar registros pendientes
final syncRecordsProvider = FutureProvider<SyncResult>((ref) async {
  final unifiedService = ref.watch(frapUnifiedServiceProvider);
  return await unifiedService.syncPendingRecords();
});

// Notifier para manejar el estado de los registros
class UnifiedRecordsNotifier extends StateNotifier<AsyncValue<List<UnifiedFrapRecord>>> {
  final FrapUnifiedService _unifiedService;

  UnifiedRecordsNotifier(this._unifiedService) : super(const AsyncValue.loading()) {
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    state = const AsyncValue.loading();
    try {
      final records = await _unifiedService.getAllRecords();
      state = AsyncValue.data(records);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refreshRecords() async {
    await _loadRecords();
  }

  Future<UnifiedSaveResult> saveRecord(FrapData frapData) async {
    final result = await _unifiedService.saveFrapRecord(frapData);
    
    // Recargar registros después de guardar
    await _loadRecords();
    
    return result;
  }

  Future<SyncResult> syncRecords() async {
    final result = await _unifiedService.syncPendingRecords();
    
    // Recargar registros después de sincronizar
    await _loadRecords();
    
    return result;
  }
}

final unifiedRecordsNotifierProvider = StateNotifierProvider<UnifiedRecordsNotifier, AsyncValue<List<UnifiedFrapRecord>>>((ref) {
  final unifiedService = ref.watch(frapUnifiedServiceProvider);
  return UnifiedRecordsNotifier(unifiedService);
}); 