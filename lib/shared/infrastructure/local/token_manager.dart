/// Centralized Authentication Token Manager.
/// Keeps the session active in memory while the app is open.

class TokenManager {
  static String? _token;

  static void saveToken(String token) {
    _token = token;
  }

  static String? getToken() => _token;

  static void clear() {
    _token = null;
  }

  static bool get isAuthenticated => _token != null;
}
