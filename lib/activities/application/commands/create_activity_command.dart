import '../../../shared/core/failures/failures.dart';
import '../../../shared/core/result/result.dart';
import '../../domain/entities/activity.dart';
import '../../domain/repositories/i_activities_repository.dart';
import '../../domain/value_objects/activity_schedule.dart';

class CreateActivityCommand {
  final IActivitiesRepository _repository;

  CreateActivityCommand(this._repository);

  Future<Result<Failure, Activity>> execute({
    required int nursingHomeId,
    required int residentId,
    required int healthcareStaffId,
    required String type,
    required String title,
    required bool isRecurring,
    required List<String> recurringDays,
  }) async {
    final trimmedTitle = title.trim();

    if (residentId <= 0) {
      return Result.failure(ValidationFailure('Resident ID is required.'));
    }
    if (healthcareStaffId <= 0) {
      return Result.failure(ValidationFailure('Staff ID is required.'));
    }
    if (trimmedTitle.isEmpty) {
      return Result.failure(ValidationFailure('Activity title is required.'));
    }
    if (isRecurring && recurringDays.isEmpty) {
      return Result.failure(
        ValidationFailure('Select at least one recurring day.'),
      );
    }

    final now = DateTime.now();
    final activity = Activity(
      id: 0,
      nursingHomeId: nursingHomeId,
      residentId: residentId,
      healthcareStaffId: healthcareStaffId,
      type: type,
      title: trimmedTitle,
      schedule: ActivitySchedule(
        startTime: now,
        endTime: now.add(const Duration(hours: 1)),
      ),
      status: ActivityStatus.pending,
      isRecurring: isRecurring,
      recurringDays: isRecurring ? recurringDays : const [],
    );

    return _repository.createActivity(
      nursingHomeId: nursingHomeId,
      activity: activity,
    );
  }
}
