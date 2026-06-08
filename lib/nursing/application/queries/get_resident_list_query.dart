import '../../../shared/core/result/result.dart';
import '../../../shared/core/failures/failures.dart';
import '../../domain/repositories/i_nursing_repository.dart';
import '../../domain/entities/resident.dart';

class GetResidentListQuery {
  final INursingRepository _repository;

  GetResidentListQuery(this._repository);

  Future<Result<Failure, List<Resident>>> execute(int nursingHomeId) async {
    return await _repository.getResidents(nursingHomeId);
  }
}
