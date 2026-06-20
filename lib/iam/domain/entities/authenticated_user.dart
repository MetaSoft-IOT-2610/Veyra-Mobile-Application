class AuthenticatedUser {
  final int id;
  final String username;
  final List<String> roles;
  final int? entityId;

  const AuthenticatedUser({
    required this.id,
    required this.username,
    required this.roles,
    this.entityId,
  });

  bool get isAdministrator => roles.contains('ROLE_ADMIN');

  bool get isFamily => roles.contains('ROLE_FAMILIAR');
}
