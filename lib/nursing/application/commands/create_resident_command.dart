import '../../../shared/core/failures/failures.dart';
import '../../../shared/core/result/result.dart';
import '../../domain/entities/resident.dart';
import '../../domain/repositories/i_nursing_repository.dart';

class CreateResidentCommand {
  final INursingRepository _repository;

  CreateResidentCommand(this._repository);

  Future<Result<Failure, Resident>> execute({
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
    required String legalRepresentativeFirstName,
    required String legalRepresentativeLastName,
    required String legalRepresentativePhoneNumber,
    required String emergencyContactFirstName,
    required String emergencyContactLastName,
    required String emergencyContactPhoneNumber,
  }) async {
    if (nursingHomeId <= 0) {
      return Result.failure(
        const ValidationFailure('A valid nursing home is required.'),
      );
    }

    if (dni.trim().isEmpty ||
        firstName.trim().isEmpty ||
        lastName.trim().isEmpty ||
        phoneNumber.trim().isEmpty) {
      return Result.failure(
        const ValidationFailure('Complete the resident personal information.'),
      );
    }

    if (birthDate == null) {
      return Result.failure(
        const ValidationFailure('Select the resident birth date.'),
      );
    }

    if (street.trim().isEmpty ||
        number.trim().isEmpty ||
        city.trim().isEmpty ||
        postalCode.trim().isEmpty ||
        country.trim().isEmpty) {
      return Result.failure(
        const ValidationFailure('Complete the resident address.'),
      );
    }

    if (legalRepresentativeFirstName.trim().isEmpty ||
        legalRepresentativeLastName.trim().isEmpty ||
        legalRepresentativePhoneNumber.trim().isEmpty) {
      return Result.failure(
        const ValidationFailure('Complete the legal representative data.'),
      );
    }

    if (emergencyContactFirstName.trim().isEmpty ||
        emergencyContactLastName.trim().isEmpty ||
        emergencyContactPhoneNumber.trim().isEmpty) {
      return Result.failure(
        const ValidationFailure('Complete the emergency contact data.'),
      );
    }

    return _repository.createResident(
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
      legalRepresentativeFirstName: legalRepresentativeFirstName.trim(),
      legalRepresentativeLastName: legalRepresentativeLastName.trim(),
      legalRepresentativePhoneNumber: legalRepresentativePhoneNumber.trim(),
      emergencyContactFirstName: emergencyContactFirstName.trim(),
      emergencyContactLastName: emergencyContactLastName.trim(),
      emergencyContactPhoneNumber: emergencyContactPhoneNumber.trim(),
    );
  }

  int _calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    var age = today.year - birthDate.year;
    final hadBirthdayThisYear =
        today.month > birthDate.month ||
        (today.month == birthDate.month && today.day >= birthDate.day);
    if (!hadBirthdayThisYear) age--;
    return age;
  }
}
