import '../../../shared/core/result/result.dart';
import '../../../shared/core/failures/failures.dart';
import '../entities/activity.dart';

/// Repository contract for activity-related operations.
///
/// This abstraction defines the data access requirements of the
/// Activities bounded context without exposing implementation details.
abstract class IActivitiesRepository {
  Future<Result<Failure, List<Activity>>> getActivitiesByNursingHome(
    int nursingHomeId,
  );

  Future<Result<Failure, Activity>> createActivity({
    required int nursingHomeId,
    required Activity activity,
  });

  Future<Result<Failure, Activity>> advanceActivityStatus(int activityId);

  Future<Result<Failure, void>> deleteActivity(int activityId);
}
