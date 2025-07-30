import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:bg_med/core/models/frap.dart';
import 'package:bg_med/core/models/patient.dart';
import 'package:bg_med/core/models/clinical_history.dart';
import 'package:bg_med/core/models/physical_exam.dart';
import 'package:bg_med/features/frap/presentation/providers/frap_data_provider.dart';

class FrapLocalService {
  static const String _boxName = 'fraps';
  
  // Obtener la caja de Hive
  Box<Frap> get _frapBox => Hive.box<Frap>(_boxName);

  // Generar ID único para registros FRAP
  String _generateId() {
    return const Uuid().v4();
  }

  // CREAR un nuevo registro FRAP local
  Future<String?> createFrapRecord({
    required FrapData frapData,
  }) async {
    try {
      // Convertir FrapData a modelo Frap
      final frap = _convertFrapDataToFrap(frapData);
      
      // Guardar en Hive
      await _frapBox.add(frap);
      
      return frap.id;
    } catch (e) {
      throw Exception('Error al crear el registro FRAP local: $e');
    }
  }

  // ACTUALIZAR un registro FRAP local existente
  Future<void> updateFrapRecord({
    required String frapId,
    required FrapData frapData,
  }) async {
    try {
      // Buscar el registro existente
      final existingIndex = _frapBox.values
          .toList()
          .indexWhere((frap) => frap.id == frapId);
      
      if (existingIndex == -1) {
        throw Exception('Registro no encontrado');
      }

      // Convertir FrapData a modelo Frap manteniendo el ID y fecha original
      final existingFrap = _frapBox.getAt(existingIndex)!;
      final updatedFrap = _convertFrapDataToFrap(
        frapData,
        existingId: existingFrap.id,
        existingCreatedAt: existingFrap.createdAt,
      );

      // Actualizar en Hive
      await _frapBox.putAt(existingIndex, updatedFrap);
    } catch (e) {
      throw Exception('Error al actualizar el registro FRAP local: $e');
    }
  }

  // OBTENER un registro FRAP por ID
  Future<Frap?> getFrapRecord(String frapId) async {
    try {
      final frap = _frapBox.values.firstWhere(
        (frap) => frap.id == frapId,
        orElse: () => throw Exception('Registro no encontrado'),
      );
      return frap;
    } catch (e) {
      return null;
    }
  }

  // OBTENER todos los registros FRAP locales
  Future<List<Frap>> getAllFrapRecords() async {
    try {
      final records = _frapBox.values.toList();
      
      // Ordenar por fecha de creación descendente
      records.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return records;
    } catch (e) {
      throw Exception('Error al obtener los registros FRAP locales: $e');
    }
  }

  // BUSCAR registros FRAP por nombre de paciente
  Future<List<Frap>> searchFrapRecordsByPatientName({
    required String patientName,
  }) async {
    try {
      final allRecords = await getAllFrapRecords();
      
      // Filtrar por nombre del paciente
      final filteredRecords = allRecords.where((record) {
        final fullName = record.patient.name.toLowerCase();
        final searchTerm = patientName.toLowerCase();
        return fullName.contains(searchTerm);
      }).toList();

      return filteredRecords;
    } catch (e) {
      throw Exception('Error al buscar registros FRAP locales: $e');
    }
  }

  // OBTENER registros FRAP por rango de fechas
  Future<List<Frap>> getFrapRecordsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final allRecords = await getAllFrapRecords();
      
      // Filtrar por rango de fechas
      final filteredRecords = allRecords.where((record) {
        return record.createdAt.isAfter(startDate) && 
               record.createdAt.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();

      return filteredRecords;
    } catch (e) {
      throw Exception('Error al obtener registros FRAP por fecha: $e');
    }
  }

  // ELIMINAR un registro FRAP
  Future<void> deleteFrapRecord(String frapId) async {
    try {
      final existingIndex = _frapBox.values
          .toList()
          .indexWhere((frap) => frap.id == frapId);
      
      if (existingIndex == -1) {
        throw Exception('Registro no encontrado');
      }

      await _frapBox.deleteAt(existingIndex);
    } catch (e) {
      throw Exception('Error al eliminar el registro FRAP local: $e');
    }
  }

  // DUPLICAR un registro FRAP
  Future<String?> duplicateFrapRecord(String frapId) async {
    try {
      final originalRecord = await getFrapRecord(frapId);
      if (originalRecord == null) {
        throw Exception('Registro no encontrado');
      }

      // Crear una copia del registro con nuevo ID y fecha
      final duplicatedRecord = Frap(
        id: const Uuid().v4(),
        patient: originalRecord.patient,
        clinicalHistory: originalRecord.clinicalHistory,
        physicalExam: originalRecord.physicalExam,
        createdAt: DateTime.now(),
      );

      await _frapBox.add(duplicatedRecord);
      return duplicatedRecord.id;
    } catch (e) {
      throw Exception('Error al duplicar el registro FRAP local: $e');
    }
  }

  // OBTENER estadísticas de registros FRAP
  Future<Map<String, dynamic>> getFrapStatistics() async {
    try {
      final allRecords = await getAllFrapRecords();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final thisWeek = today.subtract(Duration(days: today.weekday - 1));
      final thisMonth = DateTime(now.year, now.month, 1);
      final thisYear = DateTime(now.year, 1, 1);

      return {
        'total': allRecords.length,
        'today': allRecords.where((record) {
          final recordDate = DateTime(
            record.createdAt.year,
            record.createdAt.month,
            record.createdAt.day,
          );
          return recordDate.isAtSameMomentAs(today);
        }).length,
        'thisWeek': allRecords.where((record) => 
          record.createdAt.isAfter(thisWeek) && 
          record.createdAt.isBefore(today.add(const Duration(days: 1)))
        ).length,
        'thisMonth': allRecords.where((record) => 
          record.createdAt.isAfter(thisMonth) && 
          record.createdAt.isBefore(thisMonth.add(const Duration(days: 32)))
        ).length,
        'thisYear': allRecords.where((record) => 
          record.createdAt.isAfter(thisYear) && 
          record.createdAt.isBefore(thisYear.add(const Duration(days: 366)))
        ).length,
      };
    } catch (e) {
      throw Exception('Error al obtener las estadísticas FRAP locales: $e');
    }
  }

  // LIMPIAR todos los registros FRAP
  Future<void> clearAllFrapRecords() async {
    try {
      await _frapBox.clear();
    } catch (e) {
      throw Exception('Error al limpiar los registros FRAP locales: $e');
    }
  }

  // BACKUP de registros FRAP
  Future<List<Map<String, dynamic>>> backupFrapRecords() async {
    try {
      final records = await getAllFrapRecords();
      return records.map((record) => _frapToMap(record)).toList();
    } catch (e) {
      throw Exception('Error al crear backup de registros FRAP locales: $e');
    }
  }

  // RESTAURAR registros FRAP desde backup
  Future<void> restoreFrapRecords({
    required List<Map<String, dynamic>> backupData,
  }) async {
    try {
      for (final recordData in backupData) {
        final frap = _frapFromMap(recordData);
        await _frapBox.add(frap);
      }
    } catch (e) {
      throw Exception('Error al restaurar registros FRAP locales: $e');
    }
  }

  // CONVERTIR FrapData a modelo Frap
  Frap _convertFrapDataToFrap(
    FrapData frapData, {
    String? existingId,
    DateTime? existingCreatedAt,
  }) {
    // Extraer información del paciente
    final patientInfo = frapData.patientInfo;
    
    // Construir el nombre completo del paciente
    final firstName = patientInfo['firstName'] ?? '';
    final paternalLastName = patientInfo['paternalLastName'] ?? '';
    final maternalLastName = patientInfo['maternalLastName'] ?? '';
    final fullName = '$firstName $paternalLastName $maternalLastName'.trim();
    
    // Construir la dirección completa
    final street = patientInfo['street'] ?? '';
    final exteriorNumber = patientInfo['exteriorNumber'] ?? '';
    final interiorNumber = patientInfo['interiorNumber'] ?? '';
    final neighborhood = patientInfo['neighborhood'] ?? '';
    final city = patientInfo['city'] ?? '';
    
    String fullAddress = '';
    if (street.isNotEmpty) {
      fullAddress = street;
      if (exteriorNumber.isNotEmpty) {
        fullAddress += ' $exteriorNumber';
      }
      if (interiorNumber != null && interiorNumber.isNotEmpty) {
        fullAddress += ', Int. $interiorNumber';
      }
      if (neighborhood.isNotEmpty) {
        fullAddress += ', $neighborhood';
      }
      if (city.isNotEmpty) {
        fullAddress += ', $city';
      }
    }
    
    final patient = Patient(
      name: fullName.isNotEmpty ? fullName : 'Sin nombre',
      age: patientInfo['age'] ?? 0,
      sex: patientInfo['sex'] ?? '', // Cambiado de gender a sex
      address: fullAddress,
      firstName: firstName,
      paternalLastName: paternalLastName,
      maternalLastName: maternalLastName,
      phone: patientInfo['phone'] ?? '',
      street: street,
      exteriorNumber: exteriorNumber,
      interiorNumber: interiorNumber,
      neighborhood: neighborhood,
      city: city,
      insurance: patientInfo['insurance'] ?? '',
      responsiblePerson: patientInfo['responsiblePerson'],
    );

    // Extraer historia clínica
    final clinicalHistoryData = frapData.clinicalHistory;
    final clinicalHistory = ClinicalHistory(
      allergies: clinicalHistoryData['allergies'] ?? '',
      medications: clinicalHistoryData['medications'] ?? '',
      previousIllnesses: clinicalHistoryData['previous_illnesses'] ?? clinicalHistoryData['previousIllnesses'] ?? '',
      currentSymptoms: clinicalHistoryData['currentSymptoms'] ?? '',
      pain: clinicalHistoryData['pain'] ?? '',
      painScale: clinicalHistoryData['painScale'] ?? '',
      dosage: clinicalHistoryData['dosage'] ?? '',
      frequency: clinicalHistoryData['frequency'] ?? '',
      route: clinicalHistoryData['route'] ?? '',
      time: clinicalHistoryData['time'] ?? '',
      previousSurgeries: clinicalHistoryData['previousSurgeries'] ?? '',
      hospitalizations: clinicalHistoryData['hospitalizations'] ?? '',
      transfusions: clinicalHistoryData['transfusions'] ?? '',
    );

    // Extraer examen físico
    final physicalExamData = frapData.physicalExam;
    final physicalExam = PhysicalExam(
      vitalSigns: physicalExamData['vital_signs'] ?? physicalExamData['vitalSigns'] ?? '',
      head: physicalExamData['head'] ?? '',
      neck: physicalExamData['neck'] ?? '',
      thorax: physicalExamData['thorax'] ?? '',
      abdomen: physicalExamData['abdomen'] ?? '',
      extremities: physicalExamData['extremities'] ?? '',
      bloodPressure: physicalExamData['bloodPressure'] ?? '',
      heartRate: physicalExamData['heartRate'] ?? '',
      respiratoryRate: physicalExamData['respiratoryRate'] ?? '',
      temperature: physicalExamData['temperature'] ?? '',
      oxygenSaturation: physicalExamData['oxygenSaturation'] ?? '',
      neurological: physicalExamData['neurological'] ?? '',
    );

    final now = DateTime.now();
    final id = existingId ?? _generateId();
    final createdAt = existingCreatedAt ?? now;

    return Frap(
      id: id,
      patient: patient,
      clinicalHistory: clinicalHistory,
      physicalExam: physicalExam,
      createdAt: createdAt,
      updatedAt: now,
      serviceInfo: frapData.serviceInfo,
      registryInfo: frapData.registryInfo,
      management: frapData.management,
      medications: frapData.medications,
      gynecoObstetric: frapData.gynecoObstetric,
      attentionNegative: frapData.attentionNegative,
      pathologicalHistory: frapData.pathologicalHistory,
      priorityJustification: frapData.priorityJustification,
      injuryLocation: frapData.injuryLocation,
      receivingUnit: frapData.receivingUnit,
      patientReception: frapData.patientReception,
    );
  }

  // CONVERTIR Frap a Map para backup
  Map<String, dynamic> _frapToMap(Frap frap) {
    return {
      'id': frap.id,
      'patient': {
        'name': frap.patient.name,
        'age': frap.patient.age,
        'sex': frap.patient.sex, // Cambiado de gender a sex
        'address': frap.patient.address,
      },
      'clinicalHistory': {
        'allergies': frap.clinicalHistory.allergies,
        'medications': frap.clinicalHistory.medications,
        'previousIllnesses': frap.clinicalHistory.previousIllnesses,
      },
      'physicalExam': {
        'vitalSigns': frap.physicalExam.vitalSigns,
        'head': frap.physicalExam.head,
        'neck': frap.physicalExam.neck,
        'thorax': frap.physicalExam.thorax,
        'abdomen': frap.physicalExam.abdomen,
        'extremities': frap.physicalExam.extremities,
      },
      'createdAt': frap.createdAt.toIso8601String(),
    };
  }

  // CONVERTIR Map a Frap para restaurar
  Frap _frapFromMap(Map<String, dynamic> map) {
    final patientData = map['patient'] as Map<String, dynamic>;
    final clinicalHistoryData = map['clinicalHistory'] as Map<String, dynamic>;
    final physicalExamData = map['physicalExam'] as Map<String, dynamic>;

    return Frap(
      id: map['id'] as String,
      patient: Patient(
        name: patientData['name'] as String,
        age: patientData['age'] as int,
        sex: patientData['sex'] as String,
        address: patientData['address'] as String,
      ),
      clinicalHistory: ClinicalHistory(
        allergies: clinicalHistoryData['allergies'] as String,
        medications: clinicalHistoryData['medications'] as String,
        previousIllnesses: clinicalHistoryData['previousIllnesses'] as String,
      ),
      physicalExam: PhysicalExam(
        vitalSigns: physicalExamData['vitalSigns'] as String,
        head: physicalExamData['head'] as String,
        neck: physicalExamData['neck'] as String,
        thorax: physicalExamData['thorax'] as String,
        abdomen: physicalExamData['abdomen'] as String,
        extremities: physicalExamData['extremities'] as String,
      ),
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  // CONVERTIR Frap a FrapData para edición
  FrapData convertFrapToFrapData(Frap frap) {
    return FrapData(
      serviceInfo: frap.serviceInfo,
      registryInfo: frap.registryInfo,
      patientInfo: {
        'firstName': frap.patient.firstName,
        'paternalLastName': frap.patient.paternalLastName,
        'maternalLastName': frap.patient.maternalLastName,
        'age': frap.patient.age,
        'sex': frap.patient.sex, // Cambiado de gender a sex
        'phone': frap.patient.phone,
        'street': frap.patient.street,
        'exteriorNumber': frap.patient.exteriorNumber,
        'interiorNumber': frap.patient.interiorNumber,
        'neighborhood': frap.patient.neighborhood,
        'city': frap.patient.city,
        'insurance': frap.patient.insurance,
        'responsiblePerson': frap.patient.responsiblePerson,
        'currentCondition': frap.serviceInfo['currentCondition'] ?? '',
        'emergencyContact': frap.serviceInfo['emergencyContact'] ?? '',
        'address': frap.patient.fullAddress, // Mantener también la dirección completa
      },
      management: frap.management,
      medications: frap.medications.isNotEmpty ? frap.medications : {
        'current_medications': frap.clinicalHistory.medications,
        'dosage': frap.clinicalHistory.dosage,
        'frequency': frap.clinicalHistory.frequency,
        'route': frap.clinicalHistory.route,
        'time': frap.clinicalHistory.time,
      },
      gynecoObstetric: frap.gynecoObstetric,
      attentionNegative: frap.attentionNegative,
      pathologicalHistory: frap.pathologicalHistory.isNotEmpty ? frap.pathologicalHistory : {
        'allergies': frap.clinicalHistory.allergies,
        'previous_illnesses': frap.clinicalHistory.previousIllnesses,
        'previousSurgeries': frap.clinicalHistory.previousSurgeries,
        'hospitalizations': frap.clinicalHistory.hospitalizations,
        'transfusions': frap.clinicalHistory.transfusions,
      },
      clinicalHistory: {
        'allergies': frap.clinicalHistory.allergies,
        'medications': frap.clinicalHistory.medications,
        'previous_illnesses': frap.clinicalHistory.previousIllnesses,
        'currentSymptoms': frap.clinicalHistory.currentSymptoms,
        'pain': frap.clinicalHistory.pain,
        'painScale': frap.clinicalHistory.painScale,
      },
      physicalExam: {
        'vital_signs': frap.physicalExam.vitalSigns,
        'head': frap.physicalExam.head,
        'neck': frap.physicalExam.neck,
        'thorax': frap.physicalExam.thorax,
        'abdomen': frap.physicalExam.abdomen,
        'extremities': frap.physicalExam.extremities,
        'bloodPressure': frap.physicalExam.bloodPressure,
        'heartRate': frap.physicalExam.heartRate,
        'respiratoryRate': frap.physicalExam.respiratoryRate,
        'temperature': frap.physicalExam.temperature,
        'oxygenSaturation': frap.physicalExam.oxygenSaturation,
        'neurological': frap.physicalExam.neurological,
      },
      priorityJustification: frap.priorityJustification,
      injuryLocation: frap.injuryLocation,
      receivingUnit: frap.receivingUnit,
      patientReception: frap.patientReception,
    );
  }

  // Marcar registro como sincronizado
  Future<void> markAsSynced(String frapId) async {
    try {
      final existingIndex = _frapBox.values
          .toList()
          .indexWhere((frap) => frap.id == frapId);
      
      if (existingIndex == -1) {
        throw Exception('Registro no encontrado');
      }

      final existingFrap = _frapBox.getAt(existingIndex)!;
      final updatedFrap = existingFrap.copyWith(isSynced: true);

      // Actualizar en Hive
      await _frapBox.putAt(existingIndex, updatedFrap);
    } catch (e) {
      throw Exception('Error al marcar como sincronizado: $e');
    }
  }

  // Obtener registros no sincronizados
  Future<List<Frap>> getUnsyncedRecords() async {
    try {
      final records = _frapBox.values.toList();
      return records.where((frap) => !frap.isSynced).toList();
    } catch (e) {
      throw Exception('Error al obtener registros no sincronizados: $e');
    }
  }
} 