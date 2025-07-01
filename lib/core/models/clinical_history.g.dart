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
    );
  }

  @override
  void write(BinaryWriter writer, ClinicalHistory obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.allergies)
      ..writeByte(1)
      ..write(obj.medications)
      ..writeByte(2)
      ..write(obj.previousIllnesses);
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
