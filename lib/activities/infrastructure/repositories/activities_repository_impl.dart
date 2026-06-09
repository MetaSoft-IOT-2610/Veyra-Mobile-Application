import '../../../shared/core/failures/failures.dart';
import '../../../shared/core/result/result.dart';
import '../../../shared/core/exceptions/exceptions.dart';
import '../../domain/entities/activity.dart';
import '../../domain/repositories/i_activities_repository.dart';
import '../datasources/activities_remote_datasource.dart';
/// Repository implementation responsible for coordinating
/// activity data retrieval and transformation.
///
/// This class converts infrastructure models into
/// domain entities and translates technical exceptions
/// into standardized domain failures.
class ActivitiesRepositoryImpl implements IActivitiesRepository {
  /// Remote data source used to retrieve activities.
  final ActivitiesRemoteDataSource remoteDataSource;

  /// Creates a new repository instance.
  ActivitiesRepositoryImpl({required this.remoteDataSource});

  /// Retrieves activities belonging to a nursing home.
  ///
  /// Returns:
  /// - [Result.success] containing a list of domain entities.
  /// - [Result.failure] containing a domain failure.
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
  /// Creates a new activity.
  ///
  /// Currently not implemented.
  @override
  Future<Result<Failure, Activity>> createActivity({
    required int nursingHomeId,
    required Activity activity,
  }) async {
    // Implementación futura del POST
    throw UnimplementedError();
  }
}
