class AuthSession {
  final int? userId;
  final int? administratorId;
  final int? nursingHomeId;
  final List<String> roles;
  final bool requiresNursingHomeSetup;

  const AuthSession({
    required this.roles,
    this.userId,
    this.administratorId,
    this.nursingHomeId,
    this.requiresNursingHomeSetup = false,
  });

  bool get isAdministrator => roles.contains('ROLE_ADMIN');

  bool get isFamily => roles.contains('ROLE_FAMILIAR');
}
