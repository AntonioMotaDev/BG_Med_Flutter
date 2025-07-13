import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bg_med/core/models/frap.dart';
import 'package:bg_med/core/models/frap_firestore.dart';
import 'package:bg_med/features/frap/presentation/providers/frap_local_provider.dart';
import 'package:bg_med/features/frap/presentation/providers/frap_firestore_provider.dart';
import 'package:bg_med/core/services/frap_cleanup_service.dart';
import 'package:intl/intl.dart'; // Added for DateFormat

// Estados de sincronización
enum SyncStatus {
  notSynced,    // Solo local
  synced,       // Solo nube
  duplicate,    // Existe en ambos
  conflict      // Diferentes versiones
}

// Modelo unificado para representar registros FRAP de cualquier fuente
class UnifiedFrapRecord {
  final String id;
  final String patientName;
  final int patientAge;
  final String patientGender;
  final String patientAddress;
  final DateTime createdAt;
  final bool isLocal; // true = local (Hive), false = cloud (Firestore)
  final double completionPercentage;
  final String? syncId; // ID para sincronización entre local y nube
  
  // Campos para manejo de duplicados
  final bool isDuplicate;
  final String? duplicateOf; // ID del registro original
  final String? duplicateCriteria; // Criterio usado para detectar duplicado
  
  // Datos originales para acceso directo
  final Frap? localRecord;
  final FrapFirestore? cloudRecord;

  const UnifiedFrapRecord({
    required this.id,
    required this.patientName,
    required this.patientAge,
    required this.patientGender,
    required this.patientAddress,
    required this.createdAt,
    required this.isLocal,
    required this.completionPercentage,
    this.syncId,
    this.isDuplicate = false,
    this.duplicateOf,
    this.duplicateCriteria,
    this.localRecord,
    this.cloudRecord,
  });

  // Factory constructor desde registro local
  factory UnifiedFrapRecord.fromLocal(Frap frap) {
    return UnifiedFrapRecord(
      id: frap.id,
      patientName: frap.patient.fullName.isNotEmpty ? frap.patient.fullName : 'Paciente sin nombre',
      patientAge: frap.patient.age,
      patientGender: frap.patient.sex, // Cambiado de gender a sex
      patientAddress: frap.patient.fullAddress,
      createdAt: frap.createdAt,
      isLocal: true,
      completionPercentage: frap.completionPercentage,
      syncId: _generateRobustSyncId(frap.patient.fullName, frap.patient.age, frap.patient.sex, frap.createdAt),
      localRecord: frap,
      cloudRecord: null,
    );
  }

  // Factory constructor desde registro de la nube
  factory UnifiedFrapRecord.fromCloud(FrapFirestore frapFirestore) {
    return UnifiedFrapRecord(
      id: frapFirestore.id ?? '',
      patientName: frapFirestore.patientName.isNotEmpty ? frapFirestore.patientName : 'Paciente sin nombre',
      patientAge: frapFirestore.patientAge,
      patientGender: frapFirestore.patientGender,
      patientAddress: _extractAddressFromFirestore(frapFirestore),
      createdAt: frapFirestore.createdAt,
      isLocal: false,
      completionPercentage: frapFirestore.completionPercentage,
      syncId: _generateRobustSyncId(frapFirestore.patientName, frapFirestore.patientAge, frapFirestore.patientGender, frapFirestore.createdAt),
      localRecord: null,
      cloudRecord: frapFirestore,
    );
  }

  // Método para marcar como duplicado
  UnifiedFrapRecord markAsDuplicate(String originalId, String criteria) {
    return UnifiedFrapRecord(
      id: id,
      patientName: patientName,
      patientAge: patientAge,
      patientGender: patientGender,
      patientAddress: patientAddress,
      createdAt: createdAt,
      isLocal: isLocal,
      completionPercentage: completionPercentage,
      syncId: syncId,
      isDuplicate: true,
      duplicateOf: originalId,
      duplicateCriteria: criteria,
      localRecord: localRecord,
      cloudRecord: cloudRecord,
    );
  }

  // Calcular porcentaje de completitud para registros locales
  static double _calculateLocalCompletion(Frap frap) {
    // Usar el nuevo método del modelo Frap expandido
    return frap.completionPercentage;
  }

  // Extraer dirección de registro de Firestore
  static String _extractAddressFromFirestore(FrapFirestore frapFirestore) {
    final patientInfo = frapFirestore.patientInfo;
    final address = patientInfo['address'] ?? '';
    if (address.isNotEmpty) return address;
    
    final street = patientInfo['street'] ?? '';
    final neighborhood = patientInfo['neighborhood'] ?? '';
    return '$street $neighborhood'.trim();
  }

  // Generar ID de sincronización basado en datos del paciente y fecha
  static String _generateSyncId(String patientName, int patientAge, String patientGender, DateTime createdAt) {
    final normalizedName = patientName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    final dateKey = '${createdAt.year}${createdAt.month.toString().padLeft(2, '0')}${createdAt.day.toString().padLeft(2, '0')}${createdAt.hour.toString().padLeft(2, '0')}${createdAt.minute.toString().padLeft(2, '0')}';
    return '${normalizedName}_${patientAge}_${patientGender.toLowerCase()}_$dateKey';
  }

  // Generar syncId más robusto y consistente
  static String _generateRobustSyncId(String patientName, int patientAge, String patientGender, DateTime createdAt) {
    final normalizedName = patientName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    final dateKey = '${createdAt.year}${createdAt.month.toString().padLeft(2, '0')}${createdAt.day.toString().padLeft(2, '0')}${createdAt.hour.toString().padLeft(2, '0')}${createdAt.minute.toString().padLeft(2, '0')}';
    return '${normalizedName}_${patientAge}_${patientGender.toLowerCase()}_$dateKey';
  }

  // Función para comparar registros por contenido
  static bool _areRecordsEquivalent(UnifiedFrapRecord local, UnifiedFrapRecord cloud) {
    // Criterio 1: Comparar datos críticos del paciente
    if (local.patientName.toLowerCase() != cloud.patientName.toLowerCase()) return false;
    if (local.patientAge != cloud.patientAge) return false;
    if (local.patientGender.toLowerCase() != cloud.patientGender.toLowerCase()) return false;
    
    // Criterio 2: Comparar fechas de creación (con tolerancia de 5 minutos)
    final timeDifference = local.createdAt.difference(cloud.createdAt).abs();
    if (timeDifference.inMinutes > 5) return false;
    
    // Criterio 3: Comparar contenido de secciones principales
    final localInfo = local.getDetailedInfo();
    final cloudInfo = cloud.getDetailedInfo();
    
    // Comparar información del paciente
    final localPatient = localInfo['patientInfo'] as Map<String, dynamic>;
    final cloudPatient = cloudInfo['patientInfo'] as Map<String, dynamic>;
    
    if (localPatient['name'] != cloudPatient['name']) return false;
    if (localPatient['age'] != cloudPatient['age']) return false;
    if (localPatient['sex'] != cloudPatient['sex']) return false; // Cambiado de gender a sex
    
    // Comparar historia clínica básica
    final localClinical = localInfo['clinicalHistory'] as Map<String, dynamic>;
    final cloudClinical = cloudInfo['clinicalHistory'] as Map<String, dynamic>;
    
    if (localClinical['allergies'] != cloudClinical['allergies']) return false;
    if (localClinical['medications'] != cloudClinical['medications']) return false;
    
    return true;
  }

  // Detectar duplicados usando múltiples criterios
  static List<Map<String, dynamic>> _detectDuplicates(
    List<UnifiedFrapRecord> localRecords,
    List<UnifiedFrapRecord> cloudRecords,
  ) {
    final duplicates = <Map<String, dynamic>>[];
    
    for (final localRecord in localRecords) {
      for (final cloudRecord in cloudRecords) {
        // Criterio 1: SyncId exacto
        if (localRecord.syncId == cloudRecord.syncId) {
          duplicates.add({
            'local': localRecord,
            'cloud': cloudRecord,
            'criteria': 'syncId_exact',
          });
          continue;
        }
        
        // Criterio 2: Datos del paciente + fecha (con tolerancia)
        if (_areRecordsEquivalent(localRecord, cloudRecord)) {
          duplicates.add({
            'local': localRecord,
            'cloud': cloudRecord,
            'criteria': 'content_equivalent',
          });
          continue;
        }
        
        // Criterio 3: Nombre y edad exactos + fecha cercana (10 minutos)
        if (localRecord.patientName.toLowerCase() == cloudRecord.patientName.toLowerCase() &&
            localRecord.patientAge == cloudRecord.patientAge &&
            localRecord.patientGender.toLowerCase() == cloudRecord.patientGender.toLowerCase()) {
          final timeDifference = localRecord.createdAt.difference(cloudRecord.createdAt).abs();
          if (timeDifference.inMinutes <= 10) {
            duplicates.add({
              'local': localRecord,
              'cloud': cloudRecord,
              'criteria': 'patient_similar',
            });
          }
        }
      }
    }
    
    return duplicates;
  }

  // Método para obtener información detallada del registro
  Map<String, dynamic> getDetailedInfo() {
    if (isLocal && localRecord != null) {
      return {
        'serviceInfo': localRecord!.serviceInfo.isNotEmpty 
            ? localRecord!.serviceInfo 
            : {
                'serviceType': 'Atención Prehospitalaria',
                'date': DateFormat('dd/MM/yyyy').format(localRecord!.createdAt),
                'startTime': DateFormat('HH:mm').format(localRecord!.createdAt),
              },
        'registryInfo': localRecord!.registryInfo.isNotEmpty 
            ? localRecord!.registryInfo 
            : {
                'folio': localRecord!.id.substring(0, 8).toUpperCase(),
                'registrationDate': DateFormat('dd/MM/yyyy').format(localRecord!.createdAt),
                'registrationTime': DateFormat('HH:mm').format(localRecord!.createdAt),
              },
        'patientInfo': {
          'name': localRecord!.patient.fullName,
          'firstName': localRecord!.patient.firstName,
          'paternalLastName': localRecord!.patient.paternalLastName,
          'maternalLastName': localRecord!.patient.maternalLastName,
          'age': localRecord!.patient.age,
          'sex': localRecord!.patient.sex, // Cambiado de gender a sex
          'address': localRecord!.patient.fullAddress,
          'phone': localRecord!.patient.phone,
          'insurance': localRecord!.patient.insurance,
          'responsiblePerson': localRecord!.patient.responsiblePerson,
          'street': localRecord!.patient.street,
          'exteriorNumber': localRecord!.patient.exteriorNumber,
          'interiorNumber': localRecord!.patient.interiorNumber,
          'neighborhood': localRecord!.patient.neighborhood,
          'city': localRecord!.patient.city,
          // Campos específicos de FRAP (desde patientInfo del registro)
          'currentCondition': localRecord!.serviceInfo['currentCondition'] ?? '',
          'emergencyContact': localRecord!.serviceInfo['emergencyContact'] ?? '',
        },
        'clinicalHistory': {
          'allergies': localRecord!.clinicalHistory.allergies,
          'medications': localRecord!.clinicalHistory.medications,
          'previousIllnesses': localRecord!.clinicalHistory.previousIllnesses,
          'currentSymptoms': localRecord!.clinicalHistory.currentSymptoms,
          'pain': localRecord!.clinicalHistory.pain,
          'painScale': localRecord!.clinicalHistory.painScale,
        },
        'physicalExam': {
          'vitalSigns': localRecord!.physicalExam.vitalSigns,
          'head': localRecord!.physicalExam.head,
          'neck': localRecord!.physicalExam.neck,
          'thorax': localRecord!.physicalExam.thorax,
          'abdomen': localRecord!.physicalExam.abdomen,
          'extremities': localRecord!.physicalExam.extremities,
          'bloodPressure': localRecord!.physicalExam.bloodPressure,
          'heartRate': localRecord!.physicalExam.heartRate,
          'respiratoryRate': localRecord!.physicalExam.respiratoryRate,
          'temperature': localRecord!.physicalExam.temperature,
          'oxygenSaturation': localRecord!.physicalExam.oxygenSaturation,
          'neurological': localRecord!.physicalExam.neurological,
        },
        'pathologicalHistory': localRecord!.pathologicalHistory.isNotEmpty 
            ? localRecord!.pathologicalHistory 
            : {
                'allergies': localRecord!.clinicalHistory.allergies,
                'previous_illnesses': localRecord!.clinicalHistory.previousIllnesses,
                'previousSurgeries': localRecord!.clinicalHistory.previousSurgeries,
                'hospitalizations': localRecord!.clinicalHistory.hospitalizations,
                'transfusions': localRecord!.clinicalHistory.transfusions,
              },
        'medications': localRecord!.medications.isNotEmpty 
            ? localRecord!.medications 
            : {
                'current_medications': localRecord!.clinicalHistory.medications,
                'dosage': localRecord!.clinicalHistory.dosage,
                'frequency': localRecord!.clinicalHistory.frequency,
                'route': localRecord!.clinicalHistory.route,
                'time': localRecord!.clinicalHistory.time,
              },
        'management': localRecord!.management.isNotEmpty 
            ? localRecord!.management 
            : {
                'procedures': '',
                'medications': localRecord!.clinicalHistory.medications,
                'response': '',
                'observations': '',
              },
        'gynecoObstetric': localRecord!.gynecoObstetric,
        'attentionNegative': localRecord!.attentionNegative,
        'priorityJustification': localRecord!.priorityJustification,
        'injuryLocation': localRecord!.injuryLocation,
        'receivingUnit': localRecord!.receivingUnit,
        'patientReception': localRecord!.patientReception,
      };
    } else if (!isLocal && cloudRecord != null) {
      return {
        'serviceInfo': cloudRecord!.serviceInfo,
        'registryInfo': cloudRecord!.registryInfo,
        'patientInfo': cloudRecord!.patientInfo,
        'clinicalHistory': cloudRecord!.clinicalHistory,
        'physicalExam': cloudRecord!.physicalExam,
        'management': cloudRecord!.management,
        'medications': cloudRecord!.medications,
        'gynecoObstetric': cloudRecord!.gynecoObstetric,
        'attentionNegative': cloudRecord!.attentionNegative,
        'pathologicalHistory': cloudRecord!.pathologicalHistory,
        'priorityJustification': cloudRecord!.priorityJustification,
        'injuryLocation': cloudRecord!.injuryLocation,
        'receivingUnit': cloudRecord!.receivingUnit,
        'patientReception': cloudRecord!.patientReception,
      };
    }
    return {};
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UnifiedFrapRecord && other.id == id && other.isLocal == isLocal;
  }

  @override
  int get hashCode => id.hashCode ^ isLocal.hashCode;
}

// Estado unificado para registros FRAP
class UnifiedFrapState {
  final List<UnifiedFrapRecord> records;
  final bool isLoadingLocal;
  final bool isLoadingCloud;
  final String? errorLocal;
  final String? errorCloud;
  final Map<String, dynamic>? statistics;
  
  // Información de duplicados
  final int duplicateCount;
  final int localDuplicatesCount;
  final Map<String, dynamic>? cleanupStatistics;

  const UnifiedFrapState({
    this.records = const [],
    this.isLoadingLocal = false,
    this.isLoadingCloud = false,
    this.errorLocal,
    this.errorCloud,
    this.statistics,
    this.duplicateCount = 0,
    this.localDuplicatesCount = 0,
    this.cleanupStatistics,
  });

  bool get isLoading => isLoadingLocal || isLoadingCloud;
  String? get error => errorLocal ?? errorCloud;

  UnifiedFrapState copyWith({
    List<UnifiedFrapRecord>? records,
    bool? isLoadingLocal,
    bool? isLoadingCloud,
    String? errorLocal,
    String? errorCloud,
    Map<String, dynamic>? statistics,
    int? duplicateCount,
    int? localDuplicatesCount,
    Map<String, dynamic>? cleanupStatistics,
  }) {
    return UnifiedFrapState(
      records: records ?? this.records,
      isLoadingLocal: isLoadingLocal ?? this.isLoadingLocal,
      isLoadingCloud: isLoadingCloud ?? this.isLoadingCloud,
      errorLocal: errorLocal,
      errorCloud: errorCloud,
      statistics: statistics ?? this.statistics,
      duplicateCount: duplicateCount ?? this.duplicateCount,
      localDuplicatesCount: localDuplicatesCount ?? this.localDuplicatesCount,
      cleanupStatistics: cleanupStatistics ?? this.cleanupStatistics,
    );
  }
}

// Notifier para manejar el estado unificado
class UnifiedFrapNotifier extends StateNotifier<UnifiedFrapState> {
  final FrapLocalNotifier _localNotifier;
  final FrapFirestoreNotifier _cloudNotifier;
  final FrapCleanupService _cleanupService = FrapCleanupService();
  bool _isUpdating = false; // Flag para evitar actualizaciones múltiples

  UnifiedFrapNotifier(this._localNotifier, this._cloudNotifier) : super(const UnifiedFrapState()) {
    // Cargar datos iniciales
    loadAllRecords();
  }

  // Cargar todos los registros (locales y de la nube)
  Future<void> loadAllRecords() async {
    if (_isUpdating) return; // Evitar múltiples cargas simultáneas
    _isUpdating = true;

    state = state.copyWith(
      isLoadingLocal: true,
      isLoadingCloud: true,
      errorLocal: null,
      errorCloud: null,
    );

    try {
      // Cargar registros locales y de la nube en paralelo
      await Future.wait([
        _loadLocalRecords(),
        _loadCloudRecords(),
      ]);

      _combineRecords();
    } finally {
      _isUpdating = false;
    }
  }

  Future<void> _loadLocalRecords() async {
    try {
      await _localNotifier.loadLocalFrapRecords();
      state = state.copyWith(isLoadingLocal: false, errorLocal: null);
    } catch (e) {
      state = state.copyWith(isLoadingLocal: false, errorLocal: e.toString());
    }
  }

  Future<void> _loadCloudRecords() async {
    try {
      await _cloudNotifier.loadFrapRecords();
      state = state.copyWith(isLoadingCloud: false, errorCloud: null);
    } catch (e) {
      state = state.copyWith(isLoadingCloud: false, errorCloud: e.toString());
    }
  }

  void _combineRecords() {
    final localRecords = _localNotifier.state.records
        .map((frap) => UnifiedFrapRecord.fromLocal(frap))
        .toList();

    final cloudRecords = _cloudNotifier.state.records
        .map((frap) => UnifiedFrapRecord.fromCloud(frap))
        .toList();

    // Detectar duplicados usando la nueva lógica
    final duplicates = UnifiedFrapRecord._detectDuplicates(localRecords, cloudRecords);
    
    // Crear mapa de registros únicos, priorizando registros de la nube
    final Map<String, UnifiedFrapRecord> uniqueRecords = {};
    final List<String> duplicateLocalIds = [];
    
    // Primero agregar todos los registros de la nube
    for (final cloudRecord in cloudRecords) {
      if (cloudRecord.syncId != null) {
        uniqueRecords[cloudRecord.syncId!] = cloudRecord;
      } else {
        // Si no tiene syncId, usar el ID original como fallback
        uniqueRecords['cloud_${cloudRecord.id}'] = cloudRecord;
      }
    }
    
    // Luego procesar registros locales
    for (final localRecord in localRecords) {
      bool isDuplicate = false;
      String? duplicateOf;
      String? duplicateCriteria;
      
      // Verificar si es duplicado
      for (final duplicate in duplicates) {
        if (duplicate['local']?.id == localRecord.id) {
          isDuplicate = true;
          duplicateOf = duplicate['cloud']?.id;
          duplicateCriteria = duplicate['criteria'];
          duplicateLocalIds.add(localRecord.id);
          break;
        }
      }
      
      if (localRecord.syncId != null) {
        if (!uniqueRecords.containsKey(localRecord.syncId!)) {
          // No es duplicado, agregar al mapa
          if (isDuplicate) {
            uniqueRecords[localRecord.syncId!] = localRecord.markAsDuplicate(duplicateOf!, duplicateCriteria!);
          } else {
            uniqueRecords[localRecord.syncId!] = localRecord;
          }
        } else {
          // Ya existe un registro con el mismo syncId (debe ser de la nube)
          // Marcar el local como duplicado
          duplicateLocalIds.add(localRecord.id);
        }
      } else {
        // Si no tiene syncId, usar el ID original como fallback
        final key = 'local_${localRecord.id}';
        if (!uniqueRecords.containsKey(key)) {
          if (isDuplicate) {
            uniqueRecords[key] = localRecord.markAsDuplicate(duplicateOf!, duplicateCriteria!);
          } else {
            uniqueRecords[key] = localRecord;
          }
        }
      }
    }
    
    final allRecords = uniqueRecords.values.toList();
    
    // Ordenar por fecha de creación descendente
    allRecords.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    state = state.copyWith(records: allRecords);
    _updateStatistics();
    
    // Debug en desarrollo
    if (localRecords.isNotEmpty || cloudRecords.isNotEmpty) {
      debugRecordUnification();
      
      // Mostrar información de duplicados detectados
      if (duplicates.isNotEmpty) {
        print('=== DUPLICADOS DETECTADOS ===');
        print('Total de duplicados: ${duplicates.length}');
        for (final duplicate in duplicates) {
          final local = duplicate['local']!;
          final cloud = duplicate['cloud']!;
          final criteria = duplicate['criteria']!;
          print('  - Local: ${local.patientName} (${local.id})');
          print('    Cloud: ${cloud.patientName} (${cloud.id})');
          print('    Criterio: $criteria');
        }
        print('Registros locales marcados para eliminación: ${duplicateLocalIds.length}');
        print('=== FIN DUPLICADOS ===\n');
      }
    }
  }

  void _updateStatistics() {
    final totalRecords = state.records.length;
    final localCount = state.records.where((r) => r.isLocal).length;
    final cloudCount = state.records.where((r) => !r.isLocal).length;
    final duplicateCount = state.records.where((r) => r.isDuplicate).length;
    final localDuplicatesCount = state.records.where((r) => r.isLocal && r.isDuplicate).length;
    
    final unifiedStats = {
      'total': totalRecords,
      'local': localCount,
      'cloud': cloudCount,
      'today': _getTodayCount(),
      'thisWeek': _getWeekCount(),
      'thisMonth': _getMonthCount(),
      'averageCompletion': _getAverageCompletion(),
      'localOnlyCount': localCount - localDuplicatesCount, // Registros que solo existen localmente
      'cloudOnlyCount': cloudCount, // Registros que solo existen en la nube
      'syncedCount': totalRecords - localDuplicatesCount, // Registros sincronizados
      'duplicateCount': duplicateCount,
      'localDuplicatesCount': localDuplicatesCount,
    };

    state = state.copyWith(
      statistics: unifiedStats,
      duplicateCount: duplicateCount,
      localDuplicatesCount: localDuplicatesCount,
    );
  }

  int _getTodayCount() {
    final today = DateTime.now();
    return state.records.where((record) {
      final recordDate = record.createdAt;
      return recordDate.day == today.day &&
             recordDate.month == today.month &&
             recordDate.year == today.year;
    }).length;
  }

  int _getWeekCount() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    
    return state.records.where((record) {
      return record.createdAt.isAfter(weekStart) &&
             record.createdAt.isBefore(weekEnd.add(const Duration(days: 1)));
    }).length;
  }

  int _getMonthCount() {
    final now = DateTime.now();
    return state.records.where((record) {
      return record.createdAt.month == now.month &&
             record.createdAt.year == now.year;
    }).length;
  }

  double _getAverageCompletion() {
    if (state.records.isEmpty) return 0.0;
    final total = state.records.map((record) => record.completionPercentage).reduce((a, b) => a + b);
    return total / state.records.length;
  }

  // Buscar registros por nombre de paciente
  Future<void> searchRecords(String patientName) async {
    if (patientName.isEmpty) {
      await loadAllRecords();
      return;
    }

    if (_isUpdating) return;
    _isUpdating = true;

    try {
      // Buscar en ambas fuentes
      await Future.wait([
        _localNotifier.searchLocalFrapRecords(patientName),
        _cloudNotifier.searchFrapRecords(patientName),
      ]);

      _combineRecords();
    } finally {
      _isUpdating = false;
    }
  }

  // Filtrar registros por rango de fechas
  Future<void> filterByDateRange(DateTime startDate, DateTime endDate) async {
    if (_isUpdating) return;
    _isUpdating = true;

    try {
      await Future.wait([
        _localNotifier.getLocalFrapRecordsByDateRange(startDate, endDate),
        _cloudNotifier.getFrapRecordsByDateRange(startDate, endDate),
      ]);

      _combineRecords();
    } finally {
      _isUpdating = false;
    }
  }

  // Eliminar un registro
  Future<bool> deleteRecord(UnifiedFrapRecord record) async {
    bool success;
    if (record.isLocal) {
      success = await _localNotifier.deleteLocalFrapRecord(record.id);
    } else {
      success = await _cloudNotifier.deleteFrapRecord(record.id);
    }
    
    if (success) {
      // Actualizar la lista local sin recargar todo
      final updatedRecords = state.records.where((r) => r.id != record.id).toList();
      state = state.copyWith(records: updatedRecords);
      _updateStatistics();
    }
    
    return success;
  }

  // Duplicar un registro
  Future<String?> duplicateRecord(UnifiedFrapRecord record) async {
    String? newRecordId;
    if (record.isLocal) {
      newRecordId = await _localNotifier.duplicateLocalFrapRecord(record.id);
    } else {
      newRecordId = await _cloudNotifier.duplicateFrapRecord(record.id);
    }
    
    if (newRecordId != null) {
      // Recargar solo los datos necesarios
      await loadAllRecords();
    }
    
    return newRecordId;
  }

  // Sincronizar registros locales a la nube
  Future<void> syncLocalToCloud() async {
    try {
      await _cloudNotifier.syncWithLocalRecords();
      await loadAllRecords();
    } catch (e) {
      state = state.copyWith(errorCloud: e.toString());
    }
  }

  // Limpiar errores
  void clearErrors() {
    state = state.copyWith(errorLocal: null, errorCloud: null);
  }

  // Método de debug para entender la unificación de registros
  void debugRecordUnification() {
    final localRecords = _localNotifier.state.records;
    final cloudRecords = _cloudNotifier.state.records;
    
    print('=== DEBUG RECORD UNIFICATION ===');
    print('Local records count: ${localRecords.length}');
    print('Cloud records count: ${cloudRecords.length}');
    print('Unified records count: ${state.records.length}');
    
    print('\nLocal records:');
    for (final record in localRecords) {
      final unified = UnifiedFrapRecord.fromLocal(record);
      print('  - ${record.patient.name} (${record.patient.age}) | SyncID: ${unified.syncId} | Created: ${record.createdAt}');
    }
    
    print('\nCloud records:');
    for (final record in cloudRecords) {
      final unified = UnifiedFrapRecord.fromCloud(record);
      print('  - ${record.patientName} (${record.patientAge}) | SyncID: ${unified.syncId} | Created: ${record.createdAt}');
    }
    
    print('\nUnified records:');
    for (final record in state.records) {
      print('  - ${record.patientName} (${record.patientAge}) | ${record.isLocal ? 'LOCAL' : 'CLOUD'} | SyncID: ${record.syncId} | Created: ${record.createdAt}');
    }
    print('=== END DEBUG ===\n');
  }

  // Actualizar registros cuando cambian los providers subyacentes
  void updateFromProviders(FrapLocalState localState, FrapFirestoreState cloudState) {
    if (_isUpdating) return; // Evitar actualizaciones múltiples
    
    // Solo actualizar si hay cambios reales en los datos
    bool hasLocalChanges = localState.records.length != 
        (state.records.where((r) => r.isLocal).length);
    bool hasCloudChanges = cloudState.records.length != 
        (state.records.where((r) => !r.isLocal).length);
    
    if (!hasLocalChanges && !hasCloudChanges) {
      return; // No hay cambios reales, no actualizar
    }
    
    // Actualizar estados de carga
    state = state.copyWith(
      isLoadingLocal: localState.isLoading,
      isLoadingCloud: cloudState.isLoading,
      errorLocal: localState.error,
      errorCloud: cloudState.error,
    );

    // Recombinar registros solo si no están cargando y hay cambios
    if (!localState.isLoading && !cloudState.isLoading) {
      _combineRecords();
    }
  }

  // Limpiar registros duplicados
  Future<Map<String, dynamic>> cleanupDuplicateRecords() async {
    try {
      state = state.copyWith(isLoadingLocal: true);
      
      final result = await _cleanupService.cleanupDuplicateRecordsWithConfirmation(state.records);
      
      if (result['success'] == true) {
        // Recargar registros después de la limpieza
        await loadAllRecords();
        
        state = state.copyWith(
          isLoadingLocal: false,
          errorLocal: null,
        );
      } else {
        state = state.copyWith(
          isLoadingLocal: false,
          errorLocal: result['message'],
        );
      }
      
      return result;
    } catch (e) {
      state = state.copyWith(
        isLoadingLocal: false,
        errorLocal: e.toString(),
      );
      return {
        'success': false,
        'message': 'Error durante la limpieza: $e',
        'removedCount': 0,
        'statistics': {},
      };
    }
  }

  // Sincronizar y limpiar duplicados
  Future<Map<String, dynamic>> syncAndCleanup() async {
    try {
      state = state.copyWith(
        isLoadingLocal: true,
        isLoadingCloud: true,
        errorLocal: null,
        errorCloud: null,
      );

      // 1. Sincronizar registros locales a la nube
      await _cloudNotifier.syncWithLocalRecords();
      
      // 2. Recargar todos los registros
      await loadAllRecords();
      
      // 3. Limpiar duplicados
      final cleanupResult = await cleanupDuplicateRecords();
      
      // 4. Recargar una vez más después de la limpieza
      await loadAllRecords();
      
      return {
        'success': true,
        'message': 'Sincronización y limpieza completadas',
        'syncSuccess': true,
        'cleanupResult': cleanupResult,
      };
    } catch (e) {
      state = state.copyWith(
        isLoadingLocal: false,
        isLoadingCloud: false,
        errorLocal: e.toString(),
      );
      return {
        'success': false,
        'message': 'Error durante sincronización y limpieza: $e',
        'syncSuccess': false,
        'cleanupResult': {
          'success': false,
          'message': 'No se pudo completar la limpieza',
          'removedCount': 0,
          'statistics': {},
        },
      };
    }
  }

  // Obtener estadísticas de limpieza
  Future<Map<String, dynamic>> getCleanupStatistics() async {
    try {
      return await _cleanupService.getCleanupStatistics(state.records);
    } catch (e) {
      return {
        'error': e.toString(),
        'totalLocal': 0,
        'totalCloud': 0,
        'totalDuplicates': 0,
        'localDuplicates': 0,
        'estimatedSpaceFreedKB': 0,
        'estimatedSpaceFreedMB': '0.00',
      };
    }
  }

  // Crear backup antes de limpiar
  Future<List<Map<String, dynamic>>> createBackupBeforeCleanup() async {
    try {
      return await _cleanupService.createBackupBeforeCleanup();
    } catch (e) {
      throw Exception('Error al crear backup: $e');
    }
  }
}

// Provider principal unificado
final unifiedFrapProvider = StateNotifierProvider<UnifiedFrapNotifier, UnifiedFrapState>((ref) {
  final localNotifier = ref.watch(frapLocalProvider.notifier);
  final cloudNotifier = ref.watch(frapFirestoreProvider.notifier);
  
  final unifiedNotifier = UnifiedFrapNotifier(localNotifier, cloudNotifier);
  
  // Escuchar cambios en los providers subyacentes con debounce
  ref.listen<FrapLocalState>(frapLocalProvider, (previous, next) {
    if (previous != next && !next.isLoading) {
      // Solo actualizar si el estado cambió y no está cargando
      // Aumentar debounce para evitar actualizaciones muy frecuentes
      Future.delayed(const Duration(milliseconds: 300), () {
        unifiedNotifier.updateFromProviders(next, ref.read(frapFirestoreProvider));
      });
    }
  });
  
  ref.listen<FrapFirestoreState>(frapFirestoreProvider, (previous, next) {
    if (previous != next && !next.isLoading) {
      // Solo actualizar si el estado cambió y no está cargando
      // Aumentar debounce para evitar actualizaciones muy frecuentes
      Future.delayed(const Duration(milliseconds: 300), () {
        unifiedNotifier.updateFromProviders(ref.read(frapLocalProvider), next);
      });
    }
  });
  
  return unifiedNotifier;
});

// Provider para estadísticas unificadas
final unifiedFrapStatisticsProvider = Provider<Map<String, dynamic>>((ref) {
  final state = ref.watch(unifiedFrapProvider);
  return state.statistics ?? {};
});

// Provider para obtener un registro específico por ID
final unifiedFrapRecordProvider = Provider.family<UnifiedFrapRecord?, String>((ref, recordId) {
  final state = ref.watch(unifiedFrapProvider);
  try {
    return state.records.firstWhere((record) => record.id == recordId);
  } catch (e) {
    return null;
  }
}); 