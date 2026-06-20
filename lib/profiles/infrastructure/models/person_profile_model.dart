import '../../domain/entities/person_profile.dart';

class PersonProfileModel {
  final int id;
  final String fullName;
  final String dni;
  final String birthDate;
  final int age;
  final String photo;
  final String phoneNumber;
  final String emailAddress;
  final String streetAddress;

  const PersonProfileModel({
    required this.id,
    required this.fullName,
    required this.dni,
    required this.birthDate,
    required this.age,
    required this.photo,
    required this.phoneNumber,
    required this.emailAddress,
    required this.streetAddress,
  });

  factory PersonProfileModel.fromJson(Map<String, dynamic> json) {
    return PersonProfileModel(
      id: (json['id'] as num? ?? 0).toInt(),
      fullName: json['fullName'] as String? ?? '',
      dni: json['dni'] as String? ?? '',
      birthDate: json['birthDate'] as String? ?? '',
      age: (json['age'] as num? ?? 0).toInt(),
      photo: json['photo'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      emailAddress: json['emailAddress'] as String? ?? '',
      streetAddress: json['streetAddress'] as String? ?? '',
    );
  }

  PersonProfile toEntity() {
    return PersonProfile(
      id: id,
      fullName: fullName,
      dni: dni,
      birthDate: birthDate,
      age: age,
      photo: photo,
      phoneNumber: phoneNumber,
      emailAddress: emailAddress,
      streetAddress: streetAddress,
    );
  }
}
