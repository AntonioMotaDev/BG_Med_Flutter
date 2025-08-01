/// Mapeo y conversión de datos entre diferentes formatos de FRAP
class FrapConversionMapping {
  
  /// Mapeo de campos del paciente
  static Map<String, String> patientFieldMapping = {
    // Campos básicos
    'name': 'name',
    'age': 'age',
    'sex': 'sex',
    'address': 'address',
    
    // Campos expandidos
    'firstName': 'firstName',
    'paternalLastName': 'paternalLastName',
    'maternalLastName': 'maternalLastName',
    'phone': 'phone',
    'street': 'street',
    'exteriorNumber': 'exteriorNumber',
    'interiorNumber': 'interiorNumber',
    'neighborhood': 'neighborhood',
    'city': 'city',
    'insurance': 'insurance',
    'responsiblePerson': 'responsiblePerson',
    'gender': 'gender',
    'entreCalles': 'entreCalles',
    'tipoEntrega': 'tipoEntrega',
  };

  /// Mapeo de campos de historia clínica
  static Map<String, String> clinicalHistoryFieldMapping = {
    'allergies': 'allergies',
    'medications': 'medications',
    'previousIllnesses': 'previousIllnesses',
  };

  /// Mapeo de campos de examen físico
  static Map<String, String> physicalExamFieldMapping = {
    'vitalSigns': 'vitalSigns',
    'head': 'head',
    'neck': 'neck',
    'thorax': 'thorax',
    'abdomen': 'abdomen',
    'extremities': 'extremities',
    'bloodPressure': 'bloodPressure',
    'heartRate': 'heartRate',
    'respiratoryRate': 'respiratoryRate',
    'temperature': 'temperature',
    'oxygenSaturation': 'oxygenSaturation',
    'neurological': 'neurological',
  };

  /// Mapeo de campos de insumos
  static Map<String, String> insumoFieldMapping = {
    'cantidad': 'cantidad',
    'articulo': 'articulo',
  };

  /// Mapeo de campos de personal médico
  static Map<String, String> personalMedicoFieldMapping = {
    'nombre': 'nombre',
    'especialidad': 'especialidad',
    'cedula': 'cedula',
  };

  /// Mapeo de campos de escalas obstétricas
  static Map<String, String> escalasObstetricasFieldMapping = {
    'silvermanAnderson': 'silvermanAnderson',
    'apgar': 'apgar',
    'frecuenciaCardiacaFetal': 'frecuenciaCardiacaFetal',
    'contracciones': 'contracciones',
  };

  /// Secciones que existen en ambos modelos
  static List<String> commonSections = [
    'serviceInfo',
    'registryInfo',
    'management',
    'medications',
    'gynecoObstetric',
    'attentionNegative',
    'pathologicalHistory',
    'priorityJustification',
    'injuryLocation',
    'receivingUnit',
    'patientReception',
  ];

  /// Campos que solo existen en el modelo local
  static List<String> localOnlyFields = [
    'consentimientoServicio',
    'insumos',
    'personalMedico',
    'escalasObstetricas',
    'isSynced',
  ];

  /// Campos que solo existen en el modelo nube
  static List<String> cloudOnlyFields = [
    'userId',
  ];

  /// Validar si un campo existe en el modelo local
  static bool isLocalField(String fieldName) {
    return patientFieldMapping.containsKey(fieldName) ||
           clinicalHistoryFieldMapping.containsKey(fieldName) ||
           physicalExamFieldMapping.containsKey(fieldName) ||
           insumoFieldMapping.containsKey(fieldName) ||
           personalMedicoFieldMapping.containsKey(fieldName) ||
           escalasObstetricasFieldMapping.containsKey(fieldName) ||
           localOnlyFields.contains(fieldName);
  }

  /// Validar si un campo existe en el modelo nube
  static bool isCloudField(String fieldName) {
    return patientFieldMapping.containsKey(fieldName) ||
           clinicalHistoryFieldMapping.containsKey(fieldName) ||
           physicalExamFieldMapping.containsKey(fieldName) ||
           cloudOnlyFields.contains(fieldName);
  }

  /// Obtener el campo correspondiente en el modelo opuesto
  static String? getCorrespondingField(String fieldName, bool toLocal) {
    if (toLocal) {
      // Buscar en mapeos de nube a local
      return patientFieldMapping[fieldName] ??
             clinicalHistoryFieldMapping[fieldName] ??
             physicalExamFieldMapping[fieldName] ??
             insumoFieldMapping[fieldName] ??
             personalMedicoFieldMapping[fieldName] ??
             escalasObstetricasFieldMapping[fieldName];
    } else {
      // Buscar en mapeos de local a nube
      final reverseMapping = <String, String>{};
      patientFieldMapping.forEach((key, value) => reverseMapping[value] = key);
      clinicalHistoryFieldMapping.forEach((key, value) => reverseMapping[value] = key);
      physicalExamFieldMapping.forEach((key, value) => reverseMapping[value] = key);
      insumoFieldMapping.forEach((key, value) => reverseMapping[value] = key);
      personalMedicoFieldMapping.forEach((key, value) => reverseMapping[value] = key);
      escalasObstetricasFieldMapping.forEach((key, value) => reverseMapping[value] = key);
      
      return reverseMapping[fieldName];
    }
  }

  /// Generar reporte de diferencias entre modelos
  static Map<String, dynamic> generateDifferenceReport() {
    final report = <String, dynamic>{
      'localOnlyFields': localOnlyFields,
      'cloudOnlyFields': cloudOnlyFields,
      'commonSections': commonSections,
      'totalLocalFields': patientFieldMapping.length + 
                         clinicalHistoryFieldMapping.length + 
                         physicalExamFieldMapping.length + 
                         insumoFieldMapping.length + 
                         personalMedicoFieldMapping.length + 
                         escalasObstetricasFieldMapping.length + 
                         localOnlyFields.length,
      'totalCloudFields': patientFieldMapping.length + 
                          clinicalHistoryFieldMapping.length + 
                          physicalExamFieldMapping.length + 
                          cloudOnlyFields.length,
    };

    return report;
  }
} 