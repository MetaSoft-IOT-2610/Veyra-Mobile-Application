import '../../../shared/core/failures/failures.dart';
import '../../../shared/core/result/result.dart';
import '../../domain/entities/family_user.dart';
import '../../domain/repositories/i_nursing_repository.dart';

class GetFamilyUsersQuery {
  final INursingRepository _repository;

  GetFamilyUsersQuery(this._repository);

  Future<Result<Failure, List<FamilyUser>>> execute() async {
    return _repository.getFamilyUsers();
  }
}
