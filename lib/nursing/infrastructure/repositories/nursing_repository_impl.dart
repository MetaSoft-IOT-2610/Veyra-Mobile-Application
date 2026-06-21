import '../../../shared/core/failures/failures.dart';
import '../../../shared/core/result/result.dart';
import '../../../shared/core/exceptions/exceptions.dart';
import '../../domain/entities/family_user.dart';
import '../../domain/entities/relative.dart';
import '../../domain/entities/resident.dart';
import '../../domain/entities/resident_health_record.dart';
import '../../domain/entities/room.dart';
import '../../domain/repositories/i_nursing_repository.dart';
import '../datasources/nursing_remote_datasource.dart';

class NursingRepositoryImpl implements INursingRepository {
  final NursingRemoteDataSource remoteDataSource;

  NursingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<Failure, List<Resident>>> getResidents(
    int nursingHomeId,
  ) async {
    try {
      final models = await remoteDataSource.getResidents(nursingHomeId);
      return Result.success(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message));
    } catch (e) {
      return Result.failure(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Result<Failure, Resident>> createResident({
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
    required String legalRepresentativeFirstName,
    required String legalRepresentativeLastName,
    required String legalRepresentativePhoneNumber,
    required String emergencyContactFirstName,
    required String emergencyContactLastName,
    required String emergencyContactPhoneNumber,
  }) async {
    try {
      final model = await remoteDataSource.createResident(
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
        legalRepresentativeFirstName: legalRepresentativeFirstName,
        legalRepresentativeLastName: legalRepresentativeLastName,
        legalRepresentativePhoneNumber: legalRepresentativePhoneNumber,
        emergencyContactFirstName: emergencyContactFirstName,
        emergencyContactLastName: emergencyContactLastName,
        emergencyContactPhoneNumber: emergencyContactPhoneNumber,
      );

      return Result.success(model.toEntity());
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message));
    } catch (e) {
      return Result.failure(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Result<Failure, List<Room>>> getRooms(int nursingHomeId) async {
    try {
      final models = await remoteDataSource.getRooms(nursingHomeId);
      return Result.success(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message));
    } catch (e) {
      return Result.failure(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Result<Failure, Resident>> assignRoom({
    required int nursingHomeId,
    required int residentId,
    required String roomNumber,
  }) async {
    return _run(() async {
      final model = await remoteDataSource.assignRoom(
        nursingHomeId: nursingHomeId,
        residentId: residentId,
        roomNumber: roomNumber,
      );
      return model.toEntity();
    });
  }

  @override
  Future<Result<Failure, List<ResidentAllergy>>> getAllergies(
    int residentId,
  ) async {
    return _run(() async {
      final models = await remoteDataSource.getAllergies(residentId);
      return models.map((model) => model.toEntity()).toList();
    });
  }

  @override
  Future<Result<Failure, ResidentAllergy>> registerAllergy({
    required int residentId,
    required String allergenName,
    required String reaction,
    required String typeOfAllergy,
    required String severityLevel,
  }) async {
    return _run(() async {
      final model = await remoteDataSource.registerAllergy(
        residentId: residentId,
        allergenName: allergenName,
        reaction: reaction,
        typeOfAllergy: typeOfAllergy,
        severityLevel: severityLevel,
      );
      return model.toEntity();
    });
  }

  @override
  Future<Result<Failure, List<ResidentMedicalCondition>>> getMedicalConditions(
    int residentId,
  ) async {
    return _run(() async {
      final models = await remoteDataSource.getMedicalConditions(residentId);
      return models.map((model) => model.toEntity()).toList();
    });
  }

  @override
  Future<Result<Failure, ResidentMedicalCondition>> registerMedicalCondition({
    required int residentId,
    required String diagnosisName,
    required DateTime diagnosisDate,
    required String status,
    required String notes,
  }) async {
    return _run(() async {
      final model = await remoteDataSource.registerMedicalCondition(
        residentId: residentId,
        diagnosisName: diagnosisName,
        diagnosisDate: diagnosisDate,
        status: status,
        notes: notes,
      );
      return model.toEntity();
    });
  }

  @override
  Future<Result<Failure, List<ResidentVitalSign>>> getVitalSigns(
    int residentId,
  ) async {
    return _run(() async {
      final models = await remoteDataSource.getVitalSigns(residentId);
      return models.map((model) => model.toEntity()).toList();
    });
  }

  @override
  Future<Result<Failure, List<Relative>>> getRelatives(
    int nursingHomeId,
  ) async {
    return _run(() async {
      final models = await remoteDataSource.getRelatives(nursingHomeId);
      return models.map((model) => model.toEntity()).toList();
    });
  }

  @override
  Future<Result<Failure, List<FamilyUser>>> getFamilyUsers() async {
    return _run(() async {
      final models = await remoteDataSource.getFamilyUsers();
      return models.map((model) => model.toEntity()).toList();
    });
  }

  @override
  Future<Result<Failure, Relative>> createRelative({
    required int nursingHomeId,
    required int residentId,
    required String firstName,
    required String lastName,
    required String email,
    required int userId,
  }) async {
    return _run(() async {
      final model = await remoteDataSource.createRelative(
        nursingHomeId: nursingHomeId,
        residentId: residentId,
        firstName: firstName,
        lastName: lastName,
        email: email,
        userId: userId,
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
