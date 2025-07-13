import 'package:hive/hive.dart';
import 'package:bg_med/core/models/frap.dart';
import 'package:bg_med/features/frap/presentation/providers/frap_unified_provider.dart';

class FrapCleanupService {
  static const String _boxName = 'fraps';
  
  // Obtener la caja de Hive
  Box<Frap> get _frapBox => Hive.box<Frap>(_boxName);

  // Detectar registros locales duplicados
  Future<List<String>> findDuplicateLocalRecords(List<UnifiedFrapRecord> unifiedRecords) async {
    try {
      final duplicateIds = <String>[];
      
      for (final record in unifiedRecords) {
        if (record.isLocal && record.isDuplicate) {
          duplicateIds.add(record.id);
        }
      }
      
      return duplicateIds;
    } catch (e) {
      throw Exception('Error al detectar registros duplicados: $e');
    }
  }

  // Eliminar registros locales duplicados
  Future<bool> removeDuplicateLocalRecords(List<String> duplicateIds) async {
    try {
      int removedCount = 0;
      
      for (final duplicateId in duplicateIds) {
        final existingIndex = _frapBox.values
            .toList()
            .indexWhere((frap) => frap.id == duplicateId);
        
        if (existingIndex != -1) {
          await _frapBox.deleteAt(existingIndex);
          removedCount++;
        }
      }
      
      print('Registros duplicados eliminados: $removedCount');
      return removedCount > 0;
    } catch (e) {
      throw Exception('Error al eliminar registros duplicados: $e');
    }
  }

  // Verificar integridad después de limpieza
  Future<bool> verifyDataIntegrity() async {
    try {
      final records = _frapBox.values.toList();
      
      // Verificar que no hay registros corruptos
      for (final record in records) {
        if (record.id.isEmpty || record.patient.name.isEmpty) {
          print('Registro corrupto detectado: ${record.id}');
          return false;
        }
      }
      
      print('Integridad de datos verificada: ${records.length} registros válidos');
      return true;
    } catch (e) {
      print('Error al verificar integridad: $e');
      return false;
    }
  }

  // Obtener estadísticas de limpieza
  Future<Map<String, dynamic>> getCleanupStatistics(List<UnifiedFrapRecord> unifiedRecords) async {
    try {
      final totalLocal = unifiedRecords.where((r) => r.isLocal).length;
      final totalCloud = unifiedRecords.where((r) => !r.isLocal).length;
      final duplicates = unifiedRecords.where((r) => r.isDuplicate).length;
      final localDuplicates = unifiedRecords.where((r) => r.isLocal && r.isDuplicate).length;
      
      // Calcular espacio aproximado liberado (estimación)
      final estimatedSpacePerRecord = 1024; // 1KB por registro (estimación)
      final estimatedSpaceFreed = localDuplicates * estimatedSpacePerRecord;
      
      return {
        'totalLocal': totalLocal,
        'totalCloud': totalCloud,
        'totalDuplicates': duplicates,
        'localDuplicates': localDuplicates,
        'estimatedSpaceFreedKB': estimatedSpaceFreed,
        'estimatedSpaceFreedMB': (estimatedSpaceFreed / 1024).toStringAsFixed(2),
      };
    } catch (e) {
      throw Exception('Error al obtener estadísticas de limpieza: $e');
    }
  }

  // Limpiar registros duplicados con confirmación
  Future<Map<String, dynamic>> cleanupDuplicateRecordsWithConfirmation(
    List<UnifiedFrapRecord> unifiedRecords,
  ) async {
    try {
      final duplicateIds = await findDuplicateLocalRecords(unifiedRecords);
      
      if (duplicateIds.isEmpty) {
        return {
          'success': true,
          'message': 'No se encontraron registros duplicados para eliminar',
          'removedCount': 0,
          'statistics': await getCleanupStatistics(unifiedRecords),
        };
      }

      // Eliminar duplicados
      final success = await removeDuplicateLocalRecords(duplicateIds);
      
      if (success) {
        // Verificar integridad
        final integrityOk = await verifyDataIntegrity();
        
        if (!integrityOk) {
          throw Exception('Error de integridad después de la limpieza');
        }
        
        // Obtener estadísticas finales
        final statistics = await getCleanupStatistics(unifiedRecords);
        
        return {
          'success': true,
          'message': 'Limpieza completada exitosamente',
          'removedCount': duplicateIds.length,
          'statistics': statistics,
        };
      } else {
        return {
          'success': false,
          'message': 'No se pudieron eliminar los registros duplicados',
          'removedCount': 0,
          'statistics': await getCleanupStatistics(unifiedRecords),
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error durante la limpieza: $e',
        'removedCount': 0,
        'statistics': {},
      };
    }
  }

  // Crear backup antes de limpiar
  Future<List<Map<String, dynamic>>> createBackupBeforeCleanup() async {
    try {
      final records = _frapBox.values.toList();
      final backup = <Map<String, dynamic>>[];
      
      for (final record in records) {
        backup.add({
          'id': record.id,
          'patient': {
            'name': record.patient.name,
            'age': record.patient.age,
            'sex': record.patient.sex, // Cambiado de gender a sex
            'address': record.patient.address,
            'firstName': record.patient.firstName,
            'paternalLastName': record.patient.paternalLastName,
            'maternalLastName': record.patient.maternalLastName,
            'phone': record.patient.phone,
            'street': record.patient.street,
            'exteriorNumber': record.patient.exteriorNumber,
            'interiorNumber': record.patient.interiorNumber,
            'neighborhood': record.patient.neighborhood,
            'city': record.patient.city,
            'insurance': record.patient.insurance,
            'responsiblePerson': record.patient.responsiblePerson,
          },
          'clinicalHistory': {
            'allergies': record.clinicalHistory.allergies,
            'medications': record.clinicalHistory.medications,
            'previousIllnesses': record.clinicalHistory.previousIllnesses,
            'currentSymptoms': record.clinicalHistory.currentSymptoms,
            'pain': record.clinicalHistory.pain,
            'painScale': record.clinicalHistory.painScale,
            'dosage': record.clinicalHistory.dosage,
            'frequency': record.clinicalHistory.frequency,
            'route': record.clinicalHistory.route,
            'time': record.clinicalHistory.time,
            'previousSurgeries': record.clinicalHistory.previousSurgeries,
            'hospitalizations': record.clinicalHistory.hospitalizations,
            'transfusions': record.clinicalHistory.transfusions,
          },
          'physicalExam': {
            'vitalSigns': record.physicalExam.vitalSigns,
            'head': record.physicalExam.head,
            'neck': record.physicalExam.neck,
            'thorax': record.physicalExam.thorax,
            'abdomen': record.physicalExam.abdomen,
            'extremities': record.physicalExam.extremities,
            'bloodPressure': record.physicalExam.bloodPressure,
            'heartRate': record.physicalExam.heartRate,
            'respiratoryRate': record.physicalExam.respiratoryRate,
            'temperature': record.physicalExam.temperature,
            'oxygenSaturation': record.physicalExam.oxygenSaturation,
            'neurological': record.physicalExam.neurological,
          },
          'createdAt': record.createdAt.toIso8601String(),
          'updatedAt': record.updatedAt.toIso8601String(),
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
        });
      }
      
      print('Backup creado: ${backup.length} registros');
      return backup;
    } catch (e) {
      throw Exception('Error al crear backup: $e');
    }
  }
} 