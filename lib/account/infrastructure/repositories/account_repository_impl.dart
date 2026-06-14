import '../../../shared/core/exceptions/exceptions.dart';
import '../../../shared/core/failures/failures.dart';
import '../../../shared/core/result/result.dart';
import '../../domain/entities/subscription.dart';
import '../../domain/repositories/i_account_repository.dart';
import '../datasources/account_remote_datasource.dart';

class AccountRepositoryImpl implements IAccountRepository {
  final AccountRemoteDataSource remoteDataSource;

  AccountRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<Failure, Subscription>> getActiveSubscription(
    int userId,
  ) async {
    try {
      final model = await remoteDataSource.getActiveSubscription(userId);
      return Result.success(model.toEntity());
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message));
    } catch (e) {
      return Result.failure(ServerFailure('Unexpected error: $e'));
    }
  }
}
