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
    );
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
      ];
} 