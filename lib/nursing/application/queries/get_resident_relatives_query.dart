import '../../../shared/core/failures/failures.dart';
import '../../../shared/core/result/result.dart';
import '../../domain/entities/relative.dart';
import '../../domain/repositories/i_nursing_repository.dart';

class GetResidentRelativesQuery {
  final INursingRepository _repository;

  GetResidentRelativesQuery(this._repository);

  Future<Result<Failure, List<Relative>>> execute({
    required int nursingHomeId,
    required int residentId,
  }) async {
    final result = await _repository.getRelatives(nursingHomeId);
    return result.fold(
      (failure) => Result.failure(failure),
      (relatives) => Result.success(
        relatives
            .where((relative) => relative.residentId == residentId)
            .toList(),
      ),
    );
  }
}
