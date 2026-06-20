import '../../domain/entities/staff_member.dart';

class StaffModel {
  final int id;
  final int personProfileId;
  final String firstName;
  final String lastName;
  final String dni;
  final String emailAddress;
  final String phoneNumber;
  final String role;
  final String status;
  final String emergencyContactFirstName;
  final String emergencyContactLastName;
  final String emergencyContactPhoneNumber;

  const StaffModel({
    required this.id,
    required this.personProfileId,
    required this.firstName,
    required this.lastName,
    required this.dni,
    required this.emailAddress,
    required this.phoneNumber,
    required this.role,
    required this.status,
    required this.emergencyContactFirstName,
    required this.emergencyContactLastName,
    required this.emergencyContactPhoneNumber,
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    return StaffModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      personProfileId: (json['personProfileId'] as num?)?.toInt() ?? 0,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      dni: json['dni'] as String? ?? '',
      emailAddress: json['emailAddress'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      role: json['role'] as String? ?? 'Unassigned',
      status: json['status'] as String? ?? 'INACTIVE',
      emergencyContactFirstName:
          json['emergencyContactFirstName'] as String? ?? '',
      emergencyContactLastName:
          json['emergencyContactLastName'] as String? ?? '',
      emergencyContactPhoneNumber:
          json['emergencyContactPhoneNumber'] as String? ?? '',
    );
  }

  StaffMember toEntity() => StaffMember(
    id: id,
    personProfileId: personProfileId,
    firstName: firstName,
    lastName: lastName,
    dni: dni,
    emailAddress: emailAddress,
    phoneNumber: phoneNumber,
    role: role,
    status: status,
    emergencyContactFirstName: emergencyContactFirstName,
    emergencyContactLastName: emergencyContactLastName,
    emergencyContactPhoneNumber: emergencyContactPhoneNumber,
  );
}
