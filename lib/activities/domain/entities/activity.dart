import '../../../shared/domain/entities/entity.dart';
import '../value_objects/activity_schedule.dart';

class Activity extends Entity<int> {
  final int nursingHomeId;
  final int residentId;
  final int healthcareStaffId;
  final String type;
  final String title;
  final String description;
  final ActivitySchedule schedule;
  final ActivityStatus status;
  final bool isRecurring;
  final List<String> recurringDays;

  const Activity({
    required super.id,
    this.nursingHomeId = 0,
    required this.residentId,
    required this.healthcareStaffId,
    required this.type,
    required this.title,
    this.description = '',
    required this.schedule,
    required this.status,
    this.isRecurring = false,
    this.recurringDays = const [],
  });

  Activity copyWith({
    int? id,
    int? nursingHomeId,
    int? residentId,
    int? healthcareStaffId,
    String? type,
    String? title,
    String? description,
    ActivitySchedule? schedule,
    ActivityStatus? status,
    bool? isRecurring,
    List<String>? recurringDays,
  }) {
    return Activity(
      id: id ?? this.id,
      nursingHomeId: nursingHomeId ?? this.nursingHomeId,
      residentId: residentId ?? this.residentId,
      healthcareStaffId: healthcareStaffId ?? this.healthcareStaffId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      schedule: schedule ?? this.schedule,
      status: status ?? this.status,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringDays: recurringDays ?? this.recurringDays,
    );
  }
}

enum ActivityStatus { pending, inProgress, completed, cancelled }
