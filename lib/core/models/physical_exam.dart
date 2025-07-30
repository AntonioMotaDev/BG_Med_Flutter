import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'physical_exam.g.dart';

@HiveType(typeId: 2)
class PhysicalExam extends Equatable {
  // Campos existentes (mantener para compatibilidad)
  @HiveField(0)
  final String vitalSigns;
  @HiveField(1)
  final String head;
  @HiveField(2)
  final String neck;
  @HiveField(3)
  final String thorax;
  @HiveField(4)
  final String abdomen;
  @HiveField(5)
  final String extremities;

  // Nuevos campos expandidos
  @HiveField(6)
  final String bloodPressure;
  @HiveField(7)
  final String heartRate;
  @HiveField(8)
  final String respiratoryRate;
  @HiveField(9)
  final String temperature;
  @HiveField(10)
  final String oxygenSaturation;
  @HiveField(11)
  final String neurological;
  @HiveField(12)
  final int eva; // Escala EVA (0-10)
  @HiveField(13)
  final int llc; // LLC en segundos
  @HiveField(14)
  final int glucosa; // Glucosa mg/dl
  @HiveField(15)
  final String ta; // Tensión arterial mm/Hg

  const PhysicalExam({
    // Campos existentes
    required this.vitalSigns,
    required this.head,
    required this.neck,
    required this.thorax,
    required this.abdomen,
    required this.extremities,
    // Nuevos campos con valores por defecto
    this.bloodPressure = '',
    this.heartRate = '',
    this.respiratoryRate = '',
    this.temperature = '',
    this.oxygenSaturation = '',
    this.neurological = '',
    this.eva = 0,
    this.llc = 0,
    this.glucosa = 0,
    this.ta = '',
  });

  // Método copyWith para crear copias con cambios
  PhysicalExam copyWith({
    String? vitalSigns,
    String? head,
    String? neck,
    String? thorax,
    String? abdomen,
    String? extremities,
    String? bloodPressure,
    String? heartRate,
    String? respiratoryRate,
    String? temperature,
    String? oxygenSaturation,
    String? neurological,
    int? eva,
    int? llc,
    int? glucosa,
    String? ta,
  }) {
    return PhysicalExam(
      vitalSigns: vitalSigns ?? this.vitalSigns,
      head: head ?? this.head,
      neck: neck ?? this.neck,
      thorax: thorax ?? this.thorax,
      abdomen: abdomen ?? this.abdomen,
      extremities: extremities ?? this.extremities,
      bloodPressure: bloodPressure ?? this.bloodPressure,
      heartRate: heartRate ?? this.heartRate,
      respiratoryRate: respiratoryRate ?? this.respiratoryRate,
      temperature: temperature ?? this.temperature,
      oxygenSaturation: oxygenSaturation ?? this.oxygenSaturation,
      neurological: neurological ?? this.neurological,
      eva: eva ?? this.eva,
      llc: llc ?? this.llc,
      glucosa: glucosa ?? this.glucosa,
      ta: ta ?? this.ta,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vitalSigns': vitalSigns,
      'head': head,
      'neck': neck,
      'thorax': thorax,
      'abdomen': abdomen,
      'extremities': extremities,
      'eva': eva,
      'llc': llc,
      'glucosa': glucosa,
      'ta': ta,
    };
  }

  @override
  List<Object?> get props => [
        vitalSigns,
        head,
        neck,
        thorax,
        abdomen,
        extremities,
        bloodPressure,
        heartRate,
        respiratoryRate,
        temperature,
        oxygenSaturation,
        neurological,
        eva,
        llc,
        glucosa,
        ta,
      ];
} 