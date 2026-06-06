import '../../../shared/core/result/result.dart';
import '../../../shared/core/failures/failures.dart';
import '../entities/staff_member.dart';

abstract class IStaffRepository {
  Future<Result<Failure, List<StaffMember>>> getStaffByNursingHome(int nursingHomeId);
}
