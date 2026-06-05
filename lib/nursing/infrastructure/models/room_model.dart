import '../../domain/entities/room.dart';

/// DTO de Infraestructura para el agregado Room.
class RoomModel {
  final int id;
  final String roomNumber;
  final String status;
  final int capacity;

  const RoomModel({
    required this.id,
    required this.roomNumber,
    required this.status,
    required this.capacity,
  });

  /// Factory para construir el modelo desde el JSON del backend.
  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] as int,
      roomNumber: json['roomNumber'] as String? ?? '',
      status: json['status'] as String? ?? 'AVAILABLE',
      capacity: json['capacity'] as int? ?? 1,
    );
  }

  /// Transforma el modelo técnico en la entidad de dominio.
  Room toEntity() {
    return Room(
      id: id,
      roomNumber: roomNumber,
      status: _mapStatus(status),
      capacity: capacity,
    );
  }

  /// Mapeador Anti-Corrupción interno para asegurar que los cambios de nomenclatura 
  /// en los strings del Backend no rompan el tipado fuerte de la aplicación móvil.
  RoomStatus _mapStatus(String rawStatus) {
    switch (rawStatus.toUpperCase()) {
      case 'OCCUPIED':
        return RoomStatus.occupied;
      case 'MAINTENANCE':
        return RoomStatus.maintenance;
      case 'AVAILABLE':
      default:
        return RoomStatus.available;
    }
  }
}