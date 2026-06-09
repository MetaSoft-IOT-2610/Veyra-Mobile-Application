import '../../domain/entities/activity.dart';
import '../../domain/value_objects/activity_schedule.dart';

/// Infrastructure Data Transfer Object (DTO)
/// representing an activity received from the backend.
///
/// This model is responsible for JSON serialization,
/// deserialization, and conversion into domain entities.
class ActivityModel {
  /// Unique activity identifier.
  final int id;

  /// Activity title.
  final String name;

  /// Activity description.
  final String description;

  /// Activity start date and time in ISO format.
  final String startTime;

  /// Activity end date and time in ISO format.
  final String endTime;

  /// Raw status value received from the API.
  final String status;

  /// Creates a new activity model.
  ActivityModel({
    required this.id,
    required this.name,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.status,
  });

  /// Creates an instance from a JSON object.
  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      status: json['status'] as String,
    );
  }

  /// Converts this DTO into a pure domain [Activity].
  ///
  /// During conversion:
  /// - Dates are transformed into [DateTime].
  /// - The schedule becomes an [ActivitySchedule].
  /// - Raw status values are mapped to [ActivityStatus].
  Activity toEntity() {
    return Activity(
      id: id,
      name: name,
      description: description,
      // Instanciamos el Value Object (validará la lógica de fechas automáticamente)
      schedule: ActivitySchedule(
        startTime: DateTime.parse(startTime),
        endTime: DateTime.parse(endTime),
      ),
      status: _mapStatus(status),
    );
  }

  /// Maps backend status strings into domain enum values.
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
