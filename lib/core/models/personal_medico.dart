import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'personal_medico.g.dart';

@HiveType(typeId: 22)
class PersonalMedico extends Equatable {
  @HiveField(0)
  final String nombre;
  @HiveField(1)
  final String especialidad;
  @HiveField(2)
  final String cedula;

  const PersonalMedico({
    this.nombre = '',
    this.especialidad = '',
    this.cedula = '',
  });

  PersonalMedico copyWith({
    String? nombre,
    String? especialidad,
    String? cedula,
  }) {
    return PersonalMedico(
      nombre: nombre ?? this.nombre,
      especialidad: especialidad ?? this.especialidad,
      cedula: cedula ?? this.cedula,
    );
  }

  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'especialidad': especialidad,
    'cedula': cedula,
  };

  @override
  List<Object?> get props => [nombre, especialidad, cedula];
} 