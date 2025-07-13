// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clinical_history.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ClinicalHistoryAdapter extends TypeAdapter<ClinicalHistory> {
  @override
  final int typeId = 1;

  @override
  ClinicalHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ClinicalHistory(
      allergies: fields[0] as String,
      medications: fields[1] as String,
      previousIllnesses: fields[2] as String,
      currentSymptoms: fields[3] as String,
      pain: fields[4] as String,
      painScale: fields[5] as String,
      dosage: fields[6] as String,
      frequency: fields[7] as String,
      route: fields[8] as String,
      time: fields[9] as String,
      previousSurgeries: fields[10] as String,
      hospitalizations: fields[11] as String,
      transfusions: fields[12] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ClinicalHistory obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.allergies)
      ..writeByte(1)
      ..write(obj.medications)
      ..writeByte(2)
      ..write(obj.previousIllnesses)
      ..writeByte(3)
      ..write(obj.currentSymptoms)
      ..writeByte(4)
      ..write(obj.pain)
      ..writeByte(5)
      ..write(obj.painScale)
      ..writeByte(6)
      ..write(obj.dosage)
      ..writeByte(7)
      ..write(obj.frequency)
      ..writeByte(8)
      ..write(obj.route)
      ..writeByte(9)
      ..write(obj.time)
      ..writeByte(10)
      ..write(obj.previousSurgeries)
      ..writeByte(11)
      ..write(obj.hospitalizations)
      ..writeByte(12)
      ..write(obj.transfusions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClinicalHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
