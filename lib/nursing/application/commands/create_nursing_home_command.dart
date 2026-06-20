import '../../../shared/core/failures/failures.dart';
import '../../../shared/core/result/result.dart';
import '../../domain/entities/nursing_home.dart';
import '../../domain/repositories/i_nursing_home_setup_repository.dart';

class CreateNursingHomeCommand {
  final INursingHomeSetupRepository _repository;

  CreateNursingHomeCommand(this._repository);

  Future<Result<Failure, NursingHome>> execute({
    required int administratorId,
    required String businessName,
    required String emailAddress,
    required String phoneNumber,
    required String street,
    required String number,
    required String city,
    required String postalCode,
    required String country,
    required String ruc,
  }) {
    if (businessName.trim().length < 3) {
      return Future.value(
        Result.failure(
          const ValidationFailure(
            'Business name must have at least 3 characters.',
          ),
        ),
      );
    }

    if (!emailAddress.contains('@')) {
      return Future.value(
        Result.failure(const ValidationFailure('Email address must be valid.')),
      );
    }

    if (!RegExp(r'^[0-9]{11}$').hasMatch(ruc.trim())) {
      return Future.value(
        Result.failure(const ValidationFailure('RUC must have 11 digits.')),
      );
    }

    if (phoneNumber.trim().isEmpty ||
        street.trim().isEmpty ||
        number.trim().isEmpty ||
        city.trim().isEmpty ||
        postalCode.trim().isEmpty ||
        country.trim().isEmpty) {
      return Future.value(
        Result.failure(
          const ValidationFailure(
            'All contact and address fields are required.',
          ),
        ),
      );
    }

    return _repository.createNursingHome(
      administratorId: administratorId,
      businessName: businessName.trim(),
      emailAddress: emailAddress.trim(),
      phoneNumber: phoneNumber.trim(),
      street: street.trim(),
      number: number.trim(),
      city: city.trim(),
      postalCode: postalCode.trim(),
      country: country.trim(),
      ruc: ruc.trim(),
    );
  }
}
