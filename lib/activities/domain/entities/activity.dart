import '../../../shared/domain/entities/entity.dart';
import '../value_objects/activity_schedule.dart';

/// Represents a scheduled activity within a nursing home.
///
/// This domain entity encapsulates all business information
/// related to an activity, including its title, description,
/// schedule, and current lifecycle status.
///
/// The entity is immutable. Any state transition results
/// in the creation of a new instance rather than modifying
/// the existing one.
///
/// Ubiquitous Language:
/// - The term **title** is used instead of **name** to maintain
///   consistency with the backend domain model and API contracts.
class Activity extends Entity<int> {
  /// Human-readable title of the activity.
  ///
  /// Examples:
  /// - Morning Exercise Session
  /// - Music Therapy Workshop
  /// - Weekly Medical Checkup
  final String title;

  /// Detailed description of the activity.
  ///
  /// This field may contain objectives, instructions,
  /// or additional context for participants.
  final String description;

  /// Scheduled time range during which the activity
  /// takes place.
  final ActivitySchedule schedule;

  /// Current lifecycle status of the activity.
  final ActivityStatus status;

  /// Creates a new immutable [Activity] instance.
  const Activity({
    required super.id,
    required this.title,
    required this.description,
    required this.schedule,
    required this.status,
  });

  /// Cancels the activity.
  ///
  /// Business Rules:
  /// - A completed activity cannot be cancelled.
  /// - Cancellation creates a new immutable instance.
  ///
  /// Returns:
  /// - A new [Activity] with status set to
  ///   [ActivityStatus.cancelled].
  ///
  /// Throws:
  /// - [StateError] if the activity has already been completed.
  Activity cancel() {
    if (status == ActivityStatus.completed) {
      throw StateError(
        'Cannot cancel an activity that has already been completed.',
      );
    }

    return Activity(
      id: id,
      title: title,
      description: description,
      schedule: schedule,
      status: ActivityStatus.cancelled,
    );
  }
}

/// Represents the lifecycle states of an activity.
///
/// Activities transition through these states
/// during their execution lifecycle.
enum ActivityStatus {
  /// Activity has been scheduled but has not started yet.
  scheduled,

  /// Activity is currently in progress.
  inProgress,

  /// Activity has been successfully completed.
  completed,

  /// Activity has been cancelled before completion.
  cancelled,
}
