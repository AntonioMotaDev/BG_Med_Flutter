import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class FrapFirestore extends Equatable {
  final String? id;
  final String userId; // ID del usuario que creó el registro
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Información del Servicio
  final Map<String, dynamic> serviceInfo;
  
  // Información del Registro
  final Map<String, dynamic> registryInfo;
  
  // Información del Paciente
  final Map<String, dynamic> patientInfo;
  
  // Manejo
  final Map<String, dynamic> management;
  
  // Medicamentos
  final Map<String, dynamic> medications;
  
  // Gineco-Obstétrico
  final Map<String, dynamic> gynecoObstetric;
  
  // Negativa de Atención
  final Map<String, dynamic> attentionNegative;
  
  // Antecedentes Patológicos
  final Map<String, dynamic> pathologicalHistory;
  
  // Historia Clínica
  final Map<String, dynamic> clinicalHistory;
  
  // Examen Físico
  final Map<String, dynamic> physicalExam;
  
  // Justificación de Prioridad
  final Map<String, dynamic> priorityJustification;
  
  // Localización de Lesiones
  final Map<String, dynamic> injuryLocation;
  
  // Unidad Receptora
  final Map<String, dynamic> receivingUnit;
  
  // Recepción del Paciente
  final Map<String, dynamic> patientReception;

  const FrapFirestore({
    this.id,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.serviceInfo = const {},
    this.registryInfo = const {},
    this.patientInfo = const {},
    this.management = const {},
    this.medications = const {},
    this.gynecoObstetric = const {},
    this.attentionNegative = const {},
    this.pathologicalHistory = const {},
    this.clinicalHistory = const {},
    this.physicalExam = const {},
    this.priorityJustification = const {},
    this.injuryLocation = const {},
    this.receivingUnit = const {},
    this.patientReception = const {},
  });

  // Factory constructor desde Firestore
  factory FrapFirestore.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Helper function para convertir timestamps de manera segura
    DateTime _parseTimestamp(dynamic timestamp) {
      if (timestamp == null) {
        return DateTime.now();
      }
      if (timestamp is Timestamp) {
        return timestamp.toDate();
      }
      if (timestamp is String) {
        return DateTime.parse(timestamp);
      }
      return DateTime.now();
    }
    
    // Helper function para convertir Maps de manera segura
    Map<String, dynamic> _parseMap(dynamic mapData) {
      if (mapData == null) return {};
      if (mapData is Map<String, dynamic>) return mapData;
      return {};
    }
    
    return FrapFirestore(
      id: doc.id,
      userId: data['userId'] ?? '',
      createdAt: _parseTimestamp(data['createdAt']),
      updatedAt: _parseTimestamp(data['updatedAt']),
      serviceInfo: _parseMap(data['serviceInfo']),
      registryInfo: _parseMap(data['registryInfo']),
      patientInfo: _parseMap(data['patientInfo']),
      management: _parseMap(data['management']),
      medications: _parseMap(data['medications']),
      gynecoObstetric: _parseMap(data['gynecoObstetric']),
      attentionNegative: _parseMap(data['attentionNegative']),
      pathologicalHistory: _parseMap(data['pathologicalHistory']),
      clinicalHistory: _parseMap(data['clinicalHistory']),
      physicalExam: _parseMap(data['physicalExam']),
      priorityJustification: _parseMap(data['priorityJustification']),
      injuryLocation: _parseMap(data['injuryLocation']),
      receivingUnit: _parseMap(data['receivingUnit']),
      patientReception: _parseMap(data['patientReception']),
    );
  }

  // Factory constructor desde Map
  factory FrapFirestore.fromMap(Map<String, dynamic> data, String id) {
    DateTime _parseTimestamp(dynamic timestamp) {
      if (timestamp == null) {
        return DateTime.now();
      }
      if (timestamp is Timestamp) {
        return timestamp.toDate();
      }
      if (timestamp is String) {
        try {
          return DateTime.parse(timestamp);
        } catch (e) {
          return DateTime.now();
        }
      }
      return DateTime.now();
    }
    
    Map<String, dynamic> _parseMap(dynamic mapData) {
      if (mapData == null) return {};
      if (mapData is Map<String, dynamic>) return mapData;
      return {};
    }
    
    return FrapFirestore(
      id: id,
      userId: data['userId'] ?? '',
      createdAt: _parseTimestamp(data['createdAt']),
      updatedAt: _parseTimestamp(data['updatedAt']),
      serviceInfo: _parseMap(data['serviceInfo']),
      registryInfo: _parseMap(data['registryInfo']),
      patientInfo: _parseMap(data['patientInfo']),
      management: _parseMap(data['management']),
      medications: _parseMap(data['medications']),
      gynecoObstetric: _parseMap(data['gynecoObstetric']),
      attentionNegative: _parseMap(data['attentionNegative']),
      pathologicalHistory: _parseMap(data['pathologicalHistory']),
      clinicalHistory: _parseMap(data['clinicalHistory']),
      physicalExam: _parseMap(data['physicalExam']),
      priorityJustification: _parseMap(data['priorityJustification']),
      injuryLocation: _parseMap(data['injuryLocation']),
      receivingUnit: _parseMap(data['receivingUnit']),
      patientReception: _parseMap(data['patientReception']),
    );
  }

  // Convertir a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'serviceInfo': serviceInfo,
      'registryInfo': registryInfo,
      'patientInfo': patientInfo,
      'management': management,
      'medications': medications,
      'gynecoObstetric': gynecoObstetric,
      'attentionNegative': attentionNegative,
      'pathologicalHistory': pathologicalHistory,
      'clinicalHistory': clinicalHistory,
      'physicalExam': physicalExam,
      'priorityJustification': priorityJustification,
      'injuryLocation': injuryLocation,
      'receivingUnit': receivingUnit,
      'patientReception': patientReception,
    };
  }

  // Convertir a Map sin timestamps (para casos especiales)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'serviceInfo': serviceInfo,
      'registryInfo': registryInfo,
      'patientInfo': patientInfo,
      'management': management,
      'medications': medications,
      'gynecoObstetric': gynecoObstetric,
      'attentionNegative': attentionNegative,
      'pathologicalHistory': pathologicalHistory,
      'clinicalHistory': clinicalHistory,
      'physicalExam': physicalExam,
      'priorityJustification': priorityJustification,
      'injuryLocation': injuryLocation,
      'receivingUnit': receivingUnit,
      'patientReception': patientReception,
    };
  }

  // Método para crear una copia con campos actualizados
  FrapFirestore copyWith({
    String? id,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? serviceInfo,
    Map<String, dynamic>? registryInfo,
    Map<String, dynamic>? patientInfo,
    Map<String, dynamic>? management,
    Map<String, dynamic>? medications,
    Map<String, dynamic>? gynecoObstetric,
    Map<String, dynamic>? attentionNegative,
    Map<String, dynamic>? pathologicalHistory,
    Map<String, dynamic>? clinicalHistory,
    Map<String, dynamic>? physicalExam,
    Map<String, dynamic>? priorityJustification,
    Map<String, dynamic>? injuryLocation,
    Map<String, dynamic>? receivingUnit,
    Map<String, dynamic>? patientReception,
  }) {
    return FrapFirestore(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      serviceInfo: serviceInfo ?? this.serviceInfo,
      registryInfo: registryInfo ?? this.registryInfo,
      patientInfo: patientInfo ?? this.patientInfo,
      management: management ?? this.management,
      medications: medications ?? this.medications,
      gynecoObstetric: gynecoObstetric ?? this.gynecoObstetric,
      attentionNegative: attentionNegative ?? this.attentionNegative,
      pathologicalHistory: pathologicalHistory ?? this.pathologicalHistory,
      clinicalHistory: clinicalHistory ?? this.clinicalHistory,
      physicalExam: physicalExam ?? this.physicalExam,
      priorityJustification: priorityJustification ?? this.priorityJustification,
      injuryLocation: injuryLocation ?? this.injuryLocation,
      receivingUnit: receivingUnit ?? this.receivingUnit,
      patientReception: patientReception ?? this.patientReception,
    );
  }

  // Factory constructor para crear un nuevo registro
  factory FrapFirestore.create({
    required String userId,
    Map<String, dynamic>? serviceInfo,
    Map<String, dynamic>? registryInfo,
    Map<String, dynamic>? patientInfo,
    Map<String, dynamic>? management,
    Map<String, dynamic>? medications,
    Map<String, dynamic>? gynecoObstetric,
    Map<String, dynamic>? attentionNegative,
    Map<String, dynamic>? pathologicalHistory,
    Map<String, dynamic>? clinicalHistory,
    Map<String, dynamic>? physicalExam,
    Map<String, dynamic>? priorityJustification,
    Map<String, dynamic>? injuryLocation,
    Map<String, dynamic>? receivingUnit,
    Map<String, dynamic>? patientReception,
  }) {
    final now = DateTime.now();
    return FrapFirestore(
      userId: userId,
      createdAt: now,
      updatedAt: now,
      serviceInfo: serviceInfo ?? {},
      registryInfo: registryInfo ?? {},
      patientInfo: patientInfo ?? {},
      management: management ?? {},
      medications: medications ?? {},
      gynecoObstetric: gynecoObstetric ?? {},
      attentionNegative: attentionNegative ?? {},
      pathologicalHistory: pathologicalHistory ?? {},
      clinicalHistory: clinicalHistory ?? {},
      physicalExam: physicalExam ?? {},
      priorityJustification: priorityJustification ?? {},
      injuryLocation: injuryLocation ?? {},
      receivingUnit: receivingUnit ?? {},
      patientReception: patientReception ?? {},
    );
  }

  // Obtener nombre del paciente desde patientInfo
  String get patientName {
    final firstName = patientInfo['firstName'] ?? '';
    final paternalLastName = patientInfo['paternalLastName'] ?? '';
    final maternalLastName = patientInfo['maternalLastName'] ?? '';
    
    if (firstName.isEmpty && paternalLastName.isEmpty && maternalLastName.isEmpty) {
      return 'Sin nombre';
    }
    
    return '$firstName $paternalLastName $maternalLastName'.trim();
  }

  // Obtener edad del paciente
  int get patientAge {
    return patientInfo['age'] ?? 0;
  }

  // Obtener género del paciente
  String get patientGender {
    return patientInfo['sex'] ?? ''; // Cambiado de gender a sex
  }

  // Verificar si el registro está completo
  bool get isComplete {
    return serviceInfo.isNotEmpty &&
           registryInfo.isNotEmpty &&
           patientInfo.isNotEmpty &&
           management.isNotEmpty;
  }

  // Obtener porcentaje de completitud
  double get completionPercentage {
    int totalSections = 14;
    int completedSections = 0;
    
    if (serviceInfo.isNotEmpty) completedSections++;
    if (registryInfo.isNotEmpty) completedSections++;
    if (patientInfo.isNotEmpty) completedSections++;
    if (management.isNotEmpty) completedSections++;
    if (medications.isNotEmpty) completedSections++;
    if (gynecoObstetric.isNotEmpty) completedSections++;
    if (attentionNegative.isNotEmpty) completedSections++;
    if (pathologicalHistory.isNotEmpty) completedSections++;
    if (clinicalHistory.isNotEmpty) completedSections++;
    if (physicalExam.isNotEmpty) completedSections++;
    if (priorityJustification.isNotEmpty) completedSections++;
    if (injuryLocation.isNotEmpty) completedSections++;
    if (receivingUnit.isNotEmpty) completedSections++;
    if (patientReception.isNotEmpty) completedSections++;
    
    return (completedSections / totalSections) * 100;
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        createdAt,
        updatedAt,
        serviceInfo,
        registryInfo,
        patientInfo,
        management,
        medications,
        gynecoObstetric,
        attentionNegative,
        pathologicalHistory,
        clinicalHistory,
        physicalExam,
        priorityJustification,
        injuryLocation,
        receivingUnit,
        patientReception,
      ];

  @override
  String toString() {
    return 'FrapFirestore(id: $id, patient: $patientName, age: $patientAge, completion: ${completionPercentage.toStringAsFixed(1)}%)';
  }
} 