import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'clinical_history.g.dart';

@HiveType(typeId: 1)
class ClinicalHistory extends Equatable {
  // Campos existentes (mantener para compatibilidad)
  @HiveField(0)
  final String allergies;
  @HiveField(1)
  final String medications;
  @HiveField(2)
  final String previousIllnesses;

  // Nuevos campos expandidos
  @HiveField(3)
  final String currentSymptoms;
  @HiveField(4)
  final String pain;
  @HiveField(5)
  final String painScale;
  @HiveField(6)
  final String dosage;
  @HiveField(7)
  final String frequency;
  @HiveField(8)
  final String route;
  @HiveField(9)
  final String time;
  @HiveField(10)
  final String previousSurgeries;
  @HiveField(11)
  final String hospitalizations;
  @HiveField(12)
  final String transfusions;
  @HiveField(13)
  final String horaUltimoAlimento; // SAMPLE: hora de último alimento
  @HiveField(14)
  final String eventosPrevios; // SAMPLE: eventos previos

  const ClinicalHistory({
    // Campos existentes
    required this.allergies,
    required this.medications,
    required this.previousIllnesses,
    // Nuevos campos con valores por defecto
    this.currentSymptoms = '',
    this.pain = '',
    this.painScale = '',
    this.dosage = '',
    this.frequency = '',
    this.route = '',
    this.time = '',
    this.previousSurgeries = '',
    this.hospitalizations = '',
    this.transfusions = '',
    this.horaUltimoAlimento = '',
    this.eventosPrevios = '',
  });

  // Método copyWith para crear copias con cambios
  ClinicalHistory copyWith({
    String? allergies,
    String? medications,
    String? previousIllnesses,
    String? currentSymptoms,
    String? pain,
    String? painScale,
    String? dosage,
    String? frequency,
    String? route,
    String? time,
    String? previousSurgeries,
    String? hospitalizations,
    String? transfusions,
    String? horaUltimoAlimento,
    String? eventosPrevios,
  }) {
    return ClinicalHistory(
      allergies: allergies ?? this.allergies,
      medications: medications ?? this.medications,
      previousIllnesses: previousIllnesses ?? this.previousIllnesses,
      currentSymptoms: currentSymptoms ?? this.currentSymptoms,
      pain: pain ?? this.pain,
      painScale: painScale ?? this.painScale,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      route: route ?? this.route,
      time: time ?? this.time,
      previousSurgeries: previousSurgeries ?? this.previousSurgeries,
      hospitalizations: hospitalizations ?? this.hospitalizations,
      transfusions: transfusions ?? this.transfusions,
      horaUltimoAlimento: horaUltimoAlimento ?? this.horaUltimoAlimento,
      eventosPrevios: eventosPrevios ?? this.eventosPrevios,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'allergies': allergies,
      'medications': medications,
      'previousIllnesses': previousIllnesses,
      'currentSymptoms': currentSymptoms,
      'pain': pain,
      'painScale': painScale,
      'dosage': dosage,
      'frequency': frequency,
      'route': route,
      'time': time,
      'previousSurgeries': previousSurgeries,
      'hospitalizations': hospitalizations,
      'transfusions': transfusions,
      'horaUltimoAlimento': horaUltimoAlimento,
      'eventosPrevios': eventosPrevios,
    };
  }

  @override
  List<Object?> get props => [
        allergies,
        medications,
        previousIllnesses,
        currentSymptoms,
        pain,
        painScale,
        dosage,
        frequency,
        route,
        time,
        previousSurgeries,
        hospitalizations,
        transfusions,
        horaUltimoAlimento,
        eventosPrevios,
      ];
} 