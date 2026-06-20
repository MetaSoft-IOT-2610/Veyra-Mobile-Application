import '../../../shared/core/failures/failures.dart';
import '../../../shared/core/result/result.dart';
import '../../domain/entities/person_profile.dart';
import '../../domain/repositories/i_person_profile_repository.dart';

class CreatePersonProfileCommand {
  final IPersonProfileRepository _repository;

  CreatePersonProfileCommand(this._repository);

  Future<Result<Failure, PersonProfile>> execute({
    required String dni,
    required String firstName,
    required String lastName,
    required String birthDate,
    required String age,
    required String emailAddress,
    required String street,
    required String number,
    required String city,
    required String postalCode,
    required String country,
    required String phoneNumber,
  }) {
    final parsedAge = int.tryParse(age.trim());

    if (!RegExp(r'^[0-9]{8}$').hasMatch(dni.trim())) {
      return Future.value(
        Result.failure(const ValidationFailure('DNI must have 8 digits.')),
      );
    }

    if (firstName.trim().length < 2 || lastName.trim().length < 2) {
      return Future.value(
        Result.failure(
          const ValidationFailure('First name and last name are required.'),
        ),
      );
    }

    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(birthDate.trim())) {
      return Future.value(
        Result.failure(
          const ValidationFailure('Birth date must use YYYY-MM-DD format.'),
        ),
      );
    }

    if (parsedAge == null || parsedAge < 0 || parsedAge > 120) {
      return Future.value(
        Result.failure(
          const ValidationFailure('Age must be between 0 and 120.'),
        ),
      );
    }

    if (!emailAddress.contains('@')) {
      return Future.value(
        Result.failure(const ValidationFailure('Email address must be valid.')),
      );
    }

    if (street.trim().isEmpty ||
        number.trim().isEmpty ||
        city.trim().isEmpty ||
        postalCode.trim().isEmpty ||
        country.trim().isEmpty ||
        phoneNumber.trim().isEmpty) {
      return Future.value(
        Result.failure(
          const ValidationFailure(
            'All address and contact fields are required.',
          ),
        ),
      );
    }

    return _repository.createPersonProfile(
      dni: dni.trim(),
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      birthDate: birthDate.trim(),
      age: parsedAge,
      emailAddress: emailAddress.trim(),
      street: street.trim(),
      number: number.trim(),
      city: city.trim(),
      postalCode: postalCode.trim(),
      country: country.trim(),
      phoneNumber: phoneNumber.trim(),
    );
  }
}
