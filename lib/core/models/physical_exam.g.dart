// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'physical_exam.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PhysicalExamAdapter extends TypeAdapter<PhysicalExam> {
  @override
  final int typeId = 2;

  @override
  PhysicalExam read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PhysicalExam(
      vitalSigns: fields[0] as String,
      head: fields[1] as String,
      neck: fields[2] as String,
      thorax: fields[3] as String,
      abdomen: fields[4] as String,
      extremities: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PhysicalExam obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.vitalSigns)
      ..writeByte(1)
      ..write(obj.head)
      ..writeByte(2)
      ..write(obj.neck)
      ..writeByte(3)
      ..write(obj.thorax)
      ..writeByte(4)
      ..write(obj.abdomen)
      ..writeByte(5)
      ..write(obj.extremities);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhysicalExamAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
