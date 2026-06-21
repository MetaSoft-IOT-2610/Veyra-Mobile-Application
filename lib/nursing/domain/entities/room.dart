import '../../../shared/domain/entities/entity.dart';

enum RoomStatus { available, occupied, maintenance }

class Room extends Entity<int> {
  final String roomNumber;
  final RoomStatus status;
  final int capacity;

  const Room({
    required super.id,
    required this.roomNumber,
    required this.status,
    required this.capacity,
  });

  bool get isAvailable => status == RoomStatus.available;
}
