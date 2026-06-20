import '../../../shared/core/exceptions/exceptions.dart';
import '../../../shared/core/failures/failures.dart';
import '../../../shared/core/result/result.dart';
import '../../domain/entities/person_profile.dart';
import '../../domain/repositories/i_person_profile_repository.dart';
import '../datasources/person_profile_remote_datasource.dart';

class PersonProfileRepositoryImpl implements IPersonProfileRepository {
  final PersonProfileRemoteDataSource remoteDataSource;

  PersonProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<Failure, PersonProfile>> createPersonProfile({
    required String dni,
    required String firstName,
    required String lastName,
    required String birthDate,
    required int age,
    required String emailAddress,
    required String street,
    required String number,
    required String city,
    required String postalCode,
    required String country,
    required String phoneNumber,
  }) async {
    try {
      final model = await remoteDataSource.createPersonProfile(
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
      );

      return Result.success(model.toEntity());
    } on ServerException catch (e) {
      return Result.failure(
        ServerFailure(e.message, code: e.statusCode?.toString()),
      );
    } catch (e) {
      return Result.failure(
        ServerFailure('Unexpected person profile error: $e'),
      );
    }
  }
}
