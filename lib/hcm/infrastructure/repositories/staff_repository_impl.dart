import '../../../shared/core/exceptions/exceptions.dart';
import '../../../shared/core/failures/failures.dart';
import '../../../shared/core/result/result.dart';
import '../../domain/entities/staff_contract.dart';
import '../../domain/entities/staff_member.dart';
import '../../domain/repositories/i_staff_repository.dart';
import '../datasources/staff_remote_datasource.dart';

class StaffRepositoryImpl implements IStaffRepository {
  final StaffRemoteDataSource remoteDataSource;

  StaffRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<Failure, List<StaffMember>>> getStaffByNursingHome(
    int nursingHomeId,
  ) async {
    return _run(() async {
      final models = await remoteDataSource.getStaff(nursingHomeId);
      return models.map((m) => m.toEntity()).toList();
    });
  }

  @override
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
  }) async {
    return _run(() async {
      final model = await remoteDataSource.createStaff(
        nursingHomeId: nursingHomeId,
        dni: dni,
        firstName: firstName,
        lastName: lastName,
        birthDate: birthDate,
        age: age,
        emailAddress: emailAddress,
        street: street,
        number: number,
        city: city,
        postalCode: postalCode,
        country: country,
        phoneNumber: phoneNumber,
        emergencyContactFirstName: emergencyContactFirstName,
        emergencyContactLastName: emergencyContactLastName,
        emergencyContactPhoneNumber: emergencyContactPhoneNumber,
      );
      return model.toEntity();
    });
  }

  @override
  Future<Result<Failure, List<StaffContract>>> getContracts(
    int staffMemberId,
  ) async {
    return _run(() async {
      final models = await remoteDataSource.getContracts(staffMemberId);
      return models.map((model) => model.toEntity()).toList();
    });
  }

  @override
  Future<Result<Failure, StaffContract>> addContract({
    required int staffMemberId,
    required DateTime startDate,
    required DateTime endDate,
    required String typeOfContract,
    required String staffRole,
    required String workShift,
  }) async {
    return _run(() async {
      final model = await remoteDataSource.addContract(
        staffMemberId: staffMemberId,
        startDate: startDate,
        endDate: endDate,
        typeOfContract: typeOfContract,
        staffRole: staffRole,
        workShift: workShift,
      );
      return model.toEntity();
    });
  }

  Future<Result<Failure, T>> _run<T>(Future<T> Function() action) async {
    try {
      return Result.success(await action());
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message));
    } catch (e) {
      return Result.failure(ServerFailure('Unexpected error: $e'));
    }
  }
}
