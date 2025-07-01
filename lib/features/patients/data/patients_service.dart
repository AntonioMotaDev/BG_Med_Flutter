import 'package:bg_med/core/models/patient_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PatientsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'patients';

  // Stream para escuchar cambios en tiempo real
  Stream<List<PatientFirestore>> get patientsStream {
    return _firestore
        .collection(_collection)
        .orderBy('firstName')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PatientFirestore.fromFirestore(doc))
            .toList());
  }

  // Obtener todos los pacientes
  Future<List<PatientFirestore>> getAllPatients() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .orderBy('firstName')
          .get();
      
      return snapshot.docs
          .map((doc) => PatientFirestore.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error al obtener pacientes: $e');
      throw Exception('Error al obtener la lista de pacientes');
    }
  }

  // Obtener un paciente por ID
  Future<PatientFirestore?> getPatientById(String id) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection(_collection)
          .doc(id)
          .get();
      
      if (doc.exists) {
        return PatientFirestore.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error al obtener paciente: $e');
      throw Exception('Error al obtener los datos del paciente');
    }
  }

  // Crear un nuevo paciente
  Future<PatientFirestore> createPatient(PatientFirestore patient) async {
    try {
      final DocumentReference docRef = await _firestore
          .collection(_collection)
          .add(patient.toFirestore());
      
      // Obtener el documento creado para devolver el paciente con ID
      final DocumentSnapshot doc = await docRef.get();
      return PatientFirestore.fromFirestore(doc);
    } catch (e) {
      print('Error al crear paciente: $e');
      throw Exception('Error al registrar el paciente');
    }
  }

  // Actualizar un paciente existente
  Future<PatientFirestore> updatePatient(String id, PatientFirestore patient) async {
    try {
      // Actualizar updatedAt
      final updatedPatient = patient.copyWith(
        id: id,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection(_collection)
          .doc(id)
          .update(updatedPatient.toFirestore());
      
      // Obtener el documento actualizado
      final DocumentSnapshot doc = await _firestore
          .collection(_collection)
          .doc(id)
          .get();
      
      return PatientFirestore.fromFirestore(doc);
    } catch (e) {
      print('Error al actualizar paciente: $e');
      throw Exception('Error al actualizar los datos del paciente');
    }
  }

  // Eliminar un paciente
  Future<void> deletePatient(String id) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(id)
          .delete();
    } catch (e) {
      print('Error al eliminar paciente: $e');
      throw Exception('Error al eliminar el paciente');
    }
  }

  // Buscar pacientes por nombre
  Future<List<PatientFirestore>> searchPatientsByName(String query) async {
    try {
      if (query.isEmpty) {
        return await getAllPatients();
      }

      final String searchQuery = query.toLowerCase();
      final QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .get();
      
      return snapshot.docs
          .map((doc) => PatientFirestore.fromFirestore(doc))
          .where((patient) =>
              patient.firstName.toLowerCase().contains(searchQuery) ||
              patient.paternalLastName.toLowerCase().contains(searchQuery) ||
              patient.maternalLastName.toLowerCase().contains(searchQuery) ||
              patient.fullName.toLowerCase().contains(searchQuery))
          .toList()
        ..sort((a, b) => a.firstName.compareTo(b.firstName));
    } catch (e) {
      print('Error al buscar pacientes: $e');
      throw Exception('Error al buscar pacientes');
    }
  }

  // Filtrar pacientes por género
  Future<List<PatientFirestore>> getPatientsByGender(String gender) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('sex', isEqualTo: gender)
          .orderBy('firstName')
          .get();
      
      return snapshot.docs
          .map((doc) => PatientFirestore.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error al filtrar por género: $e');
      throw Exception('Error al filtrar pacientes por género');
    }
  }

  // Filtrar pacientes por edad
  Future<List<PatientFirestore>> getPatientsByAgeRange(int minAge, int maxAge) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('age', isGreaterThanOrEqualTo: minAge)
          .where('age', isLessThanOrEqualTo: maxAge)
          .orderBy('age')
          .get();
      
      return snapshot.docs
          .map((doc) => PatientFirestore.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error al filtrar por edad: $e');
      throw Exception('Error al filtrar pacientes por edad');
    }
  }

  // Filtrar pacientes por ciudad
  Future<List<PatientFirestore>> getPatientsByCity(String city) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('city', isEqualTo: city)
          .orderBy('firstName')
          .get();
      
      return snapshot.docs
          .map((doc) => PatientFirestore.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error al filtrar por ciudad: $e');
      throw Exception('Error al filtrar pacientes por ciudad');
    }
  }

  // Filtrar pacientes por seguro médico
  Future<List<PatientFirestore>> getPatientsByInsurance(String insurance) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('insurance', isEqualTo: insurance)
          .orderBy('firstName')
          .get();
      
      return snapshot.docs
          .map((doc) => PatientFirestore.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error al filtrar por seguro: $e');
      throw Exception('Error al filtrar pacientes por seguro médico');
    }
  }

  // Búsqueda avanzada con múltiples filtros
  Future<List<PatientFirestore>> advancedSearch({
    String? nameQuery,
    String? gender,
    int? minAge,
    int? maxAge,
    String? city,
    String? insurance,
  }) async {
    try {
      Query query = _firestore.collection(_collection);

      // Aplicar filtros
      if (gender != null && gender.isNotEmpty) {
        query = query.where('sex', isEqualTo: gender);
      }
      
      if (city != null && city.isNotEmpty) {
        query = query.where('city', isEqualTo: city);
      }
      
      if (insurance != null && insurance.isNotEmpty) {
        query = query.where('insurance', isEqualTo: insurance);
      }

      if (minAge != null) {
        query = query.where('age', isGreaterThanOrEqualTo: minAge);
      }
      
      if (maxAge != null) {
        query = query.where('age', isLessThanOrEqualTo: maxAge);
      }

      final QuerySnapshot snapshot = await query.get();
      List<PatientFirestore> patients = snapshot.docs
          .map((doc) => PatientFirestore.fromFirestore(doc))
          .toList();

      // Filtrar por nombre si se proporciona (Firestore no soporta búsqueda de texto completo)
      if (nameQuery != null && nameQuery.isNotEmpty) {
        final searchQuery = nameQuery.toLowerCase();
        patients = patients
            .where((patient) =>
                patient.firstName.toLowerCase().contains(searchQuery) ||
                patient.paternalLastName.toLowerCase().contains(searchQuery) ||
                patient.maternalLastName.toLowerCase().contains(searchQuery) ||
                patient.fullName.toLowerCase().contains(searchQuery))
            .toList();
      }

      // Ordenar por nombre
      patients.sort((a, b) => a.firstName.compareTo(b.firstName));
      
      return patients;
    } catch (e) {
      print('Error en búsqueda avanzada: $e');
      throw Exception('Error al realizar la búsqueda avanzada');
    }
  }

  // Obtener estadísticas de pacientes
  Future<Map<String, dynamic>> getPatientsStatistics() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .get();
      
      final List<PatientFirestore> patients = snapshot.docs
          .map((doc) => PatientFirestore.fromFirestore(doc))
          .toList();

      // Calcular estadísticas
      final int totalPatients = patients.length;
      final int malePatients = patients.where((p) => p.sex == 'Masculino').length;
      final int femalePatients = patients.where((p) => p.sex == 'Femenino').length;
      
      // Agrupar por grupos de edad
      final int children = patients.where((p) => p.age < 18).length;
      final int youngAdults = patients.where((p) => p.age >= 18 && p.age < 35).length;
      final int adults = patients.where((p) => p.age >= 35 && p.age < 60).length;
      final int seniors = patients.where((p) => p.age >= 60).length;

      // Agrupar por ciudades más comunes
      final Map<String, int> citiesCount = {};
      for (final patient in patients) {
        citiesCount[patient.city] = (citiesCount[patient.city] ?? 0) + 1;
      }

      // Agrupar por seguros más comunes
      final Map<String, int> insuranceCount = {};
      for (final patient in patients) {
        insuranceCount[patient.insurance] = (insuranceCount[patient.insurance] ?? 0) + 1;
      }

      return {
        'totalPatients': totalPatients,
        'malePatients': malePatients,
        'femalePatients': femalePatients,
        'ageGroups': {
          'children': children,
          'youngAdults': youngAdults,
          'adults': adults,
          'seniors': seniors,
        },
        'topCities': citiesCount,
        'topInsurances': insuranceCount,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('Error al obtener estadísticas: $e');
      throw Exception('Error al obtener estadísticas de pacientes');
    }
  }

  // Verificar si existe un paciente con los mismos datos básicos
  Future<PatientFirestore?> findDuplicatePatient({
    required String firstName,
    required String paternalLastName,
    required String maternalLastName,
    required int age,
  }) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('firstName', isEqualTo: firstName)
          .where('paternalLastName', isEqualTo: paternalLastName)
          .where('maternalLastName', isEqualTo: maternalLastName)
          .where('age', isEqualTo: age)
          .limit(1)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        return PatientFirestore.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      print('Error al verificar duplicados: $e');
      return null;
    }
  }

  // Obtener pacientes creados recientemente
  Future<List<PatientFirestore>> getRecentPatients({int limit = 10}) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      
      return snapshot.docs
          .map((doc) => PatientFirestore.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error al obtener pacientes recientes: $e');
      throw Exception('Error al obtener pacientes recientes');
    }
  }
} 