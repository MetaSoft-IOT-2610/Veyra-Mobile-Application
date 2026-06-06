import '../../domain/entities/staff_member.dart';

class StaffModel {
  final int id;
  final String firstName;
  final String lastName;
  final String role;
  final String status;

  const StaffModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.status,
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    return StaffModel(
      id: json['id'] as int,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      role: json['role'] ?? 'Unassigned',
      status: json['status'] ?? 'INACTIVE',
    );
  }

  StaffMember toEntity() => StaffMember(
    id: id,
    firstName: firstName,
    lastName: lastName,
    role: role,
    status: status,
  );
}
