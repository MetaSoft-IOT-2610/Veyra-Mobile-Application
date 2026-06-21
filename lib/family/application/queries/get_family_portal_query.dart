import '../../../shared/core/failures/failures.dart';
import '../../../shared/core/result/result.dart';
import '../../domain/entities/family_portal_data.dart';
import '../../domain/repositories/i_family_portal_repository.dart';

class GetFamilyPortalQuery {
  final IFamilyPortalRepository _repository;

  GetFamilyPortalQuery(this._repository);

  Future<Result<Failure, FamilyPortalData>> execute(int userId) {
    if (userId <= 0) {
      return Future.value(
        Result.failure(const ValidationFailure('Invalid family user.')),
      );
    }
    return _repository.getPortalData(userId);
  }
}
