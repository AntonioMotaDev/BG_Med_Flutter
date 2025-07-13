import 'package:bg_med/core/models/clinical_history.dart';
import 'package:bg_med/core/models/patient.dart';
import 'package:bg_med/core/models/physical_exam.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'frap.g.dart';

@HiveType(typeId: 3)
class Frap extends Equatable {
  // Campos existentes (mantener para compatibilidad)
  @HiveField(0)
  final String id;
  @HiveField(1)
  final Patient patient;
  @HiveField(2)
  final ClinicalHistory clinicalHistory;
  @HiveField(3)
  final PhysicalExam physicalExam;
  @HiveField(4)
  final DateTime createdAt;

  // Nuevos campos expandidos
  @HiveField(5)
  final DateTime updatedAt;
  
  // Nuevas secciones como Map<String, dynamic>
  @HiveField(6)
  final Map<String, dynamic> serviceInfo;
  @HiveField(7)
  final Map<String, dynamic> registryInfo;
  @HiveField(8)
  final Map<String, dynamic> management;
  @HiveField(9)
  final Map<String, dynamic> medications;
  @HiveField(10)
  final Map<String, dynamic> gynecoObstetric;
  @HiveField(11)
  final Map<String, dynamic> attentionNegative;
  @HiveField(12)
  final Map<String, dynamic> pathologicalHistory;
  @HiveField(13)
  final Map<String, dynamic> priorityJustification;
  @HiveField(14)
  final Map<String, dynamic> injuryLocation;
  @HiveField(15)
  final Map<String, dynamic> receivingUnit;
  @HiveField(16)
  final Map<String, dynamic> patientReception;

  const Frap({
    // Campos existentes
    required this.id,
    required this.patient,
    required this.clinicalHistory,
    required this.physicalExam,
    required this.createdAt,
    // Nuevos campos con valores por defecto
    DateTime? updatedAt,
    this.serviceInfo = const {},
    this.registryInfo = const {},
    this.management = const {},
    this.medications = const {},
    this.gynecoObstetric = const {},
    this.attentionNegative = const {},
    this.pathologicalHistory = const {},
    this.priorityJustification = const {},
    this.injuryLocation = const {},
    this.receivingUnit = const {},
    this.patientReception = const {},
  }) : updatedAt = updatedAt ?? createdAt;

  // Método copyWith para crear copias con cambios
  Frap copyWith({
    String? id,
    Patient? patient,
    ClinicalHistory? clinicalHistory,
    PhysicalExam? physicalExam,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? serviceInfo,
    Map<String, dynamic>? registryInfo,
    Map<String, dynamic>? management,
    Map<String, dynamic>? medications,
    Map<String, dynamic>? gynecoObstetric,
    Map<String, dynamic>? attentionNegative,
    Map<String, dynamic>? pathologicalHistory,
    Map<String, dynamic>? priorityJustification,
    Map<String, dynamic>? injuryLocation,
    Map<String, dynamic>? receivingUnit,
    Map<String, dynamic>? patientReception,
  }) {
    return Frap(
      id: id ?? this.id,
      patient: patient ?? this.patient,
      clinicalHistory: clinicalHistory ?? this.clinicalHistory,
      physicalExam: physicalExam ?? this.physicalExam,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      serviceInfo: serviceInfo ?? this.serviceInfo,
      registryInfo: registryInfo ?? this.registryInfo,
      management: management ?? this.management,
      medications: medications ?? this.medications,
      gynecoObstetric: gynecoObstetric ?? this.gynecoObstetric,
      attentionNegative: attentionNegative ?? this.attentionNegative,
      pathologicalHistory: pathologicalHistory ?? this.pathologicalHistory,
      priorityJustification: priorityJustification ?? this.priorityJustification,
      injuryLocation: injuryLocation ?? this.injuryLocation,
      receivingUnit: receivingUnit ?? this.receivingUnit,
      patientReception: patientReception ?? this.patientReception,
    );
  }

  // Método para actualizar una sección específica
  Frap updateSection(String sectionName, Map<String, dynamic> sectionData) {
    switch (sectionName) {
      case 'serviceInfo':
        return copyWith(serviceInfo: sectionData);
      case 'registryInfo':
        return copyWith(registryInfo: sectionData);
      case 'management':
        return copyWith(management: sectionData);
      case 'medications':
        return copyWith(medications: sectionData);
      case 'gynecoObstetric':
        return copyWith(gynecoObstetric: sectionData);
      case 'attentionNegative':
        return copyWith(attentionNegative: sectionData);
      case 'pathologicalHistory':
        return copyWith(pathologicalHistory: sectionData);
      case 'priorityJustification':
        return copyWith(priorityJustification: sectionData);
      case 'injuryLocation':
        return copyWith(injuryLocation: sectionData);
      case 'receivingUnit':
        return copyWith(receivingUnit: sectionData);
      case 'patientReception':
        return copyWith(patientReception: sectionData);
      default:
        return this;
    }
  }

  // Método para obtener una sección específica
  Map<String, dynamic> getSection(String sectionName) {
    switch (sectionName) {
      case 'serviceInfo':
        return serviceInfo;
      case 'registryInfo':
        return registryInfo;
      case 'management':
        return management;
      case 'medications':
        return medications;
      case 'gynecoObstetric':
        return gynecoObstetric;
      case 'attentionNegative':
        return attentionNegative;
      case 'pathologicalHistory':
        return pathologicalHistory;
      case 'priorityJustification':
        return priorityJustification;
      case 'injuryLocation':
        return injuryLocation;
      case 'receivingUnit':
        return receivingUnit;
      case 'patientReception':
        return patientReception;
      default:
        return {};
    }
  }

  // Método para verificar si una sección tiene datos
  bool hasSectionData(String sectionName) {
    final section = getSection(sectionName);
    return section.isNotEmpty && section.values.any((value) => 
      value != null && value.toString().trim().isNotEmpty
    );
  }

  // Método para calcular completitud del registro
  double get completionPercentage {
    int totalSections = 14;
    int completedSections = 0;
    
    // Secciones básicas (siempre presentes)
    if (patient.name.isNotEmpty) completedSections++;
    if (clinicalHistory.allergies.isNotEmpty || clinicalHistory.medications.isNotEmpty) completedSections++;
    if (physicalExam.vitalSigns.isNotEmpty) completedSections++;
    
    // Nuevas secciones
    if (hasSectionData('serviceInfo')) completedSections++;
    if (hasSectionData('registryInfo')) completedSections++;
    if (hasSectionData('management')) completedSections++;
    if (hasSectionData('medications')) completedSections++;
    if (hasSectionData('gynecoObstetric')) completedSections++;
    if (hasSectionData('attentionNegative')) completedSections++;
    if (hasSectionData('pathologicalHistory')) completedSections++;
    if (hasSectionData('priorityJustification')) completedSections++;
    if (hasSectionData('injuryLocation')) completedSections++;
    if (hasSectionData('receivingUnit')) completedSections++;
    if (hasSectionData('patientReception')) completedSections++;
    
    return (completedSections / totalSections) * 100;
  }

  @override
  List<Object?> get props => [
        id,
        patient,
        clinicalHistory,
        physicalExam,
        createdAt,
        updatedAt,
        serviceInfo,
        registryInfo,
        management,
        medications,
        gynecoObstetric,
        attentionNegative,
        pathologicalHistory,
        priorityJustification,
        injuryLocation,
        receivingUnit,
        patientReception,
      ];
} 