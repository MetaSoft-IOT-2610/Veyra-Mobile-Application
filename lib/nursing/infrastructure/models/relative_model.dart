import '../../domain/entities/relative.dart';

class RelativeModel {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final int residentId;
  final int nursingHomeId;
  final int? userId;

  const RelativeModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.residentId,
    required this.nursingHomeId,
    this.userId,
  });

  factory RelativeModel.fromJson(Map<String, dynamic> json) {
    return RelativeModel(
      id: _asInt(json['id']),
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      residentId: _asInt(json['residentId']),
      nursingHomeId: _asInt(json['nursingHomeId']),
      userId: json['userId'] == null ? null : _asInt(json['userId']),
    );
  }

  Relative toEntity() {
    return Relative(
      id: id,
      firstName: firstName,
      lastName: lastName,
      email: email,
      residentId: residentId,
      nursingHomeId: nursingHomeId,
      userId: userId,
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
