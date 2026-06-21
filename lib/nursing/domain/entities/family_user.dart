import '../../../shared/domain/entities/entity.dart';

class FamilyUser extends Entity<int> {
  final String username;
  final List<String> roles;

  const FamilyUser({
    required super.id,
    required this.username,
    required this.roles,
  });

  bool get isFamily => roles.contains('ROLE_FAMILIAR');

  bool get hasEmailUsername => _emailPattern.hasMatch(username.trim());

  String get email => username.trim();

  String get displayName {
    final value = username.trim();
    if (value.isEmpty) return 'Family user #$id';
    if (!hasEmailUsername) return value;

    final localPart = value.split('@').first;
    return localPart
        .split(RegExp(r'[._-]+'))
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase() + part.substring(1))
        .join(' ');
  }

  String get firstName {
    final parts = displayName.split(' ').where((part) => part.isNotEmpty);
    return parts.isEmpty ? username.trim() : parts.first;
  }

  String get lastName {
    final parts = displayName.split(' ').where((part) => part.isNotEmpty);
    if (parts.length <= 1) return 'Family';
    return parts.skip(1).join(' ');
  }

  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
}
