import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bg_med/core/services/auto_sync_service.dart';
import 'package:bg_med/core/services/frap_local_service.dart';
import 'package:bg_med/core/services/frap_firestore_service.dart';
import 'package:bg_med/core/services/frap_sync_service.dart';
import 'package:bg_med/features/frap/presentation/providers/frap_data_provider.dart';

// Provider para el servicio de sincronización automática
final autoSyncServiceProvider = Provider<AutoSyncService>((ref) {
  final localService = FrapLocalService();
  final cloudService = FrapFirestoreService();
  final syncService = FrapSyncService(
    localService: localService,
    cloudService: cloudService,
  );

  return AutoSyncService(
    localService: localService,
    cloudService: cloudService,
    syncService: syncService,
  );
});

// Estado para el provider de sincronización automática
class AutoSyncState {
  final bool isOnline;
  final bool isSyncing;
  final String? lastSyncMessage;
  final DateTime? lastSyncTime;
  final bool isInitialized;

  const AutoSyncState({
    this.isOnline = false,
    this.isSyncing = false,
    this.lastSyncMessage,
    this.lastSyncTime,
    this.isInitialized = false,
  });

  AutoSyncState copyWith({
    bool? isOnline,
    bool? isSyncing,
    String? lastSyncMessage,
    DateTime? lastSyncTime,
    bool? isInitialized,
  }) {
    return AutoSyncState(
      isOnline: isOnline ?? this.isOnline,
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncMessage: lastSyncMessage ?? this.lastSyncMessage,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

// Notifier para manejar el estado de sincronización automática
class AutoSyncNotifier extends StateNotifier<AutoSyncState> {
  final AutoSyncService _autoSyncService;

  AutoSyncNotifier(this._autoSyncService) : super(const AutoSyncState());

  // Inicializar el servicio de sincronización automática
  Future<void> initialize() async {
    if (state.isInitialized) return;

    try {
      await _autoSyncService.initialize();
      state = state.copyWith(
        isInitialized: true,
        isOnline: _autoSyncService.isOnline,
      );
    } catch (e) {
      state = state.copyWith(
        lastSyncMessage: 'Error al inicializar sincronización: $e',
      );
    }
  }

  // Guardar registro usando sincronización automática
  Future<SaveResult> saveRecord(FrapData frapData) async {
    state = state.copyWith(isSyncing: true);

    try {
      final result = await _autoSyncService.saveRecord(frapData);

      state = state.copyWith(
        isSyncing: false,
        isOnline: _autoSyncService.isOnline,
        lastSyncMessage: result.message,
        lastSyncTime: DateTime.now(),
      );

      return result;
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        lastSyncMessage: 'Error al guardar: $e',
      );

      return SaveResult()
        ..success = false
        ..message = 'Error al guardar: $e';
    }
  }

  // Forzar sincronización manual
  Future<void> forceSyncNow() async {
    if (state.isSyncing) return;

    state = state.copyWith(isSyncing: true);

    try {
      final result = await _autoSyncService.forceSyncNow();

      state = state.copyWith(
        isSyncing: false,
        isOnline: _autoSyncService.isOnline,
        lastSyncMessage: result.message,
        lastSyncTime: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        lastSyncMessage: 'Error en sincronización: $e',
      );
    }
  }

  // Actualizar estado de conectividad
  void updateConnectivityStatus() {
    state = state.copyWith(
      isOnline: _autoSyncService.isOnline,
      isSyncing: _autoSyncService.isSyncing,
    );
  }

  @override
  void dispose() {
    _autoSyncService.dispose();
    super.dispose();
  }
}

// Provider para el notifier de sincronización automática
final autoSyncProvider = StateNotifierProvider<AutoSyncNotifier, AutoSyncState>(
  (ref) {
    final service = ref.watch(autoSyncServiceProvider);
    return AutoSyncNotifier(service);
  },
);

// Provider para obtener estadísticas de sincronización
final syncStatsProvider = FutureProvider<SyncStats>((ref) async {
  final service = ref.watch(autoSyncServiceProvider);
  return await service.getSyncStats();
});
