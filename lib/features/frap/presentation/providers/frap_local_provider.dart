import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bg_med/core/services/frap_local_service.dart';
import 'package:bg_med/core/models/frap.dart';
import 'package:bg_med/features/frap/presentation/providers/frap_data_provider.dart';

// Provider para el servicio local FRAP
final frapLocalServiceProvider = Provider<FrapLocalService>((ref) {
  return FrapLocalService();
});

// Estado para el provider local FRAP
class FrapLocalState {
  final List<Frap> records;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? statistics;

  const FrapLocalState({
    this.records = const [],
    this.isLoading = false,
    this.error,
    this.statistics,
  });

  FrapLocalState copyWith({
    List<Frap>? records,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? statistics,
  }) {
    return FrapLocalState(
      records: records ?? this.records,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      statistics: statistics ?? this.statistics,
    );
  }
}

// Notifier para manejar el estado local FRAP
class FrapLocalNotifier extends StateNotifier<FrapLocalState> {
  final FrapLocalService _service;

  FrapLocalNotifier(this._service) : super(const FrapLocalState());

  // Cargar todos los registros FRAP locales
  Future<void> loadLocalFrapRecords() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final records = await _service.getAllFrapRecords();
      state = state.copyWith(
        records: records,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Crear un nuevo registro FRAP local
  Future<String?> createLocalFrapRecord(FrapData frapData) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final recordId = await _service.createFrapRecord(frapData: frapData);
      
      // Recargar la lista después de crear
      await loadLocalFrapRecords();
      
      return recordId;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  // Actualizar un registro FRAP local existente
  Future<bool> updateLocalFrapRecord(String frapId, FrapData frapData) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _service.updateFrapRecord(frapId: frapId, frapData: frapData);
      
      // Recargar la lista después de actualizar
      await loadLocalFrapRecords();
      
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Obtener un registro FRAP local específico
  Future<Frap?> getLocalFrapRecord(String frapId) async {
    try {
      return await _service.getFrapRecord(frapId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  // Eliminar un registro FRAP local
  Future<bool> deleteLocalFrapRecord(String frapId) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _service.deleteFrapRecord(frapId);
      
      // Recargar la lista después de eliminar
      await loadLocalFrapRecords();
      
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Duplicar un registro FRAP local
  Future<String?> duplicateLocalFrapRecord(String frapId) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final newRecordId = await _service.duplicateFrapRecord(frapId);
      
      // Recargar la lista después de duplicar
      await loadLocalFrapRecords();
      
      return newRecordId;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  // Buscar registros FRAP locales por nombre de paciente
  Future<void> searchLocalFrapRecords(String patientName) async {
    if (patientName.isEmpty) {
      await loadLocalFrapRecords();
      return;
    }
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final records = await _service.searchFrapRecordsByPatientName(patientName: patientName);
      state = state.copyWith(
        records: records,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Obtener registros FRAP locales por rango de fechas
  Future<void> getLocalFrapRecordsByDateRange(DateTime startDate, DateTime endDate) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final records = await _service.getFrapRecordsByDateRange(
        startDate: startDate,
        endDate: endDate,
      );
      state = state.copyWith(
        records: records,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Cargar estadísticas locales
  Future<void> loadLocalStatistics() async {
    try {
      final statistics = await _service.getFrapStatistics();
      state = state.copyWith(statistics: statistics);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Limpiar todos los registros FRAP locales
  Future<void> clearAllLocalFrapRecords() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _service.clearAllFrapRecords();
      state = state.copyWith(
        records: [],
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Crear backup de registros FRAP locales
  Future<List<Map<String, dynamic>>?> createLocalBackup() async {
    try {
      return await _service.backupFrapRecords();
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  // Restaurar registros FRAP locales desde backup
  Future<bool> restoreLocalFrapRecords(List<Map<String, dynamic>> backupData) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _service.restoreFrapRecords(backupData: backupData);
      
      // Recargar la lista después de restaurar
      await loadLocalFrapRecords();
      
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Convertir Frap a FrapData para edición
  FrapData convertFrapToFrapData(Frap frap) {
    return _service.convertFrapToFrapData(frap);
  }

  // Obtener registros no sincronizados
  Future<List<Frap>> getUnsyncedRecords() async {
    try {
      return await _service.getUnsyncedRecords();
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return [];
    }
  }

  // Limpiar errores
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider para el notifier local FRAP
final frapLocalProvider = StateNotifierProvider<FrapLocalNotifier, FrapLocalState>((ref) {
  final service = ref.watch(frapLocalServiceProvider);
  return FrapLocalNotifier(service);
});

// Provider para obtener un registro FRAP específico
final frapLocalRecordProvider = FutureProvider.family<Frap?, String>((ref, frapId) async {
  final service = ref.watch(frapLocalServiceProvider);
  return await service.getFrapRecord(frapId);
});

// Provider para las estadísticas locales
final frapLocalStatisticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.watch(frapLocalServiceProvider);
  return await service.getFrapStatistics();
});

// Provider para obtener registros no sincronizados
final unsyncedFrapRecordsProvider = FutureProvider<List<Frap>>((ref) async {
  final service = ref.watch(frapLocalServiceProvider);
  return await service.getUnsyncedRecords();
}); 