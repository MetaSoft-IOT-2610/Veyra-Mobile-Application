import '../../../shared/core/result/result.dart';
import '../../../shared/core/failures/failures.dart';
import '../../domain/repositories/i_auth_repository.dart';

/// Application Use Case for executing the Login flow.
class LoginCommand {
  final IAuthRepository _repository;

  LoginCommand(this._repository);

  /// Executes the authentication process.
  ///
  /// Returns the [nursingHomeId] required to initialize the Dashboard
  /// upon a successful login.
  Future<Result<Failure, int>> execute(String username, String password) async {
    if (username.trim().isEmpty || password.trim().isEmpty) {
      return Result.failure(const ValidationFailure('Username and password are required.'));
    }

    return await _repository.login(username, password);
  }
}
