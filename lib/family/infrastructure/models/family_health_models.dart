import '../../domain/entities/family_health_data.dart';

class FamilyResidentProfileModel {
  final String fullName;
  final String dni;
  final String birthDate;
  final int age;
  final String photo;
  final String phoneNumber;
  final String emailAddress;
  final String streetAddress;

  const FamilyResidentProfileModel({
    required this.fullName,
    required this.dni,
    required this.birthDate,
    required this.age,
    required this.photo,
    required this.phoneNumber,
    required this.emailAddress,
    required this.streetAddress,
  });

  factory FamilyResidentProfileModel.fromJson(Map<String, dynamic> json) {
    return FamilyResidentProfileModel(
      fullName: json['fullName'] as String? ?? '',
      dni: json['dni'] as String? ?? '',
      birthDate: json['birthDate'] as String? ?? '',
      age: _asInt(json['age']),
      photo: json['photo'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      emailAddress: json['emailAddress'] as String? ?? '',
      streetAddress: json['streetAddress'] as String? ?? '',
    );
  }

  FamilyResidentProfile toEntity() => FamilyResidentProfile(
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

class FamilyMedicationModel {
  final int id;
  final String name;
  final String description;
  final String amount;
  final String expirationDate;
  final String drugPresentation;
  final String dosage;

  const FamilyMedicationModel({
    required this.id,
    required this.name,
    required this.description,
    required this.amount,
    required this.expirationDate,
    required this.drugPresentation,
    required this.dosage,
  });

  factory FamilyMedicationModel.fromJson(Map<String, dynamic> json) {
    return FamilyMedicationModel(
      id: _asInt(json['id']),
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      amount: json['amount']?.toString() ?? '',
      expirationDate: json['expirationDate'] as String? ?? '',
      drugPresentation: json['drugPresentation'] as String? ?? '',
      dosage: json['dosage'] as String? ?? '',
    );
  }

  FamilyMedication toEntity() => FamilyMedication(
    id: id,
    name: name,
    description: description,
    amount: amount,
    expirationDate: expirationDate,
    drugPresentation: drugPresentation,
    dosage: dosage,
  );
}

class FamilyDeviceModel {
  final int id;
  final String deviceType;
  final String status;
  final String assignedAt;
  final String macAddress;

  const FamilyDeviceModel({
    required this.id,
    required this.deviceType,
    required this.status,
    required this.assignedAt,
    required this.macAddress,
  });

  factory FamilyDeviceModel.fromJson(Map<String, dynamic> json) {
    return FamilyDeviceModel(
      id: _asInt(json['id']),
      deviceType: json['deviceType'] as String? ?? '',
      status: json['status'] as String? ?? '',
      assignedAt: json['assignedAt'] as String? ?? '',
      macAddress: json['macAddress'] as String? ?? '',
    );
  }

  FamilyDevice toEntity() => FamilyDevice(
    id: id,
    deviceType: deviceType,
    status: status,
    assignedAt: assignedAt,
    macAddress: macAddress,
  );
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
