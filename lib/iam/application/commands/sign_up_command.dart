import '../../../shared/core/failures/failures.dart';
import '../../../shared/core/result/result.dart';
import '../../domain/repositories/i_auth_repository.dart';

/// Application use case for registering a new family user.
class SignUpCommand {
  final IAuthRepository _repository;

  SignUpCommand(this._repository);

  Future<Result<Failure, void>> execute({
    required String username,
    required String password,
    required String confirmPassword,
  }) async {
    final validation = _validate(username, password, confirmPassword);
    if (validation != null) return Result.failure(validation);

    return _repository.signUp(username.trim(), password);
  }

  Future<Result<Failure, int>> executeAdministrator({
    required String username,
    required String password,
    required String confirmPassword,
  }) async {
    final validation = _validate(username, password, confirmPassword);
    if (validation != null) return Result.failure(validation);

    return _repository.signUpAdministrator(username.trim(), password);
  }

  ValidationFailure? _validate(
    String username,
    String password,
    String confirmPassword,
  ) {
    if (username.trim().isEmpty || password.trim().isEmpty) {
      return const ValidationFailure('Username and password are required.');
    }

    if (password.length < 6) {
      return const ValidationFailure(
        'Password must have at least 6 characters.',
      );
    }

    if (password != confirmPassword) {
      return const ValidationFailure('Passwords do not match.');
    }

    return null;
  }
}
