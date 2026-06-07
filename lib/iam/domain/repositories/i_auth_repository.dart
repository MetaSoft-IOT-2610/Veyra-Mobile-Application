import '../../../shared/core/failures/failures.dart';
import '../../../shared/core/result/result.dart';

/// Contract for Authentication and Identity Management operations.
///
/// This repository interface isolates the application layer from the specific
/// implementation of the authentication mechanism (e.g., REST API, Firebase).
abstract class IAuthRepository {
  /// Authenticates a user with [username] and [password].
  ///
  /// Returns a [Result] containing the [nursingHomeId] associated with the
  /// authenticated administrator upon success, or a [Failure] if it fails.
  Future<Result<Failure, int>> login(String username, String password);
}
