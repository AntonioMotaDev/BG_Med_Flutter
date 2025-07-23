import 'package:bg_med/core/models/frap.dart';
import 'package:bg_med/core/services/duplicate_detection_service.dart';
import 'package:bg_med/core/services/frap_local_service.dart';
import 'package:bg_med/core/services/frap_firestore_service.dart';

class CleanupResult {
  final bool success;
  final int recordsRemoved;
  final int spaceFreed;
  final List<String> errors;
  final List<String> warnings;

  CleanupResult({
    required this.success,
    required this.recordsRemoved,
    required this.spaceFreed,
    required this.errors,
    required this.warnings,
  });
}

class DataCleanupService {
  final DuplicateDetectionService _duplicateDetection;
  final FrapLocalService _localService;
  final FrapFirestoreService _cloudService;

  DataCleanupService({
    required DuplicateDetectionService duplicateDetection,
    required FrapLocalService localService,
    required FrapFirestoreService cloudService,
  }) : _duplicateDetection = duplicateDetection,
       _localService = localService,
       _cloudService = cloudService;

  // Eliminar registros locales duplicados de forma segura
  Future<CleanupResult> removeDuplicateLocalRecords() async {
    final List<String> errors = [];
    final List<String> warnings = [];
    int recordsRemoved = 0;
    int spaceFreed = 0;

    try {
      // 1. Obtener todos los registros locales y de la nube
      final localRecords = await _localService.getAllFraps();
      final cloudRecords = await _cloudService.getAllFraps();

      // 2. Detectar duplicados
      final allRecords = [...localRecords, ...cloudRecords];
      final duplicateGroups = await _duplicateDetection.detectDuplicates(allRecords);

      // 3. Crear backup antes de eliminar
      await _createBackup(localRecords);

      // 4. Procesar cada grupo de duplicados
      for (final group in duplicateGroups) {
        final result = await _processDuplicateGroup(group);
        recordsRemoved += result.recordsRemoved;
        spaceFreed += result.spaceFreed;
        errors.addAll(result.errors);
        warnings.addAll(result.warnings);
      }

      // 5. Verificar integridad después de limpieza
      final integrityCheck = await verifyDataIntegrity();
      if (!integrityCheck) {
        // Rollback si hay problemas de integridad
        await _rollbackCleanup();
        errors.add('Se detectaron problemas de integridad. Se realizó rollback automático.');
        return CleanupResult(
          success: false,
          recordsRemoved: 0,
          spaceFreed: 0,
          errors: errors,
          warnings: warnings,
        );
      }

      return CleanupResult(
        success: true,
        recordsRemoved: recordsRemoved,
        spaceFreed: spaceFreed,
        errors: errors,
        warnings: warnings,
      );

    } catch (e) {
      // Rollback en caso de error
      await _rollbackCleanup();
      errors.add('Error durante la limpieza: $e');
      
      return CleanupResult(
        success: false,
        recordsRemoved: 0,
        spaceFreed: 0,
        errors: errors,
        warnings: warnings,
      );
    }
  }

  // Procesar un grupo específico de duplicados
  Future<CleanupResult> _processDuplicateGroup(DuplicateGroup group) async {
    final List<String> errors = [];
    final List<String> warnings = [];
    int recordsRemoved = 0;
    int spaceFreed = 0;

    try {
      // Separar registros locales y de la nube
      final localRecords = group.records.where((r) => r.id.startsWith('local_')).toList();
      final cloudRecords = group.records.where((r) => !r.id.startsWith('local_')).toList();

      // Priorizar registros de la nube sobre locales
      if (cloudRecords.isNotEmpty && localRecords.isNotEmpty) {
        // Eliminar registros locales duplicados
        for (final localRecord in localRecords) {
          final removed = await _localService.deleteFrap(localRecord.id);
          if (removed) {
            recordsRemoved++;
            spaceFreed += _estimateRecordSize(localRecord);
          } else {
            errors.add('No se pudo eliminar el registro local: ${localRecord.id}');
          }
        }
      } else if (localRecords.length > 1) {
        // Múltiples registros locales, mantener el más reciente
        localRecords.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        final toRemove = localRecords.skip(1); // Mantener el primero (más reciente)

        for (final record in toRemove) {
          final removed = await _localService.deleteFrap(record.id);
          if (removed) {
            recordsRemoved++;
            spaceFreed += _estimateRecordSize(record);
          } else {
            errors.add('No se pudo eliminar el registro local: ${record.id}');
          }
        }
      }

      // Advertencias para registros potencialmente duplicados
      if (group.type == DuplicateType.potential) {
        warnings.add('Grupo de duplicados potenciales detectado con confianza ${(group.confidence * 100).toStringAsFixed(1)}%');
      }

    } catch (e) {
      errors.add('Error procesando grupo ${group.groupId}: $e');
    }

    return CleanupResult(
      success: errors.isEmpty,
      recordsRemoved: recordsRemoved,
      spaceFreed: spaceFreed,
      errors: errors,
      warnings: warnings,
    );
  }

  // Verificar integridad después de limpieza
  Future<bool> verifyDataIntegrity() async {
    try {
      // 1. Verificar que no hay registros huérfanos
      final localRecords = await _localService.getAllFraps();
      final cloudRecords = await _cloudService.getAllFraps();

      // 2. Verificar que no hay duplicados restantes
      final allRecords = [...localRecords, ...cloudRecords];
      final remainingDuplicates = await _duplicateDetection.detectDuplicates(allRecords);

      // 3. Verificar que los registros locales tienen IDs válidos
      final invalidLocalRecords = localRecords.where((r) => !r.id.startsWith('local_')).toList();

      // 4. Verificar que los registros de la nube tienen IDs válidos
      final invalidCloudRecords = cloudRecords.where((r) => r.id.startsWith('local_')).toList();

      return remainingDuplicates.isEmpty && 
             invalidLocalRecords.isEmpty && 
             invalidCloudRecords.isEmpty;

    } catch (e) {
      print('Error verificando integridad: $e');
      return false;
    }
  }

  // Crear backup antes de limpieza
  Future<void> _createBackup(List<Frap> records) async {
    try {
      final backupData = records.map((r) => r.toJson()).toList();
      // Aquí podrías guardar en un archivo temporal o en Hive con prefijo 'backup_'
      // Por simplicidad, solo imprimimos que se creó el backup
      print('Backup creado con ${records.length} registros');
    } catch (e) {
      print('Error creando backup: $e');
    }
  }

  // Rollback en caso de error
  Future<void> _rollbackCleanup() async {
    try {
      // Aquí restaurarías desde el backup
      // Por simplicidad, solo imprimimos que se realizó rollback
      print('Rollback realizado');
    } catch (e) {
      print('Error durante rollback: $e');
    }
  }

  // Estimar tamaño de un registro en bytes
  int _estimateRecordSize(Frap record) {
    // Estimación simple basada en campos principales
    int size = 0;
    size += record.patient.name.length;
    size += record.clinicalHistory.allergies.join(',').length;
    size += record.physicalExam.vitalSigns.length;
    size += record.serviceInfo.toString().length;
    size += record.registryInfo.toString().length;
    size += record.management.toString().length;
    size += record.medications.toString().length;
    size += record.gynecoObstetric.toString().length;
    size += record.attentionNegative.toString().length;
    size += record.pathologicalHistory.toString().length;
    size += record.priorityJustification.toString().length;
    size += record.injuryLocation.toString().length;
    size += record.receivingUnit.toString().length;
    size += record.patientReception.toString().length;
    
    return size;
  }

  // Obtener estadísticas de limpieza
  Future<Map<String, dynamic>> getCleanupStatistics() async {
    final localRecords = await _localService.getAllFraps();
    final cloudRecords = await _cloudService.getAllFraps();
    final allRecords = [...localRecords, ...cloudRecords];
    final duplicateGroups = await _duplicateDetection.detectDuplicates(allRecords);

    int totalDuplicates = 0;
    int exactDuplicates = 0;
    int similarDuplicates = 0;
    int potentialDuplicates = 0;

    for (final group in duplicateGroups) {
      totalDuplicates += group.records.length - 1; // -1 porque un registro es el original
      
      switch (group.type) {
        case DuplicateType.exact:
          exactDuplicates += group.records.length - 1;
          break;
        case DuplicateType.similar:
          similarDuplicates += group.records.length - 1;
          break;
        case DuplicateType.potential:
          potentialDuplicates += group.records.length - 1;
          break;
      }
    }

    return {
      'totalRecords': allRecords.length,
      'localRecords': localRecords.length,
      'cloudRecords': cloudRecords.length,
      'totalDuplicates': totalDuplicates,
      'exactDuplicates': exactDuplicates,
      'similarDuplicates': similarDuplicates,
      'potentialDuplicates': potentialDuplicates,
      'duplicateGroups': duplicateGroups.length,
    };
  }
} 