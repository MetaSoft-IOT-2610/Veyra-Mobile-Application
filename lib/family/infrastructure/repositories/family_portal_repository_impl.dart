import '../../../shared/core/exceptions/exceptions.dart';
import '../../../shared/core/failures/failures.dart';
import '../../../shared/core/result/result.dart';
import '../../domain/entities/family_portal_data.dart';
import '../../domain/repositories/i_family_portal_repository.dart';
import '../datasources/family_portal_remote_datasource.dart';

class FamilyPortalRepositoryImpl implements IFamilyPortalRepository {
  final FamilyPortalRemoteDataSource remoteDataSource;

  FamilyPortalRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<Failure, FamilyPortalData>> getPortalData(int userId) async {
    try {
      final data = await remoteDataSource.getPortalData(userId);
      return Result.success(
        FamilyPortalData(
          relative: data.relative.toEntity(),
          resident: data.resident.toEntity(),
          residentProfile: data.residentProfile.toEntity(),
          allergies: data.allergies.map((item) => item.toEntity()).toList(),
          medications: data.medications.map((item) => item.toEntity()).toList(),
          devices: data.devices.map((item) => item.toEntity()).toList(),
          measurements: data.measurements.map((item) => item.toEntity()).toList(),
          activities: data.activities.map((item) => item.toEntity()).toList(),
        ),
      );
    } on ServerException catch (e) {
      return Result.failure(
        ServerFailure(e.message, code: e.statusCode?.toString()),
      );
    } catch (e) {
      return Result.failure(
        ServerFailure('Unexpected family portal error: $e'),
      );
    }
  }
}
