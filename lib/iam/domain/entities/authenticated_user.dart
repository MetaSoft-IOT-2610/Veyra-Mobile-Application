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

  bool get isAdministrator => _hasRole('ROLE_ADMIN');

  bool get isFamily => _hasRole('ROLE_FAMILIAR');

  bool get isDoctor => _hasRole('ROLE_DOCTOR');

  bool _hasRole(String role) =>
      roles.any((value) => value.trim().toUpperCase() == role);
}
