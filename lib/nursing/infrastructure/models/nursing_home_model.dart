import '../../domain/entities/nursing_home.dart';

class NursingHomeModel {
  final int id;
  final int businessProfileId;
  final int administratorId;

  const NursingHomeModel({
    required this.id,
    required this.businessProfileId,
    required this.administratorId,
  });

  factory NursingHomeModel.fromJson(Map<String, dynamic> json) {
    return NursingHomeModel(
      id: (json['id'] as num? ?? 0).toInt(),
      businessProfileId: (json['businessProfileId'] as num? ?? 0).toInt(),
      administratorId: (json['administratorId'] as num? ?? 0).toInt(),
    );
  }

  NursingHome toEntity() {
    return NursingHome(
      id: id,
      businessProfileId: businessProfileId,
      administratorId: administratorId,
    );
  }
}
