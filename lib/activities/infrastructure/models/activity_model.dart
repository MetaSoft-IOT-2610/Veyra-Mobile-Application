import '../../domain/entities/activity.dart';
import '../../domain/value_objects/activity_schedule.dart';

class ActivityModel {
  final int id;
  final String name;
  final String description;
  final String startTime;
  final String endTime;
  final String status;

  ActivityModel({
    required this.id,
    required this.name,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.status,
  });

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

  /// Transforma el DTO de infraestructura a una Entidad pura de Dominio.
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