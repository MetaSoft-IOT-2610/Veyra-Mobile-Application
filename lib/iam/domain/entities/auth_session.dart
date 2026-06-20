class AuthSession {
  final int? nursingHomeId;
  final List<String> roles;

  const AuthSession({required this.roles, this.nursingHomeId});

  bool get isAdministrator => roles.contains('ROLE_ADMIN');

  bool get isFamily => roles.contains('ROLE_FAMILIAR');
}
