import '../../domain/entities/staff_contract.dart';

class StaffContractModel {
  final int id;
  final int staffMemberId;
  final String startDate;
  final String endDate;
  final String typeOfContract;
  final String staffRole;
  final String workShift;
  final String status;

  const StaffContractModel({
    required this.id,
    required this.staffMemberId,
    required this.startDate,
    required this.endDate,
    required this.typeOfContract,
    required this.staffRole,
    required this.workShift,
    required this.status,
  });

  factory StaffContractModel.fromJson(Map<String, dynamic> json) {
    return StaffContractModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      staffMemberId: (json['staffMemberId'] as num?)?.toInt() ?? 0,
      startDate: json['startDate'] as String? ?? '',
      endDate: json['endDate'] as String? ?? '',
      typeOfContract: json['typeOfContract'] as String? ?? '',
      staffRole: json['staffRole'] as String? ?? '',
      workShift: json['workShift'] as String? ?? '',
      status: json['status'] as String? ?? '',
    );
  }

  StaffContract toEntity() {
    return StaffContract(
      id: id,
      staffMemberId: staffMemberId,
      startDate: startDate,
      endDate: endDate,
      typeOfContract: typeOfContract,
      staffRole: staffRole,
      workShift: workShift,
      status: status,
    );
  }
}
