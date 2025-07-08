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
    final patient = Patient(
      name: patientInfo['name'] ?? '',
      age: patientInfo['age'] ?? 0,
      gender: patientInfo['sex'] ?? '',
      address: patientInfo['address'] ?? '',
    );

    // Extraer historia clínica
    final clinicalHistoryData = frapData.clinicalHistory;
    final pathologicalHistoryData = frapData.pathologicalHistory;
    final medicationsData = frapData.medications;
    
    final clinicalHistory = ClinicalHistory(
      allergies: clinicalHistoryData['allergies'] ?? pathologicalHistoryData['allergies'] ?? '',
      medications: medicationsData['current_medications'] ?? clinicalHistoryData['medications'] ?? '',
      previousIllnesses: pathologicalHistoryData['previous_illnesses'] ?? clinicalHistoryData['previous_illnesses'] ?? '',
    );

    // Extraer examen físico
    final physicalExamData = frapData.physicalExam;
    final physicalExam = PhysicalExam(
      vitalSigns: physicalExamData['vital_signs'] ?? '',
      head: physicalExamData['head'] ?? '',
      neck: physicalExamData['neck'] ?? '',
      thorax: physicalExamData['thorax'] ?? '',
      abdomen: physicalExamData['abdomen'] ?? '',
      extremities: physicalExamData['extremities'] ?? '',
    );

    return Frap(
      id: existingId ?? const Uuid().v4(),
      patient: patient,
      clinicalHistory: clinicalHistory,
      physicalExam: physicalExam,
      createdAt: existingCreatedAt ?? DateTime.now(),
    );
  }

  // CONVERTIR Frap a Map para backup
  Map<String, dynamic> _frapToMap(Frap frap) {
    return {
      'id': frap.id,
      'patient': {
        'name': frap.patient.name,
        'age': frap.patient.age,
        'gender': frap.patient.gender,
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
        gender: patientData['gender'] as String,
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
      serviceInfo: {}, // No disponible en el modelo Frap actual
      registryInfo: {}, // No disponible en el modelo Frap actual
      patientInfo: {
        'name': frap.patient.name,
        'age': frap.patient.age,
        'sex': frap.patient.gender,
        'address': frap.patient.address,
      },
      management: {}, // No disponible en el modelo Frap actual
      medications: {
        'current_medications': frap.clinicalHistory.medications,
      },
      gynecoObstetric: {}, // No disponible en el modelo Frap actual
      attentionNegative: {}, // No disponible en el modelo Frap actual
      pathologicalHistory: {
        'allergies': frap.clinicalHistory.allergies,
        'previous_illnesses': frap.clinicalHistory.previousIllnesses,
      },
      clinicalHistory: {
        'allergies': frap.clinicalHistory.allergies,
        'medications': frap.clinicalHistory.medications,
        'previous_illnesses': frap.clinicalHistory.previousIllnesses,
      },
      physicalExam: {
        'vital_signs': frap.physicalExam.vitalSigns,
        'head': frap.physicalExam.head,
        'neck': frap.physicalExam.neck,
        'thorax': frap.physicalExam.thorax,
        'abdomen': frap.physicalExam.abdomen,
        'extremities': frap.physicalExam.extremities,
      },
      priorityJustification: {}, // No disponible en el modelo Frap actual
      injuryLocation: {}, // No disponible en el modelo Frap actual
      receivingUnit: {}, // No disponible en el modelo Frap actual
      patientReception: {}, // No disponible en el modelo Frap actual
    );
  }

  // SINCRONIZAR con registros en la nube
  Future<List<Frap>> getUnsyncedRecords() async {
    try {
      // Por ahora, todos los registros se consideran no sincronizados
      // En el futuro, se puede agregar un campo 'synced' al modelo Frap
      return await getAllFrapRecords();
    } catch (e) {
      throw Exception('Error al obtener registros no sincronizados: $e');
    }
  }
} 