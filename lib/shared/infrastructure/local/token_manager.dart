/// Manages the authentication session data in memory.
///
/// Acts as a session store for the authenticated user's
/// token and identity, accessible throughout the app lifecycle.
class TokenManager {
  static String? _token;
  static int? _administratorId;

  /// Saves the [token] and makes it available for the HTTP client.
  static void saveToken(String token) {
    _token = token;
    print('[TokenManager] Token updated: ${_token?.substring(0, 10)}...');
  }

  /// Saves the [administratorId] returned after authentication.
  static void saveAdministratorId(int id) {
    _administratorId = id;
    print('[TokenManager] Administrator ID saved: $id');
  }

  /// Retrieves the current token.
  static String? getToken() => _token;

  /// Retrieves the authenticated administrator's ID.
  static int? getAdministratorId() => _administratorId;

  /// Clears all session data (used on logout).
  static void clear() {
    _token = null;
    _administratorId = null;
  }

  static bool get isAuthenticated => _token != null;
}
