import '../../domain/entities/resident.dart';

/// DTO de Infraestructura para el agregado Resident.
class ResidentModel {
  final int id;
  final String firstName;
  final String lastName;
  final String admissionDate;
  final String status;

  const ResidentModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.admissionDate,
    required this.status,
  });

  /// Factory para construir el modelo desde el JSON del backend.
  /// Incluye salvaguardas por si el backend retorna valores nulos.
  factory ResidentModel.fromJson(Map<String, dynamic> json) {
    return ResidentModel(
      id: json['id'] as int,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      admissionDate: json['admissionDate'] as String? ?? '',
      status: json['status'] as String? ?? 'ACTIVE',
    );
  }

  /// Transforma el modelo técnico en la entidad de dominio inmutable.
  Resident toEntity() {
    return Resident(
      id: id,
      firstName: firstName,
      lastName: lastName,
      admissionDate: admissionDate,
      status: status,
    );
  }
}