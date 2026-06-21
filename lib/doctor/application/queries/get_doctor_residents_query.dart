import '../../../nursing/domain/entities/resident.dart';
import '../../../nursing/domain/repositories/i_nursing_repository.dart';
import '../../../shared/core/failures/failures.dart';
import '../../../shared/core/result/result.dart';

class GetDoctorResidentsQuery {
  final INursingRepository _repository;

  GetDoctorResidentsQuery(this._repository);

  Future<Result<Failure, List<Resident>>> execute(int nursingHomeId) {
    if (nursingHomeId <= 0) {
      return Future.value(
        Result.failure(
          const ValidationFailure('A valid nursing home is required.'),
        ),
      );
    }
    return _repository.getResidents(nursingHomeId);
  }
}
