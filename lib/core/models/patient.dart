import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'patient.g.dart';

@HiveType(typeId: 0)
class Patient extends Equatable {
  // Campos existentes (mantener para compatibilidad)
  @HiveField(0)
  final String name;
  @HiveField(1)
  final int age;
  @HiveField(2)
  final String sex; // Cambiado de gender a sex
  @HiveField(3)
  final String address;

  // Nuevos campos expandidos
  @HiveField(4)
  final String firstName;
  @HiveField(5)
  final String paternalLastName;
  @HiveField(6)
  final String maternalLastName;
  @HiveField(7)
  final String phone;
  @HiveField(8)
  final String street;
  @HiveField(9)
  final String exteriorNumber;
  @HiveField(10)
  final String? interiorNumber;
  @HiveField(11)
  final String neighborhood;
  @HiveField(12)
  final String city;
  @HiveField(13)
  final String insurance;
  @HiveField(14)
  final String? responsiblePerson;

  const Patient({
    // Campos existentes
    required this.name,
    required this.age,
    required this.sex, // Cambiado de gender a sex
    required this.address,
    // Nuevos campos con valores por defecto
    this.firstName = '',
    this.paternalLastName = '',
    this.maternalLastName = '',
    this.phone = '',
    this.street = '',
    this.exteriorNumber = '',
    this.interiorNumber,
    this.neighborhood = '',
    this.city = '',
    this.insurance = '',
    this.responsiblePerson,
  });

  // Getter para el nombre completo (usando nuevos campos si están disponibles)
  String get fullName {
    if (firstName.isNotEmpty || paternalLastName.isNotEmpty || maternalLastName.isNotEmpty) {
      return '$firstName $paternalLastName $maternalLastName'.trim();
    }
    return name; // Fallback al campo original
  }

  // Getter para la dirección completa (usando nuevos campos si están disponibles)
  String get fullAddress {
    if (street.isNotEmpty) {
      String fullAddr = street;
      if (exteriorNumber.isNotEmpty) {
        fullAddr += ' $exteriorNumber';
      }
      if (interiorNumber != null && interiorNumber!.isNotEmpty) {
        fullAddr += ', Int. $interiorNumber';
      }
      if (neighborhood.isNotEmpty) {
        fullAddr += ', $neighborhood';
      }
      if (city.isNotEmpty) {
        fullAddr += ', $city';
      }
      return fullAddr;
    }
    return address; // Fallback al campo original
  }

  // Método copyWith para crear copias con cambios
  Patient copyWith({
    String? name,
    int? age,
    String? sex, // Cambiado de gender a sex
    String? address,
    String? firstName,
    String? paternalLastName,
    String? maternalLastName,
    String? phone,
    String? street,
    String? exteriorNumber,
    String? interiorNumber,
    String? neighborhood,
    String? city,
    String? insurance,
    String? responsiblePerson,
  }) {
    return Patient(
      name: name ?? this.name,
      age: age ?? this.age,
      sex: sex ?? this.sex, // Cambiado de gender a sex
      address: address ?? this.address,
      firstName: firstName ?? this.firstName,
      paternalLastName: paternalLastName ?? this.paternalLastName,
      maternalLastName: maternalLastName ?? this.maternalLastName,
      phone: phone ?? this.phone,
      street: street ?? this.street,
      exteriorNumber: exteriorNumber ?? this.exteriorNumber,
      interiorNumber: interiorNumber ?? this.interiorNumber,
      neighborhood: neighborhood ?? this.neighborhood,
      city: city ?? this.city,
      insurance: insurance ?? this.insurance,
      responsiblePerson: responsiblePerson ?? this.responsiblePerson,
    );
  }

  @override
  List<Object?> get props => [
        name,
        age,
        sex, // Cambiado de gender a sex
        address,
        firstName,
        paternalLastName,
        maternalLastName,
        phone,
        street,
        exteriorNumber,
        interiorNumber,
        neighborhood,
        city,
        insurance,
        responsiblePerson,
      ];
} 