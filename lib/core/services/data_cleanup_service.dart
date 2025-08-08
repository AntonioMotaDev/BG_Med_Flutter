import 'package:bg_med/core/models/frap.dart';
import 'package:bg_med/core/services/frap_local_service.dart';
import 'package:bg_med/core/services/frap_firestore_service.dart';

class CleanupResult {
  final bool success;
  final String message;
  final int removedCount;
  final List<String> errors;
  final List<String> warnings;

  CleanupResult({
    required this.success,
    required this.message,
    required this.removedCount,
    required this.errors,
    required this.warnings,
  });
}

class DataIntegrityResult {
  final bool isValid;
  final String message;

  DataIntegrityResult({required this.isValid, required this.message});
}

class CleanupStatistics {
  final int totalLocalRecords;
  final int totalCloudRecords;
  final int duplicateGroups;
  final int totalDuplicates;
  final int estimatedSpaceSaved;

  CleanupStatistics({
    required this.totalLocalRecords,
    required this.totalCloudRecords,
    required this.duplicateGroups,
    required this.totalDuplicates,
    required this.estimatedSpaceSaved,
  });
}

class DataCleanupService {
  final FrapLocalService _localService;
  final FrapFirestoreService _cloudService;

  DataCleanupService({
    required FrapLocalService localService,
    required FrapFirestoreService cloudService,
  }) : _localService = localService,
       _cloudService = cloudService;

  Future<CleanupResult> removeDuplicateLocalRecords() async {
    try {
      final localRecords = await _localService.getAllFrapRecords();

      if (localRecords.isEmpty) {
        return CleanupResult(
          success: true,
          message: 'No hay registros locales para limpiar',
          removedCount: 0,
          errors: [],
          warnings: [],
        );
      }

      final duplicates = _findDuplicates(localRecords);

      if (duplicates.isEmpty) {
        return CleanupResult(
          success: true,
          message: 'No se encontraron duplicados',
          removedCount: 0,
          errors: [],
          warnings: [],
        );
      }

      int removedCount = 0;
      List<String> errors = [];
      List<String> warnings = [];

      for (final group in duplicates) {
        try {
          final result = await _processDuplicateGroup(group);
          removedCount += result.removedCount;
          errors.addAll(result.errors);
          warnings.addAll(result.warnings);
        } catch (e) {
          errors.add('Error procesando grupo de duplicados: $e');
        }
      }

      // Verificar integridad de datos después de la limpieza
      final integrityResult = await verifyDataIntegrity();
      if (!integrityResult.isValid) {
        warnings.add(
          'Se detectaron problemas de integridad de datos: ${integrityResult.message}',
        );
      }

      return CleanupResult(
        success: errors.isEmpty,
        message:
            'Limpieza completada. $removedCount registros duplicados removidos.',
        removedCount: removedCount,
        errors: errors,
        warnings: warnings,
      );
    } catch (e) {
      return CleanupResult(
        success: false,
        message: 'Error durante la limpieza: $e',
        removedCount: 0,
        errors: [e.toString()],
        warnings: [],
      );
    }
  }

  List<List<Frap>> _findDuplicates(List<Frap> localRecords) {
    // Simple duplicate detection based on patient name and date
    final Map<String, List<Frap>> groups = {};

    for (final record in localRecords) {
      final key =
          '${record.patient.name}_${record.createdAt.toIso8601String().split('T')[0]}';
      groups.putIfAbsent(key, () => []).add(record);
    }

    // Return only groups with more than one record
    return groups.values.where((group) => group.length > 1).toList();
  }

  Future<CleanupResult> _processDuplicateGroup(List<Frap> group) async {
    if (group.isEmpty) {
      return CleanupResult(
        success: true,
        message: 'Grupo vacío',
        removedCount: 0,
        errors: [],
        warnings: [],
      );
    }

    // Mantener el registro más reciente
    group.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final recordsToDelete = group.skip(1).toList();

    int removedCount = 0;
    List<String> errors = [];
    List<String> warnings = [];

    for (final record in recordsToDelete) {
      try {
        await _localService.deleteFrapRecord(record.id);
        removedCount++;
      } catch (e) {
        errors.add('Error eliminando registro ${record.id}: $e');
      }
    }

    return CleanupResult(
      success: errors.isEmpty,
      message: 'Procesado grupo de ${group.length} registros',
      removedCount: removedCount,
      errors: errors,
      warnings: warnings,
    );
  }

  Future<DataIntegrityResult> verifyDataIntegrity() async {
    try {
      final localRecords = await _localService.getAllFrapRecords();
      final cloudRecords = await _cloudService.getAllFrapRecords();

      Set<String> localIds = localRecords.map((r) => r.id).toSet();
      Set<String?> cloudIds = cloudRecords.map((r) => r.id).toSet();

      // Verificar IDs únicos
      if (localIds.length != localRecords.length) {
        return DataIntegrityResult(
          isValid: false,
          message: 'Se encontraron IDs duplicados en registros locales',
        );
      }

      if (cloudIds.length != cloudRecords.length) {
        return DataIntegrityResult(
          isValid: false,
          message: 'Se encontraron IDs duplicados en registros en la nube',
        );
      }

      // Verificar datos básicos
      for (final record in localRecords) {
        if (record.patient.name.isEmpty || record.serviceInfo.isEmpty) {
          return DataIntegrityResult(
            isValid: false,
            message: 'Registro local con datos incompletos: ${record.id}',
          );
        }
      }

      return DataIntegrityResult(
        isValid: true,
        message: 'Integridad de datos verificada correctamente',
      );
    } catch (e) {
      return DataIntegrityResult(
        isValid: false,
        message: 'Error verificando integridad: $e',
      );
    }
  }

  // int _estimateRecordSize(Frap record) {
  //   int size = 0;

  //   // Información del paciente
  //   size += record.patient.name.length;
  //   size += record.patient.age.toString().length;
  //   size += record.patient.sex.length;
  //   size += record.patient.address.length;
  //   size += record.patient.phone.length;

  //   // Información del servicio
  //   size += record.serviceInfo.values.map((v) => v.toString().length).fold(0, (a, b) => a + b);

  //   // Información del registro
  //   size += record.registryInfo.values.map((v) => v.toString().length).fold(0, (a, b) => a + b);

  //   // Antecedentes patológicos
  //   size += record.pathologicalHistory.values.map((v) => v.toString().length).fold(0, (a, b) => a + b);

  //   // Antecedentes clínicos
  //   size += record.clinicalHistory.allergies.length;
  //   size += record.clinicalHistory.medications.length;
  //   size += record.clinicalHistory.previousIllnesses.length;

  //   // Medicamentos
  //   size += record.medications.length;

  //   // Examen físico
  //   size += record.physicalExam.vitalSigns.length;
  //   size += record.physicalExam.head.length;
  //   size += record.physicalExam.neck.length;
  //   size += record.physicalExam.thorax.length;
  //   size += record.physicalExam.abdomen.length;
  //   size += record.physicalExam.extremities.length;

  //   // Localización de lesiones
  //   size += record.injuryLocation.values.map((v) => v.toString().length).fold(0, (a, b) => a + b);

  //   // Manejo
  //   size += record.management.values.map((v) => v.toString().length).fold(0, (a, b) => a + b);

  //   // Gineco-obstétrico
  //   size += record.gynecoObstetric.values.map((v) => v.toString().length).fold(0, (a, b) => a + b);

  //   // Negativa de atención
  //   size += record.attentionNegative.values.map((v) => v.toString().length).fold(0, (a, b) => a + b);

  //   // Justificación de prioridad
  //   size += record.priorityJustification.values.map((v) => v.toString().length).fold(0, (a, b) => a + b);

  //   // Unidad receptora
  //   size += record.receivingUnit.values.map((v) => v.toString().length).fold(0, (a, b) => a + b);

  //   // Recepción del paciente
  //   size += record.patientReception.values.map((v) => v.toString().length).fold(0, (a, b) => a + b);

  //   // Insumos
  //   size += record.insumos.length;

  //   // Personal médico
  //   size += record.personalMedico.length;

  //   // Escalas obstétricas
  //   if (record.escalasObstetricas != null) {
  //     size += record.escalasObstetricas!.toJson().toString().length;
  //   }

  //   return size;
  // }

  Future<CleanupStatistics> getCleanupStatistics() async {
    final localRecords = await _localService.getAllFrapRecords();
    final cloudRecords = await _cloudService.getAllFrapRecords();

    return CleanupStatistics(
      totalLocalRecords: localRecords.length,
      totalCloudRecords: cloudRecords.length,
      duplicateGroups:
          0, // This will need to be calculated based on the actual duplicate detection logic
      totalDuplicates:
          0, // This will need to be calculated based on the actual duplicate detection logic
      estimatedSpaceSaved:
          0, // This will need to be calculated based on the actual duplicate detection logic
    );
  }
}
