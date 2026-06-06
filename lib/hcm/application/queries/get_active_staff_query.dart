import '../../../shared/core/result/result.dart';
import '../../../shared/core/failures/failures.dart';
import '../../domain/entities/staff_member.dart';
import '../../domain/repositories/i_staff_repository.dart';

class GetActiveStaffQuery {
  final IStaffRepository _repository;

  GetActiveStaffQuery(this._repository);

  Future<Result<Failure, List<StaffMember>>> execute(int nursingHomeId) async {
    final result = await _repository.getStaffByNursingHome(nursingHomeId);

    // Regla de negocio en la query: Retornar solo el personal que está activo hoy
    return result.fold(
          (failure) => Result.failure(failure),
          (staffList) {
        final activeStaff = staffList.where((staff) => staff.isActive).toList();
        return Result.success(activeStaff);
      },
    );
  }
}
