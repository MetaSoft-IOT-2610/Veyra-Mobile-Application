import '../../../shared/core/failures/failures.dart';
import '../../../shared/core/result/result.dart';
import '../../domain/entities/family_user.dart';
import '../../domain/entities/relative.dart';
import '../../domain/repositories/i_nursing_repository.dart';

class CreateRelativeCommand {
  final INursingRepository _repository;

  CreateRelativeCommand(this._repository);

  Future<Result<Failure, Relative>> execute({
    required int nursingHomeId,
    required int residentId,
    required FamilyUser familyUser,
  }) async {
    if (nursingHomeId <= 0 || residentId <= 0) {
      return Result.failure(
        const ValidationFailure('A valid resident is required.'),
      );
    }

    if (familyUser.id <= 0) {
      return Result.failure(
        const ValidationFailure('Select a valid family account.'),
      );
    }

    return _repository.createRelative(
      nursingHomeId: nursingHomeId,
      residentId: residentId,
      firstName: familyUser.firstName,
      lastName: familyUser.lastName,
      email: familyUser.email,
      userId: familyUser.id,
    );
  }
}
