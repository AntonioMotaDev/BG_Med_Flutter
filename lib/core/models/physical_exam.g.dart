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
      eva: fields[0] as String,
      llc: fields[1] as String,
      glucosa: fields[2] as String,
      ta: fields[3] as String,
      sampleAlergias: fields[4] as String,
      sampleMedicamentos: fields[5] as String,
      sampleEnfermedades: fields[6] as String,
      sampleHoraAlimento: fields[7] as String,
      sampleEventosPrevios: fields[8] as String,
      timeColumns: (fields[9] as List).cast<String>(),
      vitalSignsData: (fields[10] as Map).map((dynamic k, dynamic v) =>
          MapEntry(k as String, (v as Map).cast<String, String>())),
      timestamp: fields[11] as String,
      vitalSigns: fields[12] as String,
      head: fields[13] as String,
      neck: fields[14] as String,
      thorax: fields[15] as String,
      abdomen: fields[16] as String,
      extremities: fields[17] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PhysicalExam obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.eva)
      ..writeByte(1)
      ..write(obj.llc)
      ..writeByte(2)
      ..write(obj.glucosa)
      ..writeByte(3)
      ..write(obj.ta)
      ..writeByte(4)
      ..write(obj.sampleAlergias)
      ..writeByte(5)
      ..write(obj.sampleMedicamentos)
      ..writeByte(6)
      ..write(obj.sampleEnfermedades)
      ..writeByte(7)
      ..write(obj.sampleHoraAlimento)
      ..writeByte(8)
      ..write(obj.sampleEventosPrevios)
      ..writeByte(9)
      ..write(obj.timeColumns)
      ..writeByte(10)
      ..write(obj.vitalSignsData)
      ..writeByte(11)
      ..write(obj.timestamp)
      ..writeByte(12)
      ..write(obj.vitalSigns)
      ..writeByte(13)
      ..write(obj.head)
      ..writeByte(14)
      ..write(obj.neck)
      ..writeByte(15)
      ..write(obj.thorax)
      ..writeByte(16)
      ..write(obj.abdomen)
      ..writeByte(17)
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
