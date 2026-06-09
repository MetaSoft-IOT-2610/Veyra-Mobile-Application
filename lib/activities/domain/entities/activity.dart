import '../../../shared/domain/entities/entity.dart';
import '../value_objects/activity_schedule.dart';

/// Represents the possible lifecycle states of an activity.
enum ActivityStatus {
  /// Activity has been scheduled but has not started yet.
  scheduled,

  /// Activity is currently in progress.
  inProgress,

  /// Activity has finished successfully.
  completed,

  /// Activity has been cancelled.
  cancelled
}

/// Represents an activity scheduled within a nursing home.
///
/// This domain entity encapsulates all business information related
/// to an activity, including its schedule, description, and current status.
///
/// The entity is immutable. Any state transition creates a new instance
/// rather than modifying the existing one.
class Activity extends Entity<int> {
  /// Activity title displayed to users.
  final String name;

  /// Detailed description of the activity.
  final String description;

  /// Value Object containing the activity schedule.
  final ActivitySchedule schedule;

  /// Current lifecycle status of the activity.
  final ActivityStatus status;

  /// Creates a new [Activity] instance.
  const Activity({
    required super.id,
    required this.name,
    required this.description,
    required this.schedule,
    required this.status,
  });

  /// Cancels the activity.
  ///
  /// Business Rules:
  /// - A completed activity cannot be cancelled.
  /// - Returns a new immutable instance with the
  ///   [ActivityStatus.cancelled] status.
  ///
  /// Throws:
  /// - [StateError] if the activity has already been completed.
  Activity cancel() {
    if (status == ActivityStatus.completed) {
      throw StateError('No se puede cancelar una actividad que ya ha sido completada.');
    }
    return Activity(
      id: id,
      name: name,
      description: description,
      schedule: schedule,
      status: ActivityStatus.cancelled,
    );
  }
}
