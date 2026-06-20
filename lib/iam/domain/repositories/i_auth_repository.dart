import '../../../shared/core/failures/failures.dart';
import '../../../shared/core/result/result.dart';
import '../entities/auth_session.dart';

/// Contract for Authentication and Identity Management operations.
///
/// This repository interface isolates the application layer from the specific
/// implementation of the authentication mechanism (e.g., REST API, Firebase).
abstract class IAuthRepository {
  /// Authenticates a user with [username] and [password].
  ///
  /// Returns a [Result] containing the authenticated session destination.
  Future<Result<Failure, AuthSession>> login(String username, String password);

  /// Registers a new family user.
  Future<Result<Failure, void>> signUp(String username, String password);

  /// Registers a new administrator and returns its aggregate identifier.
  Future<Result<Failure, int>> signUpAdministrator(
    String username,
    String password,
  );
}
