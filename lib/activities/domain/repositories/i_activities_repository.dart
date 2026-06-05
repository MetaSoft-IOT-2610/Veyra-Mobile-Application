import '../../../shared/core/result/result.dart';
import '../../../shared/core/failures/failures.dart';
import '../entities/activity.dart';

abstract class IActivitiesRepository {
  /// Mapea con: GET /api/v1/nursing-homes/{nursingHomeId}/activities
  Future<Result<Failure, List<Activity>>> getActivitiesByNursingHome(int nursingHomeId);

  /// Mapea con: POST /api/v1/nursing-homes/{nursingHomeId}/activities
  Future<Result<Failure, Activity>> createActivity({
    required int nursingHomeId,
    required Activity activity,
  });
}