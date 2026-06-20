import '../../../shared/domain/entities/entity.dart';

class StaffContract extends Entity<int> {
  final int staffMemberId;
  final String startDate;
  final String endDate;
  final String typeOfContract;
  final String staffRole;
  final String workShift;
  final String status;

  const StaffContract({
    required super.id,
    required this.staffMemberId,
    required this.startDate,
    required this.endDate,
    required this.typeOfContract,
    required this.staffRole,
    required this.workShift,
    required this.status,
  });

  bool get isActive => status.toUpperCase() == 'ACTIVE';
}
