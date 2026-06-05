import '../../../shared/domain/entities/entity.dart';

class Resident extends Entity<int> {
  final String firstName;
  final String lastName;
  final String admissionDate;
  final String status;

  const Resident({
    required super.id,
    required this.firstName,
    required this.lastName,
    required this.admissionDate,
    required this.status,
  });

  String get fullName => '$firstName $lastName';
}