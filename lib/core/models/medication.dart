import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'medication.g.dart';

@HiveType(typeId: 20)
class Medication extends Equatable {
  @HiveField(0)
  final String medicamento;
  @HiveField(1)
  final String dosis;
  @HiveField(2)
  final String viaAdministracion;
  @HiveField(3)
  final String hora;
  @HiveField(4)
  final String medicoIndico;

  const Medication({
    this.medicamento = '',
    this.dosis = '',
    this.viaAdministracion = '',
    this.hora = '',
    this.medicoIndico = '',
  });

  Medication copyWith({
    String? medicamento,
    String? dosis,
    String? viaAdministracion,
    String? hora,
    String? medicoIndico,
  }) {
    return Medication(
      medicamento: medicamento ?? this.medicamento,
      dosis: dosis ?? this.dosis,
      viaAdministracion: viaAdministracion ?? this.viaAdministracion,
      hora: hora ?? this.hora,
      medicoIndico: medicoIndico ?? this.medicoIndico,
    );
  }

  Map<String, dynamic> toJson() => {
    'medicamento': medicamento,
    'dosis': dosis,
    'viaAdministracion': viaAdministracion,
    'hora': hora,
    'medicoIndico': medicoIndico,
  };

  @override
  List<Object?> get props => [medicamento, dosis, viaAdministracion, hora, medicoIndico];
} 