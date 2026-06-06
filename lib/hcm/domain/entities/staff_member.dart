import '../../../shared/domain/entities/entity.dart';

class StaffMember extends Entity<int> {
  final String firstName;
  final String lastName;
  final String role; // Ej: Enfermero, Médico, Limpieza
  final String status;

  const StaffMember({
    required super.id,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.status,
  });

  String get fullName => '$firstName $lastName';
  bool get isActive => status.toUpperCase() == 'ACTIVE';
}
