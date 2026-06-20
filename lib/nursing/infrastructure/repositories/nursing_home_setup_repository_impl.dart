import '../../../shared/core/exceptions/exceptions.dart';
import '../../../shared/core/failures/failures.dart';
import '../../../shared/core/result/result.dart';
import '../../domain/entities/nursing_home.dart';
import '../../domain/repositories/i_nursing_home_setup_repository.dart';
import '../datasources/nursing_home_setup_remote_datasource.dart';

class NursingHomeSetupRepositoryImpl implements INursingHomeSetupRepository {
  final NursingHomeSetupRemoteDataSource remoteDataSource;

  NursingHomeSetupRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<Failure, NursingHome>> createNursingHome({
    required int administratorId,
    required String businessName,
    required String emailAddress,
    required String phoneNumber,
    required String street,
    required String number,
    required String city,
    required String postalCode,
    required String country,
    required String ruc,
  }) async {
    try {
      final model = await remoteDataSource.createNursingHome(
        administratorId: administratorId,
        businessName: businessName,
        emailAddress: emailAddress,
        phoneNumber: phoneNumber,
        street: street,
        number: number,
        city: city,
        postalCode: postalCode,
        country: country,
        ruc: ruc,
      );

      return Result.success(model.toEntity());
    } on ServerException catch (e) {
      return Result.failure(
        ServerFailure(e.message, code: e.statusCode?.toString()),
      );
    } catch (e) {
      return Result.failure(ServerFailure('Unexpected nursing home error: $e'));
    }
  }
}
