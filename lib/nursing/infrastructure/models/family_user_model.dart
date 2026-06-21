import '../../domain/entities/family_user.dart';

class FamilyUserModel {
  final int id;
  final String username;
  final List<String> roles;

  const FamilyUserModel({
    required this.id,
    required this.username,
    required this.roles,
  });

  factory FamilyUserModel.fromJson(Map<String, dynamic> json) {
    return FamilyUserModel(
      id: _asInt(json['id']),
      username: json['username'] as String? ?? '',
      roles: (json['roles'] as List<dynamic>? ?? [])
          .map((role) => role.toString())
          .toList(),
    );
  }

  FamilyUser toEntity() {
    return FamilyUser(id: id, username: username, roles: roles);
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
