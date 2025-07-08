import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bg_med/core/models/frap_firestore.dart';
import 'package:bg_med/core/services/frap_firestore_service.dart';
import 'package:bg_med/features/frap/presentation/providers/frap_data_provider.dart';

// Provider del servicio de Firestore
final frapFirestoreServiceProvider = Provider<FrapFirestoreService>((ref) {
  return FrapFirestoreService();
});

// Estado para la lista de registros FRAP
class FrapFirestoreState {
  final List<FrapFirestore> records;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? statistics;

  const FrapFirestoreState({
    this.records = const [],
    this.isLoading = false,
    this.error,
    this.statistics,
  });

  FrapFirestoreState copyWith({
    List<FrapFirestore>? records,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? statistics,
  }) {
    return FrapFirestoreState(
      records: records ?? this.records,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      statistics: statistics ?? this.statistics,
    );
  }
}

// Notifier para manejar el estado de los registros FRAP
class FrapFirestoreNotifier extends StateNotifier<FrapFirestoreState> {
  final FrapFirestoreService _service;

  FrapFirestoreNotifier(this._service) : super(const FrapFirestoreState());

  // Cargar todos los registros FRAP
  Future<void> loadFrapRecords() async {
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

  // Crear un nuevo registro FRAP
  Future<String?> createFrapRecord(FrapData frapData) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final recordId = await _service.createFrapRecord(frapData: frapData);
      
      // Recargar la lista después de crear
      await loadFrapRecords();
      
      return recordId;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  // Actualizar un registro FRAP existente
  Future<bool> updateFrapRecord(String frapId, FrapData frapData) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _service.updateFrapRecord(frapId: frapId, frapData: frapData);
      
      // Recargar la lista después de actualizar
      await loadFrapRecords();
      
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Actualizar una sección específica de un registro FRAP
  Future<bool> updateFrapSection({
    required String frapId,
    required String sectionName,
    required Map<String, dynamic> sectionData,
  }) async {
    try {
      await _service.updateFrapSection(
        frapId: frapId,
        sectionName: sectionName,
        sectionData: sectionData,
      );
      
      // Actualizar el registro en el estado local
      final updatedRecords = state.records.map((record) {
        if (record.id == frapId) {
          final updatedRecord = record.copyWith(
            updatedAt: DateTime.now(),
          );
          
          // Actualizar la sección específica
          switch (sectionName) {
            case 'serviceInfo':
              return updatedRecord.copyWith(serviceInfo: sectionData);
            case 'registryInfo':
              return updatedRecord.copyWith(registryInfo: sectionData);
            case 'patientInfo':
              return updatedRecord.copyWith(patientInfo: sectionData);
            case 'management':
              return updatedRecord.copyWith(management: sectionData);
            case 'medications':
              return updatedRecord.copyWith(medications: sectionData);
            case 'gynecoObstetric':
              return updatedRecord.copyWith(gynecoObstetric: sectionData);
            case 'attentionNegative':
              return updatedRecord.copyWith(attentionNegative: sectionData);
            case 'pathologicalHistory':
              return updatedRecord.copyWith(pathologicalHistory: sectionData);
            case 'clinicalHistory':
              return updatedRecord.copyWith(clinicalHistory: sectionData);
            case 'physicalExam':
              return updatedRecord.copyWith(physicalExam: sectionData);
            case 'priorityJustification':
              return updatedRecord.copyWith(priorityJustification: sectionData);
            case 'injuryLocation':
              return updatedRecord.copyWith(injuryLocation: sectionData);
            case 'receivingUnit':
              return updatedRecord.copyWith(receivingUnit: sectionData);
            case 'patientReception':
              return updatedRecord.copyWith(patientReception: sectionData);
            default:
              return updatedRecord;
          }
        }
        return record;
      }).toList();
      
      state = state.copyWith(records: updatedRecords);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  // Eliminar un registro FRAP
  Future<bool> deleteFrapRecord(String frapId) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _service.deleteFrapRecord(frapId);
      
      // Remover el registro del estado local
      final updatedRecords = state.records.where((record) => record.id != frapId).toList();
      state = state.copyWith(
        records: updatedRecords,
        isLoading: false,
        error: null,
      );
      
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Duplicar un registro FRAP
  Future<String?> duplicateFrapRecord(String frapId) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final newRecordId = await _service.duplicateFrapRecord(frapId);
      
      // Recargar la lista después de duplicar
      await loadFrapRecords();
      
      return newRecordId;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  // Buscar registros por nombre de paciente
  Future<void> searchFrapRecords(String patientName) async {
    if (patientName.isEmpty) {
      await loadFrapRecords();
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

  // Obtener registros por rango de fechas
  Future<void> getFrapRecordsByDateRange(DateTime startDate, DateTime endDate) async {
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

  // Cargar estadísticas
  Future<void> loadStatistics() async {
    try {
      final statistics = await _service.getFrapStatistics();
      state = state.copyWith(statistics: statistics);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Sincronizar con registros locales
  Future<void> syncWithLocalRecords() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _service.syncLocalRecordsToCloud();
      await loadFrapRecords();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Crear backup
  Future<List<Map<String, dynamic>>?> createBackup() async {
    try {
      return await _service.backupFrapRecords();
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  // Restaurar desde backup
  Future<bool> restoreFromBackup(List<Map<String, dynamic>> backupData) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _service.restoreFrapRecords(backupData: backupData);
      await loadFrapRecords();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Limpiar error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Obtener un registro específico por ID
  FrapFirestore? getFrapRecordById(String frapId) {
    try {
      return state.records.firstWhere((record) => record.id == frapId);
    } catch (e) {
      return null;
    }
  }

  // Filtrar registros por criterios
  List<FrapFirestore> filterRecords({
    String? patientName,
    DateTime? startDate,
    DateTime? endDate,
    bool? isComplete,
    double? minCompletionPercentage,
  }) {
    var filteredRecords = state.records;

    if (patientName != null && patientName.isNotEmpty) {
      filteredRecords = filteredRecords.where((record) {
        return record.patientName.toLowerCase().contains(patientName.toLowerCase());
      }).toList();
    }

    if (startDate != null) {
      filteredRecords = filteredRecords.where((record) {
        return record.createdAt.isAfter(startDate) || record.createdAt.isAtSameMomentAs(startDate);
      }).toList();
    }

    if (endDate != null) {
      filteredRecords = filteredRecords.where((record) {
        return record.createdAt.isBefore(endDate) || record.createdAt.isAtSameMomentAs(endDate);
      }).toList();
    }

    if (isComplete != null) {
      filteredRecords = filteredRecords.where((record) {
        return record.isComplete == isComplete;
      }).toList();
    }

    if (minCompletionPercentage != null) {
      filteredRecords = filteredRecords.where((record) {
        return record.completionPercentage >= minCompletionPercentage;
      }).toList();
    }

    return filteredRecords;
  }

  // Ordenar registros
  List<FrapFirestore> sortRecords({
    required List<FrapFirestore> records,
    required String sortBy,
    bool ascending = true,
  }) {
    var sortedRecords = List<FrapFirestore>.from(records);

    switch (sortBy) {
      case 'createdAt':
        sortedRecords.sort((a, b) => ascending 
          ? a.createdAt.compareTo(b.createdAt)
          : b.createdAt.compareTo(a.createdAt));
        break;
      case 'updatedAt':
        sortedRecords.sort((a, b) => ascending 
          ? a.updatedAt.compareTo(b.updatedAt)
          : b.updatedAt.compareTo(a.updatedAt));
        break;
      case 'patientName':
        sortedRecords.sort((a, b) => ascending 
          ? a.patientName.compareTo(b.patientName)
          : b.patientName.compareTo(a.patientName));
        break;
      case 'patientAge':
        sortedRecords.sort((a, b) => ascending 
          ? a.patientAge.compareTo(b.patientAge)
          : b.patientAge.compareTo(a.patientAge));
        break;
      case 'completionPercentage':
        sortedRecords.sort((a, b) => ascending 
          ? a.completionPercentage.compareTo(b.completionPercentage)
          : b.completionPercentage.compareTo(a.completionPercentage));
        break;
      default:
        // Por defecto ordenar por fecha de creación descendente
        sortedRecords.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return sortedRecords;
  }
}

// Provider principal para los registros FRAP
final frapFirestoreProvider = StateNotifierProvider<FrapFirestoreNotifier, FrapFirestoreState>((ref) {
  final service = ref.watch(frapFirestoreServiceProvider);
  return FrapFirestoreNotifier(service);
});

// Provider para el stream de registros FRAP en tiempo real
final frapFirestoreStreamProvider = StreamProvider<List<FrapFirestore>>((ref) {
  final service = ref.watch(frapFirestoreServiceProvider);
  return service.getFrapRecordsStream();
});

// Provider para un registro FRAP específico
final frapFirestoreRecordProvider = FutureProvider.family<FrapFirestore?, String>((ref, frapId) {
  final service = ref.watch(frapFirestoreServiceProvider);
  return service.getFrapRecord(frapId);
});

// Provider para las estadísticas de registros FRAP
final frapFirestoreStatisticsProvider = FutureProvider<Map<String, dynamic>>((ref) {
  final service = ref.watch(frapFirestoreServiceProvider);
  return service.getFrapStatistics();
});

// Provider para el stream de un registro específico
final frapFirestoreRecordStreamProvider = StreamProvider.family<FrapFirestore?, String>((ref, frapId) {
  final service = ref.watch(frapFirestoreServiceProvider);
  return service.getFrapRecordStream(frapId);
}); 