import '../../../app/di/dependency_injection.dart';
import '../../../hcm/domain/entities/staff_member.dart';
import '../../../hcm/domain/repositories/i_staff_repository.dart';
import '../../../nursing/domain/entities/resident.dart';
import '../../../nursing/domain/repositories/i_nursing_repository.dart';

class ActivityDirectoryOptions {
  const ActivityDirectoryOptions({
    required this.residents,
    required this.staff,
  });

  final List<Resident> residents;
  final List<StaffMember> staff;

  Map<int, String> get residentNames => {
    for (final resident in residents) resident.id: resident.fullName,
    for (final resident in residents)
      if (resident.personProfileId > 0)
        resident.personProfileId: resident.fullName,
  };

  Map<int, String> get staffNames => {
    for (final member in staff) member.id: member.fullName,
    for (final member in staff)
      if (member.personProfileId > 0) member.personProfileId: member.fullName,
  };
}

Future<ActivityDirectoryOptions> loadActivityDirectoryOptions(
  int nursingHomeId,
) async {
  final residentsResult = await locator<INursingRepository>().getResidents(
    nursingHomeId,
  );
  final staffResult = await locator<IStaffRepository>().getStaffByNursingHome(
    nursingHomeId,
  );

  final residents = residentsResult.fold<List<Resident>>(
    (failure) => throw Exception(failure.message),
    (data) => data,
  );
  final staff = staffResult.fold<List<StaffMember>>(
    (failure) => throw Exception(failure.message),
    (data) => data.where((member) => member.isActive).toList(),
  );
  return ActivityDirectoryOptions(residents: residents, staff: staff);
}
