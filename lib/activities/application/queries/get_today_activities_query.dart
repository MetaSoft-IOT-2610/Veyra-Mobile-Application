import '../../../shared/core/result/result.dart';
import '../../../shared/core/failures/failures.dart';
import '../../domain/entities/activity.dart';
import '../../domain/repositories/i_activities_repository.dart';

/// Application Query responsible for retrieving activities scheduled
/// for the current day.
///
/// This query encapsulates application-specific logic by:
/// - Validating input parameters.
/// - Retrieving activities from the repository.
/// - Filtering activities to include only those scheduled for today.
/// - Sorting the resulting activities by start time.
///
/// By centralizing this logic, the Presentation layer remains focused
/// on displaying data rather than performing business operations.
class GetTodayActivitiesQuery {
  /// Repository used to retrieve activity data.
  final IActivitiesRepository _repository;

  /// Creates a new query instance.
  ///
  /// The repository dependency is injected to maintain
  /// loose coupling between layers.
  GetTodayActivitiesQuery(this._repository);

  /// Retrieves and filters activities scheduled for the current day.
  ///
  /// Parameters:
  /// - [nursingHomeId]: Unique identifier of the nursing home.
  ///
  /// Returns:
  /// - [Result.success] containing a list of today's [Activity]
  ///   instances ordered by start time.
  /// - [Result.failure] containing a [ValidationFailure] or any
  ///   repository-related failure.
  ///
  /// Validation Rules:
  /// - The nursing home identifier must be greater than zero.
  ///
  /// Business Rules:
  /// - Only activities whose start date matches the current date
  ///   (year, month, and day) are included.
  /// - Activities are sorted chronologically using their
  ///   scheduled start time.
  ///
  /// Example:
  /// ```dart
  /// final result = await query.execute(1);
  ///
  /// result.fold(
  ///   (failure) => print(failure.message),
  ///   (activities) => print('Activities found: ${activities.length}'),
  /// );
  /// ```
  Future<Result<Failure, List<Activity>>> execute(int nursingHomeId) async {
    if (nursingHomeId <= 0) {
      return Result.failure(
        const ValidationFailure('Invalid nursing home identifier.'),
      );
    }

    final result = await _repository.getActivitiesByNursingHome(nursingHomeId);

    return result.fold((failure) => Result.failure(failure), (activities) {
      final now = DateTime.now();

      final todayActivities = activities.where((activity) {
        final startTime = activity.schedule.startTime;

        return startTime.year == now.year &&
            startTime.month == now.month &&
            startTime.day == now.day;
      }).toList();

      todayActivities.sort(
        (a, b) => a.schedule.startTime.compareTo(b.schedule.startTime),
      );

      return Result.success(todayActivities);
    });
  }
}
