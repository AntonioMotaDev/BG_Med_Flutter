// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medication.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MedicationAdapter extends TypeAdapter<Medication> {
  @override
  final int typeId = 20;

  @override
  Medication read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Medication(
      medicamento: fields[0] as String,
      dosis: fields[1] as String,
      viaAdministracion: fields[2] as String,
      hora: fields[3] as String,
      medicoIndico: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Medication obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.medicamento)
      ..writeByte(1)
      ..write(obj.dosis)
      ..writeByte(2)
      ..write(obj.viaAdministracion)
      ..writeByte(3)
      ..write(obj.hora)
      ..writeByte(4)
      ..write(obj.medicoIndico);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
