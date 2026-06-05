class ResidentSummaryDto {
  final int totalResidents;
  final int totalRooms;
  final int availableRooms;
  final double occupancyRate;

  ResidentSummaryDto({
    required this.totalResidents,
    required this.totalRooms,
    required this.availableRooms,
  }) : occupancyRate = totalRooms == 0 ? 0.0 : ((totalRooms - availableRooms) / totalRooms) * 100;
}