import 'package:bg_med/core/services/frap_unified_service.dart';
import 'package:bg_med/core/services/frap_local_service.dart';
import 'package:bg_med/core/services/frap_firestore_service.dart';

class FrapCleanupService {
  final FrapLocalService _localService;
  final FrapFirestoreService _cloudService;

  FrapCleanupService({
    required FrapLocalService localService,
    required FrapFirestoreService cloudService,
  }) : _localService = localService,
       _cloudService = cloudService;

  // Limpiar registros duplicados con confirmación
  Future<Map<String, dynamic>> cleanupDuplicateRecordsWithConfirmation(
    List<UnifiedFrapRecord> records,
  ) async {
    try {
      // Separar registros locales y de la nube
      final localRecords = records.where((r) => r.isLocal).toList();
      final cloudRecords = records.where((r) => !r.isLocal).toList();

      // Detectar duplicados
      final duplicates = _detectDuplicates(localRecords, cloudRecords);

      if (duplicates.isEmpty) {
        return {
          'success': true,
          'message': 'No se encontraron duplicados para limpiar',
          'removedCount': 0,
          'statistics': {
            'totalRecords': records.length,
            'localRecords': localRecords.length,
            'cloudRecords': cloudRecords.length,
            'duplicatesFound': 0,
          },
        };
      }

      // Procesar duplicados
      int removedCount = 0;
      final errors = <String>[];

      for (final duplicate in duplicates) {
        try {
          final localRecord = duplicate['local'] as UnifiedFrapRecord?;

          if (localRecord != null && localRecord.isLocal) {
            // Eliminar registro local duplicado
            await _localService.deleteFrapRecord(
              localRecord.localRecord?.id ?? '',
            );
            removedCount++;
          }
        } catch (e) {
          errors.add('Error eliminando duplicado: $e');
        }
      }

      return {
        'success': errors.isEmpty,
        'message':
            errors.isEmpty
                ? 'Limpieza completada. $removedCount registros eliminados'
                : 'Limpieza completada con errores: ${errors.join(', ')}',
        'removedCount': removedCount,
        'errors': errors,
        'statistics': {
          'totalRecords': records.length,
          'localRecords': localRecords.length,
          'cloudRecords': cloudRecords.length,
          'duplicatesFound': duplicates.length,
          'removedCount': removedCount,
        },
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error durante la limpieza: $e',
        'removedCount': 0,
        'errors': [e.toString()],
        'statistics': {},
      };
    }
  }

  // Detectar duplicados entre registros locales y de la nube
  List<Map<String, dynamic>> _detectDuplicates(
    List<UnifiedFrapRecord> localRecords,
    List<UnifiedFrapRecord> cloudRecords,
  ) {
    final duplicates = <Map<String, dynamic>>[];

    for (final localRecord in localRecords) {
      for (final cloudRecord in cloudRecords) {
        // Comparar por nombre del paciente y fecha de creación
        if (_areRecordsEquivalent(localRecord, cloudRecord)) {
          duplicates.add({
            'local': localRecord,
            'cloud': cloudRecord,
            'criteria': 'patient_name_and_date',
          });
        }
      }
    }

    return duplicates;
  }

  // Verificar si dos registros son equivalentes
  bool _areRecordsEquivalent(UnifiedFrapRecord local, UnifiedFrapRecord cloud) {
    // Comparar por nombre del paciente y fecha de creación
    final localPatientName = local.patientName;
    final cloudPatientName = cloud.patientName;

    return localPatientName.toLowerCase() == cloudPatientName.toLowerCase() &&
        local.createdAt.difference(cloud.createdAt).abs().inMinutes < 5;
  }

  // Obtener estadísticas de limpieza
  Future<Map<String, dynamic>> getCleanupStatistics(
    List<UnifiedFrapRecord> records,
  ) async {
    try {
      final localRecords = records.where((r) => r.isLocal).toList();
      final cloudRecords = records.where((r) => !r.isLocal).toList();

      final duplicates = _detectDuplicates(localRecords, cloudRecords);

      return {
        'totalRecords': records.length,
        'localRecords': localRecords.length,
        'cloudRecords': cloudRecords.length,
        'duplicatesFound': duplicates.length,
        'estimatedSpaceFreedKB': duplicates.length * 2, // Estimación aproximada
        'estimatedSpaceFreedMB': (duplicates.length * 2 / 1024).toStringAsFixed(
          2,
        ),
      };
    } catch (e) {
      return {
        'error': e.toString(),
        'totalRecords': 0,
        'localRecords': 0,
        'cloudRecords': 0,
        'duplicatesFound': 0,
        'estimatedSpaceFreedKB': 0,
        'estimatedSpaceFreedMB': '0.00',
      };
    }
  }

  // Crear backup antes de limpiar
  Future<List<Map<String, dynamic>>> createBackupBeforeCleanup() async {
    try {
      final localRecords = await _localService.getAllFrapRecords();
      final cloudRecords = await _cloudService.getAllFrapRecords();

      final backup = <Map<String, dynamic>>[];

      // Backup de registros locales
      for (final record in localRecords) {
        backup.add({
          'type': 'local',
          'id': record.id,
          'patientName': record.patient.name,
          'createdAt': record.createdAt.toIso8601String(),
          'data': record.toJson(),
        });
      }

      // Backup de registros de la nube
      for (final record in cloudRecords) {
        backup.add({
          'type': 'cloud',
          'id': record.id ?? '',
          'patientName': record.patientName,
          'createdAt': record.createdAt.toIso8601String(),
          'data': {
            'patientInfo': record.patientInfo,
            'clinicalHistory': record.clinicalHistory,
            'physicalExam': record.physicalExam,
            'serviceInfo': record.serviceInfo,
            'registryInfo': record.registryInfo,
            'management': record.management,
            'medications': record.medications,
            'gynecoObstetric': record.gynecoObstetric,
            'attentionNegative': record.attentionNegative,
            'pathologicalHistory': record.pathologicalHistory,
            'priorityJustification': record.priorityJustification,
            'injuryLocation': record.injuryLocation,
            'receivingUnit': record.receivingUnit,
            'patientReception': record.patientReception,
          },
        });
      }

      return backup;
    } catch (e) {
      throw Exception('Error al crear backup: $e');
    }
  }
}
