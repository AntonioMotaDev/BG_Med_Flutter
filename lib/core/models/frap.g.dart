// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'frap.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FrapAdapter extends TypeAdapter<Frap> {
  @override
  final int typeId = 3;

  @override
  Frap read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Frap(
      id: fields[0] as String,
      patient: fields[1] as Patient,
      clinicalHistory: fields[2] as ClinicalHistory,
      physicalExam: fields[3] as PhysicalExam,
      createdAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Frap obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.patient)
      ..writeByte(2)
      ..write(obj.clinicalHistory)
      ..writeByte(3)
      ..write(obj.physicalExam)
      ..writeByte(4)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FrapAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
