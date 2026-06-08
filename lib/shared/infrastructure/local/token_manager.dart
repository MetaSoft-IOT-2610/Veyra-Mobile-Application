/// Manages the authentication token in memory.
///
/// Uses a singleton pattern to ensure the token is accessible
/// globally throughout the app lifecycle.
class TokenManager {
  static String? _token;

  /// Saves the [token] and makes it available for the HTTP client.
  static void saveToken(String token) {
    _token = token;
    print('[TokenManager] Token updated: ${_token?.substring(0, 10)}...');
  }

  /// Retrieves the current token.
  static String? getToken() => _token;

  /// Clears the token (used on logout).
  static void clear() {
    _token = null;
  }

  static bool get isAuthenticated => _token != null;
}
