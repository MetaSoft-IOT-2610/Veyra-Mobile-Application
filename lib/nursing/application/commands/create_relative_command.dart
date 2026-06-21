import '../../../shared/core/failures/failures.dart';
import '../../../shared/core/result/result.dart';
import '../../domain/entities/relative.dart';
import '../../domain/repositories/i_nursing_repository.dart';

class CreateRelativeCommand {
  final INursingRepository _repository;

  CreateRelativeCommand(this._repository);

  Future<Result<Failure, Relative>> execute({
    required int nursingHomeId,
    required int residentId,
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    if (nursingHomeId <= 0 || residentId <= 0) {
      return Result.failure(
        const ValidationFailure('A valid resident is required.'),
      );
    }

    if (firstName.trim().isEmpty ||
        lastName.trim().isEmpty ||
        email.trim().isEmpty) {
      return Result.failure(
        const ValidationFailure('Complete the family member information.'),
      );
    }

    if (!_isValidEmail(email.trim())) {
      return Result.failure(
        const ValidationFailure('Enter a valid family member email.'),
      );
    }

    return _repository.createRelative(
      nursingHomeId: nursingHomeId,
      residentId: residentId,
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      email: email.trim(),
    );
  }

  bool _isValidEmail(String value) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
  }
}
