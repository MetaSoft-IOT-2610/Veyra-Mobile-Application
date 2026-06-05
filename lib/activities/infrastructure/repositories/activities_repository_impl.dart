import '../../../shared/core/failures/failures.dart';
import '../../../shared/core/result/result.dart';
import '../../../shared/core/exceptions/exceptions.dart';
import '../../domain/entities/activity.dart';
import '../../domain/repositories/i_activities_repository.dart';
import '../datasources/activities_remote_datasource.dart';

class ActivitiesRepositoryImpl implements IActivitiesRepository {
  final ActivitiesRemoteDataSource remoteDataSource;

  ActivitiesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<Failure, List<Activity>>> getActivitiesByNursingHome(int nursingHomeId) async {
    try {
      final models = await remoteDataSource.getActivities(nursingHomeId);
      
      // Transformamos la lista de Models a Entities puras
      final entities = models.map((model) => model.toEntity()).toList();
      
      return Result.success(entities);
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message, code: e.statusCode?.toString()));
    } catch (e) {
      return Result.failure(ServerFailure('Error inesperado procesando actividades: $e'));
    }
  }

  @override
  Future<Result<Failure, Activity>> createActivity({
    required int nursingHomeId,
    required Activity activity,
  }) async {
    // Implementación futura del POST
    throw UnimplementedError();
  }
}