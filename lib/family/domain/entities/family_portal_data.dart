import '../../../activities/domain/entities/activity.dart';
import '../../../nursing/domain/entities/relative.dart';
import '../../../nursing/domain/entities/resident.dart';
import '../../../nursing/domain/entities/resident_health_record.dart';
import 'family_health_data.dart';

class FamilyPortalData {
  final Relative relative;
  final Resident resident;
  final FamilyResidentProfile residentProfile;
  final List<ResidentAllergy> allergies;
  final List<FamilyMedication> medications;
  final List<FamilyDevice> devices;
  final List<ResidentVitalSign> vitalSigns;
  final List<Activity> activities;

  const FamilyPortalData({
    required this.relative,
    required this.resident,
    required this.residentProfile,
    required this.allergies,
    required this.medications,
    required this.devices,
    required this.vitalSigns,
    required this.activities,
  });
}
