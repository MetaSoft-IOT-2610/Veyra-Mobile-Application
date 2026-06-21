class AuthSession {
  final int? userId;
  final String? username;
  final int? administratorId;
  final int? staffId;
  final int? nursingHomeId;
  final List<String> roles;
  final bool requiresNursingHomeSetup;
  final bool requiresPersonProfileSetup;

  const AuthSession({
    required this.roles,
    this.userId,
    this.username,
    this.administratorId,
    this.staffId,
    this.nursingHomeId,
    this.requiresNursingHomeSetup = false,
    this.requiresPersonProfileSetup = false,
  });

  bool get isAdministrator => roles.contains('ROLE_ADMIN');

  bool get isFamily => roles.contains('ROLE_FAMILIAR');

  bool get isDoctor => roles.contains('ROLE_DOCTOR');
}
