import '../../../shared/core/failures/failures.dart';
import '../../../shared/core/result/result.dart';
import '../../domain/entities/subscription.dart';
import '../../domain/repositories/i_account_repository.dart';

class CreateSubscriptionCommand {
  final IAccountRepository _repository;

  CreateSubscriptionCommand(this._repository);

  Future<Result<Failure, Subscription>> execute({
    required int userId,
    required String planType,
    required String period,
  }) async {
    if (userId <= 0) {
      return Result.failure(
        const ValidationFailure('A valid user is required.'),
      );
    }

    if (planType.isEmpty || period.isEmpty) {
      return Result.failure(
        const ValidationFailure('Please select a subscription plan.'),
      );
    }

    return _repository.createSubscription(
      userId: userId,
      planType: planType,
      period: period,
      paymentMethodId: 'pm_dev_placeholder',
    );
  }
}
