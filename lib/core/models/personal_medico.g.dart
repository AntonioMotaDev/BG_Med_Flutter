// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'personal_medico.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PersonalMedicoAdapter extends TypeAdapter<PersonalMedico> {
  @override
  final int typeId = 22;

  @override
  PersonalMedico read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PersonalMedico(
      nombre: fields[0] as String,
      especialidad: fields[1] as String,
      cedula: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PersonalMedico obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.nombre)
      ..writeByte(1)
      ..write(obj.especialidad)
      ..writeByte(2)
      ..write(obj.cedula);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PersonalMedicoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
