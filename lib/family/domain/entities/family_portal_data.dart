import '../../../activities/domain/entities/activity.dart';
import '../../../nursing/domain/entities/relative.dart';
import '../../../nursing/domain/entities/resident.dart';
import '../../../nursing/domain/entities/resident_health_record.dart';

class FamilyPortalData {
  final Relative relative;
  final Resident resident;
  final List<ResidentAllergy> allergies;
  final List<ResidentMedicalCondition> medicalConditions;
  final List<ResidentVitalSign> vitalSigns;
  final List<Activity> activities;

  const FamilyPortalData({
    required this.relative,
    required this.resident,
    required this.allergies,
    required this.medicalConditions,
    required this.vitalSigns,
    required this.activities,
  });
}
