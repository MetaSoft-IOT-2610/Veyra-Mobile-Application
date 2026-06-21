import '../../../nursing/domain/entities/resident_health_record.dart';

class ResidentClinicalRecord {
  final List<ResidentAllergy> allergies;
  final List<ResidentMedicalCondition> medicalConditions;
  final List<ResidentVitalSign> vitalSigns;

  const ResidentClinicalRecord({
    required this.allergies,
    required this.medicalConditions,
    required this.vitalSigns,
  });
}
