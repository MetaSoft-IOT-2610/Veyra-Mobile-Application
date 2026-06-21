import '../../../shared/core/exceptions/exceptions.dart';
import '../../../shared/core/failures/failures.dart';
import '../../../shared/core/result/result.dart';
import '../../domain/entities/activity.dart';
import '../../domain/repositories/i_activities_repository.dart';
import '../datasources/activities_remote_datasource.dart';

class ActivitiesRepositoryImpl implements IActivitiesRepository {
  final ActivitiesRemoteDataSource remoteDataSource;

  ActivitiesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<Failure, List<Activity>>> getActivitiesByNursingHome(
    int nursingHomeId,
  ) async {
    try {
      final models = await remoteDataSource.getActivities(nursingHomeId);
      return Result.success(models.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Result.failure(
        ServerFailure(e.message, code: e.statusCode?.toString()),
      );
    } catch (e) {
      return Result.failure(
        ServerFailure('Error inesperado procesando actividades: $e'),
      );
    }
  }

  @override
  Future<Result<Failure, Activity>> createActivity({
    required int nursingHomeId,
    required Activity activity,
  }) async {
    try {
      final model = await remoteDataSource.createActivity(
        nursingHomeId: nursingHomeId,
        residentId: activity.residentId,
        healthcareStaffId: activity.healthcareStaffId,
        type: activity.type,
        title: activity.title,
        isRecurring: activity.isRecurring,
        recurringDays: activity.recurringDays,
      );
      return Result.success(model.toEntity());
    } on ServerException catch (e) {
      return Result.failure(
        ServerFailure(e.message, code: e.statusCode?.toString()),
      );
    } catch (e) {
      return Result.failure(ServerFailure('Error creando actividad: $e'));
    }
  }

  @override
  Future<Result<Failure, Activity>> advanceActivityStatus(
    int activityId,
  ) async {
    try {
      final model = await remoteDataSource.advanceActivityStatus(activityId);
      return Result.success(model.toEntity());
    } on ServerException catch (e) {
      return Result.failure(
        ServerFailure(e.message, code: e.statusCode?.toString()),
      );
    } catch (e) {
      return Result.failure(
        ServerFailure('Error actualizando estado de actividad: $e'),
      );
    }
  }

  @override
  Future<Result<Failure, void>> deleteActivity(int activityId) async {
    try {
      await remoteDataSource.deleteActivity(activityId);
      return Result.success(null);
    } on ServerException catch (e) {
      return Result.failure(
        ServerFailure(e.message, code: e.statusCode?.toString()),
      );
    } catch (e) {
      return Result.failure(ServerFailure('Error eliminando actividad: $e'));
    }
  }
}
