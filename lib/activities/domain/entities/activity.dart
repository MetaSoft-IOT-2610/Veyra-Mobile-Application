import '../../../shared/domain/entities/entity.dart';
import '../value_objects/activity_schedule.dart';

enum ActivityStatus { scheduled, inProgress, completed, cancelled }

class Activity extends Entity<int> {
  final String name;
  final String description;
  final ActivitySchedule schedule;
  final ActivityStatus status;

  const Activity({
    required super.id,
    required this.name,
    required this.description,
    required this.schedule,
    required this.status,
  });

  /// Ejemplo de comportamiento de dominio: Cancelar la actividad.
  /// Retorna una copia de la entidad con el nuevo estado (Inmutabilidad).
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