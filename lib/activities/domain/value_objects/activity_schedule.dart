import '../../../shared/domain/value_objects/value_object.dart';

/// Value Object representing the scheduled time range of an activity.
///
/// This object guarantees temporal consistency by enforcing
/// business validation rules during construction.
class ActivitySchedule extends ValueObject {
  /// Activity start date and time.
  final DateTime startTime;

  /// Activity end date and time.
  final DateTime endTime;

  const ActivitySchedule._(this.startTime, this.endTime);

  /// Creates a valid activity schedule.
  ///
  /// Validation Rules:
  /// - The end time cannot be earlier than the start time.
  ///
  /// Throws:
  /// - [ArgumentError] when the schedule is invalid.
  factory ActivitySchedule({
    required DateTime startTime,
    required DateTime endTime,
  }) {
    if (endTime.isBefore(startTime)) {
      throw ArgumentError(
        'La fecha de fin no puede ser anterior a la fecha de inicio.',
      );
    }
    return ActivitySchedule._(startTime, endTime);
  }

  /// Indicates whether the activity is currently taking place.
  ///
  /// Returns `true` when the current time falls between
  /// [startTime] and [endTime].
  bool get isOngoing {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime);
  }

  @override
  List<Object?> get props => [startTime, endTime];
}
