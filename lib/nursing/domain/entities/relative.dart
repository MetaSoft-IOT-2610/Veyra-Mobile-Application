import '../../../shared/domain/entities/entity.dart';

class Relative extends Entity<int> {
  final String firstName;
  final String lastName;
  final String email;
  final int residentId;
  final int nursingHomeId;
  final int? userId;

  const Relative({
    required super.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.residentId,
    required this.nursingHomeId,
    this.userId,
  });

  String get fullName {
    final name = '$firstName $lastName'.trim();
    return name.isEmpty ? 'Relative #$id' : name;
  }

  bool get hasUser => userId != null && userId! > 0;
}
