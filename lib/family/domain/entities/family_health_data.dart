class FamilyResidentProfile {
  final String fullName;
  final String dni;
  final String birthDate;
  final int age;
  final String photo;
  final String phoneNumber;
  final String emailAddress;
  final String streetAddress;

  const FamilyResidentProfile({
    required this.fullName,
    required this.dni,
    required this.birthDate,
    required this.age,
    required this.photo,
    required this.phoneNumber,
    required this.emailAddress,
    required this.streetAddress,
  });
}

class FamilyMedication {
  final int id;
  final String name;
  final String description;
  final String amount;
  final String expirationDate;
  final String drugPresentation;
  final String dosage;

  const FamilyMedication({
    required this.id,
    required this.name,
    required this.description,
    required this.amount,
    required this.expirationDate,
    required this.drugPresentation,
    required this.dosage,
  });
}

class FamilyDevice {
  final int id;
  final String deviceType;
  final String status;
  final String assignedAt;
  final String macAddress;

  const FamilyDevice({
    required this.id,
    required this.deviceType,
    required this.status,
    required this.assignedAt,
    required this.macAddress,
  });
}

class FamilyMeasurement {
  final String id;
  final int deviceId;
  final double? ambientTemperature;
  final int? heartRate;
  final int? oxygenSaturation;
  final DateTime timestamp;

  const FamilyMeasurement({
    required this.id,
    required this.deviceId,
    required this.ambientTemperature,
    required this.heartRate,
    required this.oxygenSaturation,
    required this.timestamp,
  });
}
