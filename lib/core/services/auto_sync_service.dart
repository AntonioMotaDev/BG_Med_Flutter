import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:bg_med/core/services/frap_local_service.dart';
import 'package:bg_med/core/services/frap_firestore_service.dart';
import 'package:bg_med/core/services/frap_sync_service.dart';
import 'package:bg_med/features/frap/presentation/providers/frap_data_provider.dart';

class AutoSyncService {
  final FrapLocalService _localService;
  final FrapFirestoreService _cloudService;
  final FrapSyncService _syncService;
  final Connectivity _connectivity;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isOnline = false;
  bool _isSyncing = false;

  AutoSyncService({
    required FrapLocalService localService,
    required FrapFirestoreService cloudService,
    required FrapSyncService syncService,
    Connectivity? connectivity,
  }) : _localService = localService,
       _cloudService = cloudService,
       _syncService = syncService,
       _connectivity = connectivity ?? Connectivity();

  // Inicializar el servicio de sincronización automática
  Future<void> initialize() async {
    // Verificar conectividad inicial
    await _checkConnectivity();
    
    // Escuchar cambios en la conectividad
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        _onConnectivityChanged(results);
      },
    );
  }

  // Verificar conectividad actual
  Future<void> _checkConnectivity() async {
    final connectivityResults = await _connectivity.checkConnectivity();
    _isOnline = !connectivityResults.contains(ConnectivityResult.none);
    
    // Si se conecta a internet, sincronizar automáticamente
    if (_isOnline && !_isSyncing) {
      await _performAutoSync();
    }
  }

  // Manejar cambios en la conectividad
  void _onConnectivityChanged(List<ConnectivityResult> results) async {
    _isOnline = !results.contains(ConnectivityResult.none);
    
    // COMENTADO: Si se acaba de conectar a internet, sincronizar
    // Esto puede causar creación automática de registros
    // if (!wasOnline && _isOnline && !_isSyncing) {
    //   await _performAutoSync();
    // }
    
    // Solo actualizar el estado de conectividad sin sincronizar automáticamente
    print('Estado de conectividad actualizado: ${_isOnline ? "En línea" : "Sin conexión"}');
  }

  // Realizar sincronización automática
  Future<void> _performAutoSync() async {
    if (_isSyncing) return;
    
    _isSyncing = true;
    try {
      // Sincronizar registros locales a la nube
      await _syncService.syncLocalToCloud();
      
      // Sincronizar registros de la nube al local
      await _syncService.syncCloudToLocal();
      
      print('Sincronización automática completada');
    } catch (e) {
      print('Error en sincronización automática: $e');
    } finally {
      _isSyncing = false;
    }
  }

  // Guardar registro automáticamente (local o nube según conectividad)
  Future<SaveResult> saveRecord(FrapData frapData) async {
    final result = SaveResult();
    
    try {
      // Verificar conectividad actual
      await _checkConnectivity();
      
      // Validar datos antes de guardar
      if (!_validateFrapData(frapData)) {
        result.success = false;
        result.message = 'Datos del formulario incompletos o inválidos';
        return result;
      }
      
      if (_isOnline) {
        // Guardar en la nube
        try {
          // Asegurar que los datos estén correctamente mapeados
          final validatedData = _validateAndCleanData(frapData);
          
          final cloudRecordId = await _cloudService.createFrapRecord(frapData: validatedData);
          if (cloudRecordId != null) {
            result.success = true;
            result.recordId = cloudRecordId;
            result.savedToCloud = true;
            result.message = 'Registro guardado en la nube exitosamente';
            
            // COMENTADO: También guardar una copia local para backup
            // try {
            //   await _localService.createFrapRecord(frapData: validatedData);
            // } catch (e) {
            //   print('Advertencia: No se pudo crear backup local: $e');
            // }
          } else {
            throw Exception('No se pudo guardar en la nube');
          }
        } catch (e) {
          print('Error guardando en la nube: $e');
          // Si falla la nube, guardar localmente como respaldo
          final localRecordId = await _localService.createFrapRecord(frapData: frapData);
          if (localRecordId != null) {
            result.success = true;
            result.recordId = localRecordId;
            result.savedToCloud = false;
            result.message = 'Error en la nube, guardado localmente. Se sincronizará cuando haya conexión.';
          } else {
            throw Exception('Error guardando en nube y local: $e');
          }
        }
      } else {
        // Guardar localmente
        final localRecordId = await _localService.createFrapRecord(frapData: frapData);
        if (localRecordId != null) {
          result.success = true;
          result.recordId = localRecordId;
          result.savedToCloud = false;
          result.message = 'Sin conexión, guardado localmente. Se sincronizará cuando haya conexión.';
        } else {
          throw Exception('No se pudo guardar localmente');
        }
      }
    } catch (e) {
      result.success = false;
      result.message = 'Error al guardar: $e';
    }
    
    return result;
  }

  // Validar datos del formulario FRAP
  bool _validateFrapData(FrapData frapData) {
    // Validar que al menos la información del paciente esté completa
    if (frapData.patientInfo.isEmpty) {
      return false;
    }
    
    // Validar campos críticos del paciente
    final patientInfo = frapData.patientInfo;
    final hasName = patientInfo.containsKey('firstName') && 
                   patientInfo['firstName']?.toString().isNotEmpty == true;
    final hasAge = patientInfo.containsKey('age') && 
                  patientInfo['age'] != null;
    
    return hasName && hasAge;
  }

  // Validar y limpiar datos antes de enviar a la nube
  FrapData _validateAndCleanData(FrapData frapData) {
    // Crear una copia de los datos para limpiar
    final cleanedData = FrapData(
      serviceInfo: _cleanMap(frapData.serviceInfo),
      registryInfo: _cleanMap(frapData.registryInfo),
      patientInfo: _cleanMap(frapData.patientInfo),
      management: _cleanMap(frapData.management),
      medications: _cleanMap(frapData.medications),
      gynecoObstetric: _cleanMap(frapData.gynecoObstetric),
      attentionNegative: _cleanMap(frapData.attentionNegative),
      pathologicalHistory: _cleanMap(frapData.pathologicalHistory),
      clinicalHistory: _cleanMap(frapData.clinicalHistory),
      physicalExam: _cleanMap(frapData.physicalExam),
      priorityJustification: _cleanMap(frapData.priorityJustification),
      injuryLocation: _cleanMap(frapData.injuryLocation),
      receivingUnit: _cleanMap(frapData.receivingUnit),
      patientReception: _cleanMap(frapData.patientReception),
    );
    
    // Asegurar que los datos del paciente estén correctamente formateados
    if (cleanedData.patientInfo.isNotEmpty) {
      final patientInfo = Map<String, dynamic>.from(cleanedData.patientInfo);
      
      // Asegurar que los campos críticos estén presentes
      if (!patientInfo.containsKey('firstName') || patientInfo['firstName'] == null) {
        patientInfo['firstName'] = '';
      }
      if (!patientInfo.containsKey('paternalLastName') || patientInfo['paternalLastName'] == null) {
        patientInfo['paternalLastName'] = '';
      }
      if (!patientInfo.containsKey('maternalLastName') || patientInfo['maternalLastName'] == null) {
        patientInfo['maternalLastName'] = '';
      }
      if (!patientInfo.containsKey('age') || patientInfo['age'] == null) {
        patientInfo['age'] = 0;
      }
      if (!patientInfo.containsKey('sex') || patientInfo['sex'] == null) {
        patientInfo['sex'] = '';
      }
      
      // Actualizar los datos limpios
      cleanedData.patientInfo.clear();
      cleanedData.patientInfo.addAll(patientInfo);
    }
    
    return cleanedData;
  }

  // Limpiar un mapa de datos
  Map<String, dynamic> _cleanMap(Map<String, dynamic> originalMap) {
    final cleanedMap = <String, dynamic>{};
    
    for (final entry in originalMap.entries) {
      final key = entry.key;
      final value = entry.value;
      
      // Solo incluir valores no nulos y no vacíos
      if (value != null) {
        if (value is String && value.isNotEmpty) {
          cleanedMap[key] = value;
        } else if (value is! String) {
          cleanedMap[key] = value;
        }
      }
    }
    
    return cleanedMap;
  }

  // Verificar si hay conexión a internet
  bool get isOnline => _isOnline;

  // Verificar si está sincronizando
  bool get isSyncing => _isSyncing;

  // Obtener estadísticas de sincronización
  Future<SyncStats> getSyncStats() async {
    return await _syncService.getSyncStats();
  }

  // Forzar sincronización manual
  Future<SyncResult> forceSyncNow() async {
    if (!_isOnline) {
      return SyncResult()
        ..success = false
        ..message = 'No hay conexión a internet';
    }
    
    return await _syncService.fullSync();
  }

  // Liberar recursos
  void dispose() {
    _connectivitySubscription?.cancel();
  }
}

// Clase para el resultado de guardado
class SaveResult {
  bool success = false;
  String? recordId;
  bool savedToCloud = false;
  String message = '';
} 