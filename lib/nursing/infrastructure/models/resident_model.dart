import '../../domain/entities/resident.dart';

/// DTO de Infraestructura para el agregado Resident.
class ResidentModel {
  final int id;
  final int personProfileId;
  final String firstName;
  final String lastName;
  final String admissionDate;
  final String status;
  final String legalRepresentativeFirstName;
  final String legalRepresentativeLastName;
  final String legalRepresentativePhoneNumber;
  final String emergencyContactFirstName;
  final String emergencyContactLastName;
  final String emergencyContactPhoneNumber;
  final int? roomId;
  final String photo;

  const ResidentModel({
    required this.id,
    required this.personProfileId,
    required this.firstName,
    required this.lastName,
    required this.admissionDate,
    required this.status,
    required this.legalRepresentativeFirstName,
    required this.legalRepresentativeLastName,
    required this.legalRepresentativePhoneNumber,
    required this.emergencyContactFirstName,
    required this.emergencyContactLastName,
    required this.emergencyContactPhoneNumber,
    this.roomId,
    this.photo = '',
  });

  /// Factory para construir el modelo desde el JSON del backend.
  /// Incluye salvaguardas por si el backend retorna valores nulos.
  factory ResidentModel.fromJson(Map<String, dynamic> json) {
    final profile = json['personProfile'] is Map
        ? json['personProfile'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final fullName =
        (json['fullName'] as String?) ??
        (json['name'] as String?) ??
        (profile['fullName'] as String?) ??
        '';
    final nameParts = fullName.trim().split(RegExp(r'\s+'));
    final parsedFirstName = nameParts.isNotEmpty ? nameParts.first : '';
    final parsedLastName = nameParts.length > 1
        ? nameParts.skip(1).join(' ')
        : '';

    return ResidentModel(
      id: (json['id'] as num? ?? 0).toInt(),
      personProfileId: (json['personProfileId'] as num? ?? 0).toInt(),
      firstName:
          json['firstName'] as String? ??
          profile['firstName'] as String? ??
          parsedFirstName,
      lastName:
          json['lastName'] as String? ??
          profile['lastName'] as String? ??
          parsedLastName,
      admissionDate: json['admissionDate'] as String? ?? '',
      status: json['status'] as String? ?? 'ACTIVE',
      legalRepresentativeFirstName:
          json['legalRepresentativeFirstName'] as String? ?? '',
      legalRepresentativeLastName:
          json['legalRepresentativeLastName'] as String? ?? '',
      legalRepresentativePhoneNumber:
          json['legalRepresentativePhoneNumber'] as String? ?? '',
      emergencyContactFirstName:
          json['emergencyContactFirstName'] as String? ?? '',
      emergencyContactLastName:
          json['emergencyContactLastName'] as String? ?? '',
      emergencyContactPhoneNumber:
          json['emergencyContactPhoneNumber'] as String? ?? '',
      roomId: (json['roomId'] as num?)?.toInt(),
      photo:
          json['photo'] as String? ??
          profile['photo'] as String? ??
          '',
    );
  }

  /// Transforma el modelo técnico en la entidad de dominio inmutable.
  Resident toEntity() {
    return Resident(
      id: id,
      personProfileId: personProfileId,
      firstName: firstName,
      lastName: lastName,
      admissionDate: admissionDate,
      status: status,
      legalRepresentativeFirstName: legalRepresentativeFirstName,
      legalRepresentativeLastName: legalRepresentativeLastName,
      legalRepresentativePhoneNumber: legalRepresentativePhoneNumber,
      emergencyContactFirstName: emergencyContactFirstName,
      emergencyContactLastName: emergencyContactLastName,
      emergencyContactPhoneNumber: emergencyContactPhoneNumber,
      roomId: roomId,
      photo: photo,
    );
  }
}
