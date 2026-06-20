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
    final trimmedUsername = username.trim();

    if (trimmedUsername.isEmpty || password.trim().isEmpty) {
      return Result.failure(
        const ValidationFailure('Username and password are required.'),
      );
    }

    if (password.length < 6) {
      return Result.failure(
        const ValidationFailure('Password must have at least 6 characters.'),
      );
    }

    if (password != confirmPassword) {
      return Result.failure(const ValidationFailure('Passwords do not match.'));
    }

    return _repository.signUp(trimmedUsername, password);
  }
}
