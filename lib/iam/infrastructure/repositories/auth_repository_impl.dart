import '../../../shared/core/failures/failures.dart';
import '../../../shared/core/result/result.dart';
import '../../../shared/core/exceptions/exceptions.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../datasources/iam_remote_datasource.dart';

/// Concrete implementation of [IAuthRepository].
///
/// Orchestrates the data source calls and maps technical exceptions
/// into pure Domain [Failure] objects.
class AuthRepositoryImpl implements IAuthRepository {
  final IamRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<Failure, int>> login(String username, String password) async {
    try {
      // 1. Authenticate and retrieve Administrator ID
      final int adminId = await remoteDataSource.authenticate(username, password);

      // 2. Retrieve the Nursing Home ID managed by this Administrator
      final int nursingHomeId = await remoteDataSource.getNursingHomeId(adminId);

      return Result.success(nursingHomeId);
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message, code: e.statusCode?.toString()));
    } catch (e) {
      return Result.failure(ServerFailure('Unexpected authentication error: $e'));
    }
  }
}
