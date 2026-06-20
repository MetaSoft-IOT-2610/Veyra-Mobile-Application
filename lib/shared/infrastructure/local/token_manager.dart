/// Manages the authentication session data in memory.
///
/// Acts as a session store for the authenticated user's
/// token and identity, accessible throughout the app lifecycle.
class TokenManager {
  static String? _token;
  static int? _userId;
  static int? _administratorId;
  static int? _nursingHomeId;

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

  /// Saves the nursing home identifier associated with the administrator.
  static void saveNursingHomeId(int id) {
    _nursingHomeId = id;
    print('[TokenManager] Nursing Home ID saved: $id');
  }

  /// Saves the authenticated IAM user identifier.
  static void saveUserId(int id) {
    _userId = id;
    print('[TokenManager] User ID saved: $id');
  }

  /// Retrieves the current token.
  static String? getToken() => _token;

  /// Retrieves the authenticated IAM user's ID.
  static int? getUserId() => _userId;

  /// Retrieves the authenticated administrator's ID.
  static int? getAdministratorId() => _administratorId;

  /// Retrieves the authenticated administrator's nursing home ID.
  static int? getNursingHomeId() => _nursingHomeId;

  /// Clears all session data (used on logout).
  static void clear() {
    _token = null;
    _userId = null;
    _administratorId = null;
    _nursingHomeId = null;
  }

  static bool get isAuthenticated => _token != null;
}
