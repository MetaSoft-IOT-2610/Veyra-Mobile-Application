import '../../../shared/core/failures/failures.dart';
import '../../../shared/core/result/result.dart';
import '../../domain/entities/subscription.dart';
import '../../domain/repositories/i_account_repository.dart';

class GetActiveSubscriptionQuery {
  final IAccountRepository _repository;

  GetActiveSubscriptionQuery(this._repository);

  Future<Result<Failure, Subscription>> execute(int userId) async {
    if (userId <= 0) {
      return Result.failure(
        const ValidationFailure('Invalid user identifier.'),
      );
    }
    return await _repository.getActiveSubscription(userId);
  }
}
