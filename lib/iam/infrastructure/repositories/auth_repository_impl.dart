import '../../../shared/core/failures/failures.dart';
import '../../../shared/core/result/result.dart';
import '../../../shared/core/exceptions/exceptions.dart';
import '../../domain/entities/auth_session.dart';
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
  Future<Result<Failure, AuthSession>> login(
    String username,
    String password,
  ) async {
    try {
      final authenticatedUser = await remoteDataSource.authenticate(
        username,
        password,
      );

      if (authenticatedUser.isFamily) {
        return Result.success(AuthSession(roles: authenticatedUser.roles));
      }

      if (authenticatedUser.isAdministrator) {
        final adminId = authenticatedUser.entityId;
        if (adminId == null) {
          return Result.failure(
            const ServerFailure(
              'Administrator profile was not found for this user.',
            ),
          );
        }

        try {
          final nursingHomeId = await remoteDataSource.getNursingHomeId(
            adminId,
          );

          return Result.success(
            AuthSession(
              roles: authenticatedUser.roles,
              administratorId: adminId,
              nursingHomeId: nursingHomeId,
            ),
          );
        } on ServerException catch (e) {
          if (e.statusCode == 404) {
            return Result.success(
              AuthSession(
                roles: authenticatedUser.roles,
                administratorId: adminId,
                requiresNursingHomeSetup: true,
              ),
            );
          }
          rethrow;
        }
      }

      return Result.failure(
        const ServerFailure('This role is not supported in the mobile app.'),
      );
    } on ServerException catch (e) {
      return Result.failure(
        ServerFailure(e.message, code: e.statusCode?.toString()),
      );
    } catch (e) {
      return Result.failure(
        ServerFailure('Unexpected authentication error: $e'),
      );
    }
  }

  @override
  Future<Result<Failure, void>> signUp(String username, String password) async {
    try {
      await remoteDataSource.signUp(username, password);
      return Result.success(null);
    } on ServerException catch (e) {
      return Result.failure(
        ServerFailure(e.message, code: e.statusCode?.toString()),
      );
    } catch (e) {
      return Result.failure(ServerFailure('Unexpected sign up error: $e'));
    }
  }

  @override
  Future<Result<Failure, int>> signUpAdministrator(
    String username,
    String password,
  ) async {
    try {
      final administratorId = await remoteDataSource.signUpAdministrator(
        username,
        password,
      );
      return Result.success(administratorId);
    } on ServerException catch (e) {
      return Result.failure(
        ServerFailure(e.message, code: e.statusCode?.toString()),
      );
    } catch (e) {
      return Result.failure(
        ServerFailure('Unexpected administrator sign up error: $e'),
      );
    }
  }
}
