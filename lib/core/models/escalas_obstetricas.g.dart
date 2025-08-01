// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'escalas_obstetricas.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EscalasObstetricasAdapter extends TypeAdapter<EscalasObstetricas> {
  @override
  final int typeId = 23;

  @override
  EscalasObstetricas read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EscalasObstetricas(
      silvermanAnderson: (fields[0] as Map).cast<String, int>(),
      apgar: (fields[1] as Map).cast<String, int>(),
      frecuenciaCardiacaFetal: fields[2] as int,
      contracciones: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, EscalasObstetricas obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.silvermanAnderson)
      ..writeByte(1)
      ..write(obj.apgar)
      ..writeByte(2)
      ..write(obj.frecuenciaCardiacaFetal)
      ..writeByte(3)
      ..write(obj.contracciones);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EscalasObstetricasAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
