import '../../domain/entities/resident_health_record.dart';

class ResidentAllergyModel {
  final int id;
  final String allergenName;
  final String reaction;
  final String severityLevel;
  final String typeOfAllergy;

  const ResidentAllergyModel({
    required this.id,
    required this.allergenName,
    required this.reaction,
    required this.severityLevel,
    required this.typeOfAllergy,
  });

  factory ResidentAllergyModel.fromJson(Map<String, dynamic> json) {
    return ResidentAllergyModel(
      id: (json['id'] as num? ?? 0).toInt(),
      allergenName: json['allergenName'] as String? ?? '',
      reaction: json['reaction'] as String? ?? '',
      severityLevel: json['severityLevel'] as String? ?? 'LOW',
      typeOfAllergy: json['typeOfAllergy'] as String? ?? '',
    );
  }

  ResidentAllergy toEntity() => ResidentAllergy(
    id: id,
    allergenName: allergenName,
    reaction: reaction,
    severityLevel: severityLevel,
    typeOfAllergy: typeOfAllergy,
  );
}

class ResidentMedicalConditionModel {
  final int id;
  final String diagnosisName;
  final String diagnosisDate;
  final String status;
  final String notes;

  const ResidentMedicalConditionModel({
    required this.id,
    required this.diagnosisName,
    required this.diagnosisDate,
    required this.status,
    required this.notes,
  });

  factory ResidentMedicalConditionModel.fromJson(Map<String, dynamic> json) {
    return ResidentMedicalConditionModel(
      id: (json['id'] as num? ?? 0).toInt(),
      diagnosisName: json['diagnosisName'] as String? ?? '',
      diagnosisDate: json['diagnosisDate'] as String? ?? '',
      status: json['status'] as String? ?? 'ACTIVE',
      notes: json['notes'] as String? ?? '',
    );
  }

  ResidentMedicalCondition toEntity() => ResidentMedicalCondition(
    id: id,
    diagnosisName: diagnosisName,
    diagnosisDate: diagnosisDate,
    status: status,
    notes: notes,
  );
}

class ResidentVitalSignModel {
  final int id;
  final String measurementId;
  final String severityLevel;

  const ResidentVitalSignModel({
    required this.id,
    required this.measurementId,
    required this.severityLevel,
  });

  factory ResidentVitalSignModel.fromJson(Map<String, dynamic> json) {
    return ResidentVitalSignModel(
      id: (json['id'] as num? ?? 0).toInt(),
      measurementId: json['measurementId'] as String? ?? '',
      severityLevel: json['severityLevel'] as String? ?? 'NORMAL',
    );
  }

  ResidentVitalSign toEntity() => ResidentVitalSign(
    id: id,
    measurementId: measurementId,
    severityLevel: severityLevel,
  );
}
