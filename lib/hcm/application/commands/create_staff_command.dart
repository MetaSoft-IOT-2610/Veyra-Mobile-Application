import '../../../shared/core/failures/failures.dart';
import '../../../shared/core/result/result.dart';
import '../../domain/entities/staff_member.dart';
import '../../domain/repositories/i_staff_repository.dart';

class CreateStaffCommand {
  final IStaffRepository _repository;

  CreateStaffCommand(this._repository);

  Future<Result<Failure, StaffMember>> execute({
    required int nursingHomeId,
    required String dni,
    required String firstName,
    required String lastName,
    required DateTime? birthDate,
    required String emailAddress,
    required String street,
    required String number,
    required String city,
    required String postalCode,
    required String country,
    required String phoneNumber,
    required String emergencyContactFirstName,
    required String emergencyContactLastName,
    required String emergencyContactPhoneNumber,
  }) async {
    if (birthDate == null) {
      return Result.failure(ValidationFailure('Birth date is required.'));
    }

    final fields = {
      'DNI': dni,
      'First name': firstName,
      'Last name': lastName,
      'Email': emailAddress,
      'Street': street,
      'Number': number,
      'City': city,
      'Postal code': postalCode,
      'Country': country,
      'Phone number': phoneNumber,
      'Emergency first name': emergencyContactFirstName,
      'Emergency last name': emergencyContactLastName,
      'Emergency phone number': emergencyContactPhoneNumber,
    };

    for (final entry in fields.entries) {
      if (entry.value.trim().isEmpty) {
        return Result.failure(ValidationFailure('${entry.key} is required.'));
      }
    }

    return _repository.createStaff(
      nursingHomeId: nursingHomeId,
      dni: dni.trim(),
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      birthDate: birthDate,
      age: _calculateAge(birthDate),
      emailAddress: emailAddress.trim(),
      street: street.trim(),
      number: number.trim(),
      city: city.trim(),
      postalCode: postalCode.trim(),
      country: country.trim(),
      phoneNumber: phoneNumber.trim(),
      emergencyContactFirstName: emergencyContactFirstName.trim(),
      emergencyContactLastName: emergencyContactLastName.trim(),
      emergencyContactPhoneNumber: emergencyContactPhoneNumber.trim(),
    );
  }

  int _calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    var age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}
