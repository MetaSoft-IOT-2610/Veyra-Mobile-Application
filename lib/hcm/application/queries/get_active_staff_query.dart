import '../../../shared/core/failures/failures.dart';
import '../../../shared/core/result/result.dart';
import '../../domain/entities/staff_member.dart';
import '../../domain/repositories/i_staff_repository.dart';

class GetActiveStaffQuery {
  final IStaffRepository _repository;

  GetActiveStaffQuery(this._repository);

  Future<Result<Failure, List<StaffMember>>> execute(int nursingHomeId) async {
    return _repository.getStaffByNursingHome(nursingHomeId);
  }
}
