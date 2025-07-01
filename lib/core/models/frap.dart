import 'package:bg_med/core/models/clinical_history.dart';
import 'package:bg_med/core/models/patient.dart';
import 'package:bg_med/core/models/physical_exam.dart';
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'frap.g.dart';

@HiveType(typeId: 3)
class Frap extends Equatable {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final Patient patient;
  @HiveField(2)
  final ClinicalHistory clinicalHistory;
  @HiveField(3)
  final PhysicalExam physicalExam;
  @HiveField(4)
  final DateTime createdAt;

  const Frap({
    required this.id,
    required this.patient,
    required this.clinicalHistory,
    required this.physicalExam,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, patient, clinicalHistory, physicalExam, createdAt];
} 