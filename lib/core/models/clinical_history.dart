import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'clinical_history.g.dart';

@HiveType(typeId: 1)
class ClinicalHistory extends Equatable {
  @HiveField(0)
  final String allergies;
  @HiveField(1)
  final String medications;
  @HiveField(2)
  final String previousIllnesses;

  const ClinicalHistory({
    required this.allergies,
    required this.medications,
    required this.previousIllnesses,
  });

  @override
  List<Object?> get props => [allergies, medications, previousIllnesses];
} 