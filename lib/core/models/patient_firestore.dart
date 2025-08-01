import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class PatientFirestore extends Equatable {
  final String? id; // Firestore document ID
  final int age;
  final String city;
  final DateTime createdAt;
  final String exteriorNumber;
  final String firstName;
  final String insurance;
  final String? interiorNumber; // nullable
  final String maternalLastName;
  final String neighborhood;
  final String paternalLastName;
  final String phone;
  final String? responsiblePerson; // nullable
  final String sex;
  final String street;
  final DateTime updatedAt;

  const PatientFirestore({
    this.id,
    required this.age,
    required this.city,
    required this.createdAt,
    required this.exteriorNumber,
    required this.firstName,
    required this.insurance,
    this.interiorNumber,
    required this.maternalLastName,
    required this.neighborhood,
    required this.paternalLastName,
    required this.phone,
    this.responsiblePerson,
    required this.sex,
    required this.street,
    required this.updatedAt,
  });

  // Getter para el nombre completo
  String get fullName =>
      '$firstName $paternalLastName $maternalLastName'.trim();

  // Getter para la dirección completa
  String get fullAddress {
    final interior =
        interiorNumber?.isNotEmpty == true ? ', Int. $interiorNumber' : '';
    return '$street $exteriorNumber$interior, $neighborhood, $city';
  }

  // Factory constructor desde Firestore
  factory PatientFirestore.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Helper function para convertir timestamps de manera segura
    DateTime parseTimestamp(dynamic timestamp) {
      if (timestamp == null) {
        return DateTime.now();
      }
      if (timestamp is Timestamp) {
        return timestamp.toDate();
      }
      if (timestamp is String) {
        return DateTime.parse(timestamp);
      }
      return DateTime.now();
    }

    return PatientFirestore(
      id: doc.id,
      age: data['age'] ?? 0,
      city: data['city'] ?? '',
      createdAt: parseTimestamp(data['createdAt']),
      exteriorNumber: data['exteriorNumber'] ?? '',
      firstName: data['firstName'] ?? '',
      insurance: data['insurance'] ?? '',
      interiorNumber: data['interiorNumber'],
      maternalLastName: data['maternalLastName'] ?? '',
      neighborhood: data['neighborhood'] ?? '',
      paternalLastName: data['paternalLastName'] ?? '',
      phone: data['phone'] ?? '',
      responsiblePerson: data['responsiblePerson'],
      sex: data['sex'] ?? '',
      street: data['street'] ?? '',
      updatedAt: parseTimestamp(data['updatedAt']),
    );
  }

  // Factory constructor desde Map
  factory PatientFirestore.fromMap(Map<String, dynamic> data, String id) {
    // Helper function para convertir timestamps de manera segura
    DateTime parseTimestamp(dynamic timestamp) {
      if (timestamp == null) {
        return DateTime.now();
      }
      if (timestamp is Timestamp) {
        return timestamp.toDate();
      }
      if (timestamp is String) {
        try {
          return DateTime.parse(timestamp);
        } catch (e) {
          return DateTime.now();
        }
      }
      return DateTime.now();
    }

    return PatientFirestore(
      id: id,
      age: data['age'] ?? 0,
      city: data['city'] ?? '',
      createdAt: parseTimestamp(data['createdAt']),
      exteriorNumber: data['exteriorNumber'] ?? '',
      firstName: data['firstName'] ?? '',
      insurance: data['insurance'] ?? '',
      interiorNumber: data['interiorNumber'],
      maternalLastName: data['maternalLastName'] ?? '',
      neighborhood: data['neighborhood'] ?? '',
      paternalLastName: data['paternalLastName'] ?? '',
      phone: data['phone'] ?? '',
      responsiblePerson: data['responsiblePerson'],
      sex: data['sex'] ?? '',
      street: data['street'] ?? '',
      updatedAt: parseTimestamp(data['updatedAt']),
    );
  }

  // Convertir a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'age': age,
      'city': city,
      'createdAt': Timestamp.fromDate(createdAt),
      'exteriorNumber': exteriorNumber,
      'firstName': firstName,
      'insurance': insurance,
      'interiorNumber': interiorNumber,
      'maternalLastName': maternalLastName,
      'neighborhood': neighborhood,
      'paternalLastName': paternalLastName,
      'phone': phone,
      'responsiblePerson': responsiblePerson,
      'sex': sex,
      'street': street,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Convertir a Map sin timestamps (para casos especiales)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'age': age,
      'city': city,
      'createdAt': createdAt.toIso8601String(),
      'exteriorNumber': exteriorNumber,
      'firstName': firstName,
      'insurance': insurance,
      'interiorNumber': interiorNumber,
      'maternalLastName': maternalLastName,
      'neighborhood': neighborhood,
      'paternalLastName': paternalLastName,
      'phone': phone,
      'responsiblePerson': responsiblePerson,
      'sex': sex,
      'street': street,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Método copyWith para crear copias con cambios
  PatientFirestore copyWith({
    String? id,
    int? age,
    String? city,
    DateTime? createdAt,
    String? exteriorNumber,
    String? firstName,
    String? insurance,
    String? interiorNumber,
    String? maternalLastName,
    String? neighborhood,
    String? paternalLastName,
    String? phone,
    String? responsiblePerson,
    String? sex,
    String? street,
    DateTime? updatedAt,
  }) {
    return PatientFirestore(
      id: id ?? this.id,
      age: age ?? this.age,
      city: city ?? this.city,
      createdAt: createdAt ?? this.createdAt,
      exteriorNumber: exteriorNumber ?? this.exteriorNumber,
      firstName: firstName ?? this.firstName,
      insurance: insurance ?? this.insurance,
      interiorNumber: interiorNumber ?? this.interiorNumber,
      maternalLastName: maternalLastName ?? this.maternalLastName,
      neighborhood: neighborhood ?? this.neighborhood,
      paternalLastName: paternalLastName ?? this.paternalLastName,
      phone: phone ?? this.phone,
      responsiblePerson: responsiblePerson ?? this.responsiblePerson,
      sex: sex ?? this.sex,
      street: street ?? this.street,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Método para crear un nuevo paciente (sin ID, con timestamps actuales)
  factory PatientFirestore.create({
    required int age,
    required String city,
    required String exteriorNumber,
    required String firstName,
    required String insurance,
    String? interiorNumber,
    required String maternalLastName,
    required String neighborhood,
    required String paternalLastName,
    required String phone,
    String? responsiblePerson,
    required String sex,
    required String street,
  }) {
    final now = DateTime.now();
    return PatientFirestore(
      age: age,
      city: city,
      createdAt: now,
      exteriorNumber: exteriorNumber,
      firstName: firstName,
      insurance: insurance,
      interiorNumber: interiorNumber,
      maternalLastName: maternalLastName,
      neighborhood: neighborhood,
      paternalLastName: paternalLastName,
      phone: phone,
      responsiblePerson: responsiblePerson,
      sex: sex,
      street: street,
      updatedAt: now,
    );
  }

  @override
  List<Object?> get props => [
    id,
    age,
    city,
    createdAt,
    exteriorNumber,
    firstName,
    insurance,
    interiorNumber,
    maternalLastName,
    neighborhood,
    paternalLastName,
    phone,
    responsiblePerson,
    sex,
    street,
    updatedAt,
  ];

  @override
  String toString() {
    return 'PatientFirestore(id: $id, name: $fullName, age: $age, sex: $sex)';
  }
}
