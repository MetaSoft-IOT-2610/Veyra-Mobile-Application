import '../../../shared/core/failures/failures.dart';
import '../../../shared/core/result/result.dart';
import '../entities/staff_contract.dart';
import '../entities/staff_member.dart';

abstract class IStaffRepository {
  Future<Result<Failure, List<StaffMember>>> getStaffByNursingHome(
    int nursingHomeId,
  );

  Future<Result<Failure, StaffMember>> createStaff({
    required int nursingHomeId,
    required String dni,
    required String firstName,
    required String lastName,
    required DateTime birthDate,
    required int age,
    required String emailAddress,
    required String street,
    required String number,
    required String city,
    required String postalCode,
    required String country,
    required String phoneNumber,
    required String emergencyContactFirstName,
    required String emergencyContactLastName,
    required String emergencyContactPhoneNumber,
  });

  Future<Result<Failure, List<StaffContract>>> getContracts(int staffMemberId);

  Future<Result<Failure, StaffContract>> addContract({
    required int staffMemberId,
    required DateTime startDate,
    required DateTime endDate,
    required String typeOfContract,
    required String staffRole,
    required String workShift,
  });
}
