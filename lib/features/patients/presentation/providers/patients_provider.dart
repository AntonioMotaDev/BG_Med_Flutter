import 'package:bg_med/core/models/patient_firestore.dart';
import 'package:bg_med/features/patients/data/patients_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Proveedor del servicio de pacientes
final patientsServiceProvider = Provider<PatientsService>((ref) {
  return PatientsService();
});

// Proveedor del stream de pacientes en tiempo real
final patientsStreamProvider = StreamProvider<List<PatientFirestore>>((ref) {
  final service = ref.watch(patientsServiceProvider);
  return service.patientsStream;
});

// Proveedor para obtener todos los pacientes
final allPatientsProvider = FutureProvider<List<PatientFirestore>>((ref) async {
  final service = ref.watch(patientsServiceProvider);
  return await service.getAllPatients();
});

// Proveedor para obtener un paciente específico por ID
final patientByIdProvider = FutureProvider.family<PatientFirestore?, String>((ref, id) async {
  final service = ref.watch(patientsServiceProvider);
  return await service.getPatientById(id);
});

// Proveedor para estadísticas de pacientes
final patientsStatisticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.watch(patientsServiceProvider);
  return await service.getPatientsStatistics();
});

// Proveedor para pacientes recientes
final recentPatientsProvider = FutureProvider<List<PatientFirestore>>((ref) async {
  final service = ref.watch(patientsServiceProvider);
  return await service.getRecentPatients();
});

// Estados para el manejo de pacientes
enum PatientsStatus { initial, loading, success, error }

class PatientsState {
  final PatientsStatus status;
  final List<PatientFirestore> patients;
  final String? errorMessage;
  final bool isSearching;
  final String searchQuery;
  final Map<String, dynamic> filters;

  const PatientsState({
    required this.status,
    this.patients = const [],
    this.errorMessage,
    this.isSearching = false,
    this.searchQuery = '',
    this.filters = const {},
  });

  PatientsState copyWith({
    PatientsStatus? status,
    List<PatientFirestore>? patients,
    String? errorMessage,
    bool? isSearching,
    String? searchQuery,
    Map<String, dynamic>? filters,
  }) {
    return PatientsState(
      status: status ?? this.status,
      patients: patients ?? this.patients,
      errorMessage: errorMessage,
      isSearching: isSearching ?? this.isSearching,
      searchQuery: searchQuery ?? this.searchQuery,
      filters: filters ?? this.filters,
    );
  }

  @override
  String toString() {
    return 'PatientsState(status: $status, patients: ${patients.length}, isSearching: $isSearching)';
  }
}

// Notificador principal para el manejo de pacientes
final patientsNotifierProvider = StateNotifierProvider<PatientsNotifier, PatientsState>((ref) {
  final service = ref.watch(patientsServiceProvider);
  return PatientsNotifier(service);
});

class PatientsNotifier extends StateNotifier<PatientsState> {
  final PatientsService _service;

  PatientsNotifier(this._service) : super(const PatientsState(status: PatientsStatus.initial)) {
    // Cargar pacientes automáticamente al inicializar
    loadPatients();
  }

  // Cargar todos los pacientes
  Future<void> loadPatients() async {
    state = state.copyWith(status: PatientsStatus.loading);
    
    try {
      final patients = await _service.getAllPatients();
      state = state.copyWith(
        status: PatientsStatus.success,
        patients: patients,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: PatientsStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Crear un nuevo paciente
  Future<PatientFirestore?> createPatient(PatientFirestore patient) async {
    state = state.copyWith(status: PatientsStatus.loading);
    
    try {
      // Verificar duplicados
      final duplicate = await _service.findDuplicatePatient(
        firstName: patient.firstName,
        paternalLastName: patient.paternalLastName,
        maternalLastName: patient.maternalLastName,
        age: patient.age,
      );
      
      if (duplicate != null) {
        state = state.copyWith(
          status: PatientsStatus.error,
          errorMessage: 'Ya existe un paciente con los mismos datos básicos',
        );
        return null;
      }

      final newPatient = await _service.createPatient(patient);
      
      // Actualizar la lista local
      final updatedPatients = [...state.patients, newPatient];
      updatedPatients.sort((a, b) => a.firstName.compareTo(b.firstName));
      
      state = state.copyWith(
        status: PatientsStatus.success,
        patients: updatedPatients,
        errorMessage: null,
      );
      
      return newPatient;
    } catch (e) {
      state = state.copyWith(
        status: PatientsStatus.error,
        errorMessage: e.toString(),
      );
      return null;
    }
  }

  // Actualizar un paciente existente
  Future<PatientFirestore?> updatePatient(String id, PatientFirestore patient) async {
    state = state.copyWith(status: PatientsStatus.loading);
    
    try {
      final updatedPatient = await _service.updatePatient(id, patient);
      
      // Actualizar la lista local
      final updatedPatients = state.patients.map((p) {
        return p.id == id ? updatedPatient : p;
      }).toList();
      
      state = state.copyWith(
        status: PatientsStatus.success,
        patients: updatedPatients,
        errorMessage: null,
      );
      
      return updatedPatient;
    } catch (e) {
      state = state.copyWith(
        status: PatientsStatus.error,
        errorMessage: e.toString(),
      );
      return null;
    }
  }

  // Eliminar un paciente
  Future<bool> deletePatient(String id) async {
    state = state.copyWith(status: PatientsStatus.loading);
    
    try {
      await _service.deletePatient(id);
      
      // Actualizar la lista local
      final updatedPatients = state.patients.where((p) => p.id != id).toList();
      
      state = state.copyWith(
        status: PatientsStatus.success,
        patients: updatedPatients,
        errorMessage: null,
      );
      
      return true;
    } catch (e) {
      state = state.copyWith(
        status: PatientsStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  // Buscar pacientes por nombre
  Future<void> searchPatients(String query) async {
    state = state.copyWith(
      isSearching: true,
      searchQuery: query,
      status: PatientsStatus.loading,
    );
    
    try {
      final patients = await _service.searchPatientsByName(query);
      state = state.copyWith(
        status: PatientsStatus.success,
        patients: patients,
        isSearching: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: PatientsStatus.error,
        errorMessage: e.toString(),
        isSearching: false,
      );
    }
  }

  // Búsqueda avanzada
  Future<void> advancedSearch({
    String? nameQuery,
    String? gender,
    int? minAge,
    int? maxAge,
    String? city,
    String? insurance,
  }) async {
    final filters = <String, dynamic>{
      if (nameQuery != null) 'nameQuery': nameQuery,
      if (gender != null) 'gender': gender,
      if (minAge != null) 'minAge': minAge,
      if (maxAge != null) 'maxAge': maxAge,
      if (city != null) 'city': city,
      if (insurance != null) 'insurance': insurance,
    };

    state = state.copyWith(
      isSearching: true,
      filters: filters,
      status: PatientsStatus.loading,
    );
    
    try {
      final patients = await _service.advancedSearch(
        nameQuery: nameQuery,
        gender: gender,
        minAge: minAge,
        maxAge: maxAge,
        city: city,
        insurance: insurance,
      );
      
      state = state.copyWith(
        status: PatientsStatus.success,
        patients: patients,
        isSearching: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: PatientsStatus.error,
        errorMessage: e.toString(),
        isSearching: false,
      );
    }
  }

  // Filtrar por género
  Future<void> filterByGender(String gender) async {
    state = state.copyWith(status: PatientsStatus.loading);
    
    try {
      final patients = await _service.getPatientsByGender(gender);
      state = state.copyWith(
        status: PatientsStatus.success,
        patients: patients,
        filters: {'gender': gender},
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: PatientsStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Filtrar por rango de edad
  Future<void> filterByAgeRange(int minAge, int maxAge) async {
    state = state.copyWith(status: PatientsStatus.loading);
    
    try {
      final patients = await _service.getPatientsByAgeRange(minAge, maxAge);
      state = state.copyWith(
        status: PatientsStatus.success,
        patients: patients,
        filters: {'minAge': minAge, 'maxAge': maxAge},
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: PatientsStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Filtrar por ciudad
  Future<void> filterByCity(String city) async {
    state = state.copyWith(status: PatientsStatus.loading);
    
    try {
      final patients = await _service.getPatientsByCity(city);
      state = state.copyWith(
        status: PatientsStatus.success,
        patients: patients,
        filters: {'city': city},
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: PatientsStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Filtrar por seguro médico
  Future<void> filterByInsurance(String insurance) async {
    state = state.copyWith(status: PatientsStatus.loading);
    
    try {
      final patients = await _service.getPatientsByInsurance(insurance);
      state = state.copyWith(
        status: PatientsStatus.success,
        patients: patients,
        filters: {'insurance': insurance},
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: PatientsStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Limpiar filtros y búsquedas
  Future<void> clearFilters() async {
    state = state.copyWith(
      searchQuery: '',
      filters: {},
      isSearching: false,
    );
    await loadPatients();
  }

  // Refrescar datos
  Future<void> refresh() async {
    await loadPatients();
  }

  // Limpiar errores
  void clearError() {
    if (state.status == PatientsStatus.error) {
      state = state.copyWith(
        status: PatientsStatus.success,
        errorMessage: null,
      );
    }
  }
} 