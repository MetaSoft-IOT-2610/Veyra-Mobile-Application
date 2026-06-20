import '../../../shared/domain/entities/entity.dart';

class StaffMember extends Entity<int> {
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

  const StaffMember({
    required super.id,
    this.personProfileId = 0,
    required this.firstName,
    required this.lastName,
    this.dni = '',
    this.emailAddress = '',
    this.phoneNumber = '',
    required this.role,
    required this.status,
    this.emergencyContactFirstName = '',
    this.emergencyContactLastName = '',
    this.emergencyContactPhoneNumber = '',
  });

  String get fullName {
    final name = '$firstName $lastName'.trim();
    if (name.isNotEmpty) return name;
    return 'Staff #$id';
  }

  String get emergencyContactName =>
      '$emergencyContactFirstName $emergencyContactLastName'.trim();

  bool get isActive => status.toUpperCase() == 'ACTIVE';
}
