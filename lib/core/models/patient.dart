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
  @HiveField(4)
  final String addressDetails;
  @HiveField(5)
  final String firstName;
  @HiveField(6)
  final String paternalLastName;
  @HiveField(7)
  final String maternalLastName;
  @HiveField(8)
  final String phone;
  @HiveField(9)
  final String street;
  @HiveField(10)
  final String exteriorNumber;
  @HiveField(11)
  final String? interiorNumber;
  @HiveField(12)
  final String neighborhood;
  @HiveField(13)
  final String city;
  @HiveField(14)
  final String insurance;
  @HiveField(15)
  final String? responsiblePerson;
  @HiveField(16)
  final String gender;
  @HiveField(17)
  final String tipoEntrega;

  // Nuevos campos para sincronización con diálogos y PDF
  @HiveField(18)
  final String? emergencyContact; // Contacto de emergencia
  @HiveField(19)
  final String? currentCondition; // Padecimiento actual
  @HiveField(20)
  final String? tipoEntregaOtro; // Especificación de "Otro" en tipo de entrega

  const Patient({
    required this.name,
    required this.age,
    required this.sex,
    this.gender = '',
    required this.address,
    this.addressDetails = '',
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
    this.tipoEntrega = '',
    this.emergencyContact,
    this.currentCondition,
    this.tipoEntregaOtro,
  });

  String get fullName {
    if (firstName.isNotEmpty ||
        paternalLastName.isNotEmpty ||
        maternalLastName.isNotEmpty) {
      return '$firstName $paternalLastName $maternalLastName'.trim();
    }
    return name;
  }

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
      if (addressDetails.isNotEmpty) {
        fullAddr += ', $addressDetails';
      }
      return fullAddr;
    }
    return address;
  }

  Patient copyWith({
    String? name,
    int? age,
    String? sex,
    String? address,
    String? addressDetails,
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
    String? gender,
    String? tipoEntrega,
    String? emergencyContact,
    String? currentCondition,
    String? tipoEntregaOtro,
  }) {
    return Patient(
      name: name ?? this.name,
      age: age ?? this.age,
      sex: sex ?? this.sex,
      address: address ?? this.address,
      addressDetails: addressDetails ?? this.addressDetails,
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
      gender: gender ?? this.gender,
      tipoEntrega: tipoEntrega ?? this.tipoEntrega,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      currentCondition: currentCondition ?? this.currentCondition,
      tipoEntregaOtro: tipoEntregaOtro ?? this.tipoEntregaOtro,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'sex': sex,
      'address': address,
      'addressDetails': addressDetails,
      'firstName': firstName,
      'paternalLastName': paternalLastName,
      'maternalLastName': maternalLastName,
      'phone': phone,
      'street': street,
      'exteriorNumber': exteriorNumber,
      'interiorNumber': interiorNumber,
      'neighborhood': neighborhood,
      'city': city,
      'insurance': insurance,
      'responsiblePerson': responsiblePerson,
      'gender': gender,
      'tipoEntrega': tipoEntrega,
      'emergencyContact': emergencyContact,
      'currentCondition': currentCondition,
      'tipoEntregaOtro': tipoEntregaOtro,
    };
  }

  @override
  List<Object?> get props => [
    name,
    age,
    sex,
    address,
    addressDetails,
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
    gender,
    tipoEntrega,
    emergencyContact,
    currentCondition,
    tipoEntregaOtro,
  ];
}
