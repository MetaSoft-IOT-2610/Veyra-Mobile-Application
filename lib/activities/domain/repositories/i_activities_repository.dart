import '../../../shared/core/result/result.dart';
import '../../../shared/core/failures/failures.dart';
import '../entities/activity.dart';

/// Repository contract for activity-related operations.
///
/// This abstraction defines the data access requirements of the
/// Activities bounded context without exposing implementation details.
abstract class IActivitiesRepository {

  /// Retrieves all activities associated with a nursing home.
  ///
  /// Returns:
  /// - [Result.success] containing a list of [Activity] entities.
  /// - [Result.failure] containing a domain [Failure].
  Future<Result<Failure, List<Activity>>> getActivitiesByNursingHome(int nursingHomeId);

  /// Creates a new activity for a nursing home.
  ///
  /// Parameters:
  /// - [nursingHomeId]: Target nursing home identifier.
  /// - [activity]: Activity entity to be persisted.
  ///
  /// Returns:
  /// - [Result.success] containing the created [Activity].
  /// - [Result.failure] containing a domain [Failure].
  Future<Result<Failure, Activity>> createActivity({
    required int nursingHomeId,
    required Activity activity,
  });
}
