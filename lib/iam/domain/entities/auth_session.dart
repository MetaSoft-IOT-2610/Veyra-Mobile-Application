class AuthSession {
  final int? userId;
  final String? username;
  final int? administratorId;
  final int? staffId;
  final int? nursingHomeId;
  final List<String> roles;
  final bool requiresNursingHomeSetup;

  const AuthSession({
    required this.roles,
    this.userId,
    this.username,
    this.administratorId,
    this.staffId,
    this.nursingHomeId,
    this.requiresNursingHomeSetup = false,
  });

  bool get isAdministrator => _hasRole('ROLE_ADMIN');

  bool get isFamily => _hasRole('ROLE_FAMILIAR');

  bool get isDoctor => _hasRole('ROLE_DOCTOR');

  bool _hasRole(String role) =>
      roles.any((value) => value.trim().toUpperCase() == role);
}
