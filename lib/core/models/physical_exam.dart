import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'physical_exam.g.dart';

@HiveType(typeId: 2)
class PhysicalExam extends Equatable {
  @HiveField(0)
  final String vitalSigns;
  @HiveField(1)
  final String head;
  @HiveField(2)
  final String neck;
  @HiveField(3)
  final String thorax;
  @HiveField(4)
  final String abdomen;
  @HiveField(5)
  final String extremities;

  const PhysicalExam({
    required this.vitalSigns,
    required this.head,
    required this.neck,
    required this.thorax,
    required this.abdomen,
    required this.extremities,
  });

  @override
  List<Object?> get props => [vitalSigns, head, neck, thorax, abdomen, extremities];
} 