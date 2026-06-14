import '../../domain/entities/activity.dart';
import '../../domain/value_objects/activity_schedule.dart';

/// Infrastructure Data Transfer Object (DTO) representing
/// an activity received from an external data source.
///
/// Responsibilities:
/// - Deserialize raw JSON responses.
/// - Provide safe default values when fields are missing.
/// - Convert infrastructure data into pure domain entities.
/// - Map external status values into domain-specific enums.
///
/// This model belongs exclusively to the Infrastructure layer
/// and should never be exposed directly to the Presentation layer.
class ActivityModel {
  /// Unique identifier of the activity.
  final int id;

  /// Human-readable activity title.
  ///
  /// The backend primarily exposes this field as `title`.
  /// For backward compatibility, `name` is also supported.
  final String title;

  /// Detailed description of the activity.
  final String description;

  /// Activity start date and time represented as
  /// an ISO-8601 string.
  final String startTime;

  /// Activity end date and time represented as
  /// an ISO-8601 string.
  final String endTime;

  /// Raw status value received from the backend.
  final String status;

  /// Creates a new [ActivityModel].
  const ActivityModel({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.status,
  });

  /// Creates an [ActivityModel] from a JSON payload.
  ///
  /// Defensive Parsing:
  /// - Provides default values when optional fields
  ///   are not present.
  /// - Supports both `title` and legacy `name` fields.
  /// - Generates temporary schedule values when the
  ///   backend does not yet provide date information.
  ///
  /// Defaults:
  /// - `id` → 0
  /// - `title` → "Untitled Activity"
  /// - `description` → Empty string
  /// - `status` → "SCHEDULED"
  factory ActivityModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return ActivityModel(
      id: json['id'] as int? ?? 0,

      /// Backend-aligned field name.
      ///
      /// Falls back to the legacy `name` property
      /// when necessary.
      title: json['title'] as String? ??
          json['name'] as String? ??
          'Untitled Activity',

      description: json['description'] as String? ?? '',

      /// Temporary fallback values prevent
      /// ActivitySchedule validation failures
      /// when the backend does not yet provide
      /// scheduling information.
      startTime: json['startTime'] as String? ??
          DateTime.now().toIso8601String(),

      endTime: json['endTime'] as String? ??
          DateTime.now()
              .add(const Duration(hours: 1))
              .toIso8601String(),

      status: json['status'] as String? ??
          'SCHEDULED',
    );
  }

  /// Converts this DTO into a pure domain [Activity].
  ///
  /// During conversion:
  /// - ISO date strings are transformed into [DateTime].
  /// - Schedule information becomes an [ActivitySchedule].
  /// - Backend status values are mapped into
  ///   [ActivityStatus] enum values.
  ///
  /// Returns:
  /// - A fully initialized domain entity.
  Activity toEntity() {
    return Activity(
      id: id,
      title: title,
      description: description,

      schedule: ActivitySchedule(
        startTime: DateTime.parse(startTime),
        endTime: DateTime.parse(endTime),
      ),

      status: _mapStatus(status),
    );
  }

  /// Maps backend status values into domain-specific
  /// [ActivityStatus] enum values.
  ///
  /// Supported Values:
  /// - IN_PROGRESS → [ActivityStatus.inProgress]
  /// - COMPLETED → [ActivityStatus.completed]
  /// - CANCELLED → [ActivityStatus.cancelled]
  /// - SCHEDULED → [ActivityStatus.scheduled]
  ///
  /// Any unknown value defaults to
  /// [ActivityStatus.scheduled].
  ActivityStatus _mapStatus(String rawStatus) {
    switch (rawStatus.toUpperCase()) {
      case 'IN_PROGRESS':
        return ActivityStatus.inProgress;

      case 'COMPLETED':
        return ActivityStatus.completed;

      case 'CANCELLED':
        return ActivityStatus.cancelled;

      case 'SCHEDULED':
      default:
        return ActivityStatus.scheduled;
    }
  }
}
