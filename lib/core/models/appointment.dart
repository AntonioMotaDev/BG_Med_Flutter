import 'package:hive/hive.dart';

part 'appointment.g.dart';

@HiveType(typeId: 10)
class Appointment extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  DateTime dateTime;

  @HiveField(4)
  String patientName;

  @HiveField(5)
  String patientPhone;

  @HiveField(6)
  String patientAddress;

  @HiveField(7)
  String appointmentType; // 'consulta', 'emergencia', 'seguimiento'

  @HiveField(8)
  String status; // 'programada', 'confirmada', 'cancelada', 'completada'

  @HiveField(9)
  String notes;

  @HiveField(10)
  DateTime createdAt;

  @HiveField(11)
  DateTime updatedAt;

  @HiveField(12)
  bool isSynced;

  Appointment({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.patientName,
    this.patientPhone = '',
    this.patientAddress = '',
    this.appointmentType = 'consulta',
    this.status = 'programada',
    this.notes = '',
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
  });

  Appointment copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dateTime,
    String? patientName,
    String? patientPhone,
    String? patientAddress,
    String? appointmentType,
    String? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
  }) {
    return Appointment(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      patientName: patientName ?? this.patientName,
      patientPhone: patientPhone ?? this.patientPhone,
      patientAddress: patientAddress ?? this.patientAddress,
      appointmentType: appointmentType ?? this.appointmentType,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dateTime': dateTime.toIso8601String(),
      'patientName': patientName,
      'patientPhone': patientPhone,
      'patientAddress': patientAddress,
      'appointmentType': appointmentType,
      'status': status,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isSynced': isSynced,
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      dateTime: DateTime.parse(map['dateTime']),
      patientName: map['patientName'] ?? '',
      patientPhone: map['patientPhone'] ?? '',
      patientAddress: map['patientAddress'] ?? '',
      appointmentType: map['appointmentType'] ?? 'consulta',
      status: map['status'] ?? 'programada',
      notes: map['notes'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      isSynced: map['isSynced'] ?? false,
    );
  }
}
