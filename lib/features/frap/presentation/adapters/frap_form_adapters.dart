import 'package:bg_med/core/models/frap.dart';
import 'package:bg_med/core/models/frap_firestore.dart';
import 'package:bg_med/core/models/frap_transition_model.dart';
import 'package:bg_med/core/models/insumo.dart';
import 'package:bg_med/core/models/personal_medico.dart';
import 'package:bg_med/core/models/escalas_obstetricas.dart';
import 'package:bg_med/core/models/patient.dart';
import 'package:bg_med/core/services/frap_data_validator.dart';

/// Adaptadores de formularios para manejo de datos híbridos
class FrapFormAdapters {
  
  /// Adaptador para datos de insumos
  static Map<String, dynamic> adaptInsumos(dynamic data, {bool isFromCloud = false}) {
    if (data == null) {
      return {
        'insumosList': <Map<String, dynamic>>[],
        'insumos': '',
        'totalInsumos': 0,
        'totalCantidad': 0,
      };
    }

    if (isFromCloud) {
      // Datos vienen de la nube (Map<String, dynamic>)
      if (data is Map<String, dynamic>) {
        // Verificar si ya están en formato de lista
        if (data['insumosList'] != null && data['insumosList'] is List) {
          return _normalizeInsumosData(data);
        }
        
        // Buscar insumos en diferentes ubicaciones
        final insumosData = data['insumos'] ?? [];
        if (insumosData is List) {
          final validation = FrapDataValidator.validateInsumosData(insumosData);
          if (validation.isValid && validation.cleanedData != null) {
            final cleanedInsumos = validation.cleanedData!['insumos'] as List;
            return {
              'insumosList': cleanedInsumos,
              'insumos': cleanedInsumos.map((i) => '${i['cantidad']} - ${i['articulo']}').join('\n'),
              'totalInsumos': cleanedInsumos.length,
              'totalCantidad': cleanedInsumos.fold(0, (sum, i) => sum + (i['cantidad'] as int)),
            };
          }
        }
      }
    } else {
      // Datos vienen del modelo local (List<Insumo>)
      if (data is List<Insumo>) {
        return {
          'insumosList': data.map((i) => i.toJson()).toList(),
          'insumos': data.map((i) => '${i.cantidad} - ${i.articulo}').join('\n'),
          'totalInsumos': data.length,
          'totalCantidad': data.fold(0, (sum, i) => sum + i.cantidad),
        };
      }
    }

    return {
      'insumosList': <Map<String, dynamic>>[],
      'insumos': '',
      'totalInsumos': 0,
      'totalCantidad': 0,
    };
  }

  /// Adaptador para datos de personal médico
  static Map<String, dynamic> adaptPersonalMedico(dynamic data, {bool isFromCloud = false}) {
    if (data == null) {
      return {
        'personalMedicoList': <Map<String, dynamic>>[],
        'personalMedico': '',
        'totalPersonal': 0,
      };
    }

    if (isFromCloud) {
      // Datos vienen de la nube (Map<String, dynamic>)
      if (data is Map<String, dynamic>) {
        // Verificar si ya están en formato de lista
        if (data['personalMedicoList'] != null && data['personalMedicoList'] is List) {
          return _normalizePersonalMedicoData(data);
        }
        
        // Buscar personal médico en diferentes ubicaciones
        final personalData = data['personalMedico'] ?? [];
        if (personalData is List) {
          final validation = FrapDataValidator.validatePersonalMedicoData(personalData);
          if (validation.isValid && validation.cleanedData != null) {
            final cleanedPersonal = validation.cleanedData!['personalMedico'] as List;
            return {
              'personalMedicoList': cleanedPersonal,
              'personalMedico': cleanedPersonal.map((p) => 
                '${p['nombre']} - ${p['especialidad']} - ${p['cedula']}'
              ).join('\n'),
              'totalPersonal': cleanedPersonal.length,
            };
          }
        }
      }
    } else {
      // Datos vienen del modelo local (List<PersonalMedico>)
      if (data is List<PersonalMedico>) {
        return {
          'personalMedicoList': data.map((p) => p.toJson()).toList(),
          'personalMedico': data.map((p) => '${p.nombre} - ${p.especialidad} - ${p.cedula}').join('\n'),
          'totalPersonal': data.length,
        };
      }
    }

    return {
      'personalMedicoList': <Map<String, dynamic>>[],
      'personalMedico': '',
      'totalPersonal': 0,
    };
  }

  /// Adaptador para escalas obstétricas
  static Map<String, dynamic> adaptEscalasObstetricas(dynamic data, {bool isFromCloud = false}) {
    if (data == null) {
      return {
        'silvermanAnderson': <String, int>{},
        'apgar': <String, int>{},
        'frecuenciaCardiacaFetal': 0,
        'contracciones': '',
        'hasEscalas': false,
      };
    }

    if (isFromCloud) {
      // Datos vienen de la nube (Map<String, dynamic>)
      if (data is Map<String, dynamic>) {
        final escalasData = data['escalasObstetricas'] ?? data['escalas'] ?? {};
        if (escalasData is Map<String, dynamic>) {
          final validation = FrapDataValidator.validateEscalasObstetricasData(escalasData);
          if (validation.isValid && validation.cleanedData != null) {
            final cleanedData = validation.cleanedData!;
            return {
              'silvermanAnderson': Map<String, int>.from(cleanedData['silvermanAnderson'] ?? {}),
              'apgar': Map<String, int>.from(cleanedData['apgar'] ?? {}),
              'frecuenciaCardiacaFetal': cleanedData['frecuenciaCardiacaFetal'] ?? 0,
              'contracciones': cleanedData['contracciones'] ?? '',
              'hasEscalas': true,
            };
          }
        }
      }
    } else {
      // Datos vienen del modelo local (EscalasObstetricas?)
      if (data is EscalasObstetricas) {
        return {
          'silvermanAnderson': data.silvermanAnderson,
          'apgar': data.apgar,
          'frecuenciaCardiacaFetal': data.frecuenciaCardiacaFetal,
          'contracciones': data.contracciones,
          'hasEscalas': true,
        };
      }
    }

    return {
      'silvermanAnderson': <String, int>{},
      'apgar': <String, int>{},
      'frecuenciaCardiacaFetal': 0,
      'contracciones': '',
      'hasEscalas': false,
    };
  }

  /// Adaptador para consentimiento de servicio
  static Map<String, dynamic> adaptConsentimientoServicio(dynamic data, {bool isFromCloud = false}) {
    if (data == null) {
      return {
        'consentimientoSignature': '',
        'hasConsentimiento': false,
        'timestamp': '',
      };
    }

    if (isFromCloud) {
      // En la nube, el consentimiento puede estar en serviceInfo
      if (data is Map<String, dynamic>) {
        final consentimiento = data['consentimientoSignature'] ?? 
                              data['consentimiento'] ?? 
                              '';
        return {
          'consentimientoSignature': consentimiento,
          'hasConsentimiento': consentimiento.toString().isNotEmpty,
          'timestamp': data['timestamp'] ?? '',
        };
      }
    } else {
      // Datos vienen del modelo local (String)
      if (data is String) {
        return {
          'consentimientoSignature': data,
          'hasConsentimiento': data.isNotEmpty,
          'timestamp': DateTime.now().toIso8601String(),
        };
      }
    }

    return {
      'consentimientoSignature': '',
      'hasConsentimiento': false,
      'timestamp': '',
    };
  }

  /// Adaptador para datos de paciente completos
  static Map<String, dynamic> adaptPatientData(dynamic data, {bool isFromCloud = false}) {
    final defaultData = {
      'firstName': '',
      'paternalLastName': '',
      'maternalLastName': '',
      'age': 0,
      'sex': '',
      'address': '',
      'phone': '',
      'street': '',
      'exteriorNumber': '',
      'interiorNumber': '',
      'neighborhood': '',
      'city': '',
      'insurance': '',
      'responsiblePerson': '',
      'gender': '',
      'entreCalles': '',
      'tipoEntrega': '',
    };

    if (data == null) return defaultData;

    if (isFromCloud) {
      // Datos vienen de la nube (Map<String, dynamic>)
      if (data is Map<String, dynamic>) {
        final validation = FrapDataValidator.validatePatientData(data);
        if (validation.isValid && validation.cleanedData != null) {
          return {...defaultData, ...validation.cleanedData!};
        }
      }
    } else {
      // Datos vienen del modelo local (Patient)
      if (data is Patient) {
        return {
          'firstName': data.firstName,
          'paternalLastName': data.paternalLastName,
          'maternalLastName': data.maternalLastName,
          'age': data.age,
          'sex': data.sex,
          'address': data.address,
          'phone': data.phone,
          'street': data.street,
          'exteriorNumber': data.exteriorNumber,
          'interiorNumber': data.interiorNumber,
          'neighborhood': data.neighborhood,
          'city': data.city,
          'insurance': data.insurance,
          'responsiblePerson': data.responsiblePerson,
          'gender': data.gender,
          'entreCalles': data.entreCalles,
          'tipoEntrega': data.tipoEntrega,
        };
      }
    }

    return defaultData;
  }

  /// Adaptador universal para cualquier registro FRAP
  static Map<String, dynamic> adaptFrapRecord(dynamic record) {
    final adaptedData = <String, dynamic>{};

    if (record is Frap) {
      // Registro local
      adaptedData.addAll({
        'id': record.id,
        'createdAt': record.createdAt,
        'updatedAt': record.updatedAt,
        'isSynced': record.isSynced,
        'isLocal': true,
        'isCloud': false,
      });

      // Datos del paciente
      adaptedData['patientInfo'] = adaptPatientData(record.patient, isFromCloud: false);
      
      // Campos específicos del modelo local
      adaptedData['insumos'] = adaptInsumos(record.insumos, isFromCloud: false);
      adaptedData['personalMedico'] = adaptPersonalMedico(record.personalMedico, isFromCloud: false);
      adaptedData['escalasObstetricas'] = adaptEscalasObstetricas(record.escalasObstetricas, isFromCloud: false);
      adaptedData['consentimientoServicio'] = adaptConsentimientoServicio(record.consentimientoServicio, isFromCloud: false);

      // Secciones comunes
      adaptedData.addAll({
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

    } else if (record is FrapFirestore) {
      // Registro de la nube
      adaptedData.addAll({
        'id': record.id,
        'userId': record.userId,
        'createdAt': record.createdAt,
        'updatedAt': record.updatedAt,
        'isSynced': true,
        'isLocal': false,
        'isCloud': true,
      });

      // Datos del paciente
      adaptedData['patientInfo'] = adaptPatientData(record.patientInfo, isFromCloud: true);
      
      // Campos específicos del modelo local (extraer de secciones de nube)
      adaptedData['insumos'] = adaptInsumos(record.management, isFromCloud: true);
      adaptedData['personalMedico'] = adaptPersonalMedico(record.management, isFromCloud: true);
      adaptedData['escalasObstetricas'] = adaptEscalasObstetricas(record.gynecoObstetric, isFromCloud: true);
      adaptedData['consentimientoServicio'] = adaptConsentimientoServicio(record.serviceInfo, isFromCloud: true);

      // Secciones comunes
      adaptedData.addAll({
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

    } else if (record is FrapTransitionModel) {
      // Modelo de transición - usar el modelo estándar (local)
      if (record.localModel != null) {
        return adaptFrapRecord(record.localModel!);
      } else if (record.cloudModel != null) {
        return adaptFrapRecord(record.cloudModel!);
      }
    }

    return adaptedData;
  }

  /// Normalizar datos de insumos
  static Map<String, dynamic> _normalizeInsumosData(Map<String, dynamic> data) {
    final insumosList = data['insumosList'] as List? ?? [];
    return {
      'insumosList': insumosList,
      'insumos': data['insumos'] ?? '',
      'totalInsumos': data['totalInsumos'] ?? insumosList.length,
      'totalCantidad': data['totalCantidad'] ?? 0,
    };
  }

  /// Normalizar datos de personal médico
  static Map<String, dynamic> _normalizePersonalMedicoData(Map<String, dynamic> data) {
    final personalList = data['personalMedicoList'] as List? ?? [];
    return {
      'personalMedicoList': personalList,
      'personalMedico': data['personalMedico'] ?? '',
      'totalPersonal': data['totalPersonal'] ?? personalList.length,
    };
  }

  /// Detectar el tipo de origen de los datos
  static DataOrigin detectDataOrigin(dynamic data) {
    if (data is Frap) return DataOrigin.local;
    if (data is FrapFirestore) return DataOrigin.cloud;
    if (data is FrapTransitionModel) return DataOrigin.hybrid;
    if (data is Map<String, dynamic>) {
      if (data.containsKey('userId')) return DataOrigin.cloud;
      if (data.containsKey('isSynced')) return DataOrigin.local;
      return DataOrigin.unknown;
    }
    return DataOrigin.unknown;
  }

  /// Obtener campos faltantes en conversión
  static List<String> getMissingFields(Map<String, dynamic> source, DataOrigin targetOrigin) {
    final missingFields = <String>[];
    
    if (targetOrigin == DataOrigin.local) {
      // Verificar campos específicos del modelo local
      if (!source.containsKey('consentimientoServicio') || source['consentimientoServicio'] == null) {
        missingFields.add('consentimientoServicio');
      }
      if (!source.containsKey('insumos') || (source['insumos'] is List && (source['insumos'] as List).isEmpty)) {
        missingFields.add('insumos');
      }
      if (!source.containsKey('personalMedico') || (source['personalMedico'] is List && (source['personalMedico'] as List).isEmpty)) {
        missingFields.add('personalMedico');
      }
      if (!source.containsKey('escalasObstetricas') || source['escalasObstetricas'] == null) {
        missingFields.add('escalasObstetricas');
      }
      if (!source.containsKey('isSynced')) {
        missingFields.add('isSynced');
      }
    } else if (targetOrigin == DataOrigin.cloud) {
      // Verificar campos específicos del modelo nube
      if (!source.containsKey('userId') || source['userId'] == null || source['userId'].toString().isEmpty) {
        missingFields.add('userId');
      }
    }
    
    return missingFields;
  }
}

/// Enum para identificar el origen de los datos
enum DataOrigin {
  local,
  cloud,
  hybrid,
  unknown,
} 