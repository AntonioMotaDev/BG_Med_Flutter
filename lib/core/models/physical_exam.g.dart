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
      bloodPressure: fields[6] as String,
      heartRate: fields[7] as String,
      respiratoryRate: fields[8] as String,
      temperature: fields[9] as String,
      oxygenSaturation: fields[10] as String,
      neurological: fields[11] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PhysicalExam obj) {
    writer
      ..writeByte(12)
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
      ..write(obj.extremities)
      ..writeByte(6)
      ..write(obj.bloodPressure)
      ..writeByte(7)
      ..write(obj.heartRate)
      ..writeByte(8)
      ..write(obj.respiratoryRate)
      ..writeByte(9)
      ..write(obj.temperature)
      ..writeByte(10)
      ..write(obj.oxygenSaturation)
      ..writeByte(11)
      ..write(obj.neurological);
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
