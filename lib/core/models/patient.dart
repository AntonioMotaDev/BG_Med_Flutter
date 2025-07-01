import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'patient.g.dart';

@HiveType(typeId: 0)
class Patient extends Equatable {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final int age;
  @HiveField(2)
  final String gender;
  @HiveField(3)
  final String address;

  const Patient({
    required this.name,
    required this.age,
    required this.gender,
    required this.address,
  });

  @override
  List<Object?> get props => [name, age, gender, address];
} 