import '../../../shared/core/failures/failures.dart';
import '../../../shared/core/result/result.dart';
import '../entities/subscription.dart';

abstract class IAccountRepository {
  Future<Result<Failure, Subscription>> getActiveSubscription(int userId);
}