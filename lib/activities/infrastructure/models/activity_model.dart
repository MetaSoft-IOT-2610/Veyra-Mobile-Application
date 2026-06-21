import '../../domain/entities/activity.dart';
import '../../domain/value_objects/activity_schedule.dart';

class ActivityModel {
  final int id;
  final int nursingHomeId;
  final int residentId;
  final int healthcareStaffId;
  final String type;
  final String title;
  final String status;
  final bool isRecurring;
  final List<String> recurringDays;

  const ActivityModel({
    required this.id,
    required this.nursingHomeId,
    required this.residentId,
    required this.healthcareStaffId,
    required this.type,
    required this.title,
    required this.status,
    required this.isRecurring,
    required this.recurringDays,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: _asInt(json['id']),
      nursingHomeId: _asInt(json['nursingHomeId']),
      residentId: _asInt(json['residentId']),
      healthcareStaffId: _asInt(json['healthcareStaffId']),
      type: (json['type'] as String?) ?? 'RECREATIONAL',
      title:
          (json['title'] as String?) ??
          (json['name'] as String?) ??
          'Untitled activity',
      status: (json['status'] as String?) ?? 'PENDING',
      isRecurring: (json['isRecurring'] as bool?) ?? false,
      recurringDays:
          (json['recurringDays'] as List?)?.whereType<String>().toList() ??
          const [],
    );
  }

  Activity toEntity() {
    final now = DateTime.now();

    return Activity(
      id: id,
      nursingHomeId: nursingHomeId,
      residentId: residentId,
      healthcareStaffId: healthcareStaffId,
      type: type,
      title: title,
      schedule: ActivitySchedule(
        startTime: now,
        endTime: now.add(const Duration(hours: 1)),
      ),
      status: _mapStatus(status),
      isRecurring: isRecurring,
      recurringDays: recurringDays,
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  ActivityStatus _mapStatus(String rawStatus) {
    switch (rawStatus.toUpperCase()) {
      case 'IN_PROGRESS':
        return ActivityStatus.inProgress;
      case 'COMPLETED':
        return ActivityStatus.completed;
      case 'CANCELLED':
        return ActivityStatus.cancelled;
      case 'PENDING':
      case 'SCHEDULED':
      default:
        return ActivityStatus.pending;
    }
  }
}
