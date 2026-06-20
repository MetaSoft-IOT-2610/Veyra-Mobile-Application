import '../../../shared/domain/entities/entity.dart';

class Resident extends Entity<int> {
  final int personProfileId;
  final String firstName;
  final String lastName;
  final String admissionDate;
  final String status;
  final String legalRepresentativeFirstName;
  final String legalRepresentativeLastName;
  final String legalRepresentativePhoneNumber;
  final String emergencyContactFirstName;
  final String emergencyContactLastName;
  final String emergencyContactPhoneNumber;
  final int? roomId;

  const Resident({
    required super.id,
    this.personProfileId = 0,
    required this.firstName,
    required this.lastName,
    required this.admissionDate,
    required this.status,
    this.legalRepresentativeFirstName = '',
    this.legalRepresentativeLastName = '',
    this.legalRepresentativePhoneNumber = '',
    this.emergencyContactFirstName = '',
    this.emergencyContactLastName = '',
    this.emergencyContactPhoneNumber = '',
    this.roomId,
  });

  String get fullName {
    final name = '$firstName $lastName'.trim();
    if (name.isNotEmpty) return name;
    return 'Resident #$id';
  }

  String get legalRepresentativeName =>
      '$legalRepresentativeFirstName $legalRepresentativeLastName'.trim();

  String get emergencyContactName =>
      '$emergencyContactFirstName $emergencyContactLastName'.trim();
}
