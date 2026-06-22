import 'package:shared_preferences/shared_preferences.dart';

class TokenManager {
  static const _tokenKey = 'auth_token';
  static const _userIdKey = 'auth_user_id';
  static const _administratorIdKey = 'auth_administrator_id';
  static const _staffIdKey = 'auth_staff_id';
  static const _nursingHomeIdKey = 'auth_nursing_home_id';
  static const _rolesKey = 'auth_roles';

  static SharedPreferences? _preferences;
  static String? _token;
  static int? _userId;
  static int? _administratorId;
  static int? _staffId;
  static int? _nursingHomeId;
  static List<String> _roles = const [];

  static Future<void> initialize() async {
    _preferences = await SharedPreferences.getInstance();
    _token = _preferences?.getString(_tokenKey);
    _userId = _preferences?.getInt(_userIdKey);
    _administratorId = _preferences?.getInt(_administratorIdKey);
    _staffId = _preferences?.getInt(_staffIdKey);
    _nursingHomeId = _preferences?.getInt(_nursingHomeIdKey);
    _roles = _preferences?.getStringList(_rolesKey) ?? const [];
  }

  /// Saves the [token] and makes it available for the HTTP client.
  static void saveToken(String token) {
    _token = token;
    _preferences?.setString(_tokenKey, token);
  }

  /// Saves the [administratorId] returned after authentication.
  static void saveAdministratorId(int id) {
    _administratorId = id;
    _preferences?.setInt(_administratorIdKey, id);
  }

  static void saveStaffId(int id) {
    _staffId = id;
    _preferences?.setInt(_staffIdKey, id);
  }

  /// Saves the nursing home identifier associated with the administrator.
  static void saveNursingHomeId(int id) {
    _nursingHomeId = id;
    _preferences?.setInt(_nursingHomeIdKey, id);
  }

  /// Saves the authenticated IAM user identifier.
  static void saveUserId(int id) {
    _userId = id;
    _preferences?.setInt(_userIdKey, id);
  }

  static void saveRoles(List<String> roles) {
    _roles = List.unmodifiable(roles);
    _preferences?.setStringList(_rolesKey, roles);
  }

  /// Retrieves the current token.
  static String? getToken() => _token;

  /// Retrieves the authenticated IAM user's ID.
  static int? getUserId() => _userId;

  /// Retrieves the authenticated administrator's ID.
  static int? getAdministratorId() => _administratorId;

  static int? getStaffId() => _staffId;

  /// Retrieves the authenticated administrator's nursing home ID.
  static int? getNursingHomeId() => _nursingHomeId;

  static List<String> getRoles() => List.unmodifiable(_roles);

  /// Clears all session data (used on logout).
  static void clear() {
    _token = null;
    _userId = null;
    _administratorId = null;
    _staffId = null;
    _nursingHomeId = null;
    _roles = const [];
    _preferences?.clear();
  }

  static bool get isAuthenticated => _token?.isNotEmpty ?? false;
}
