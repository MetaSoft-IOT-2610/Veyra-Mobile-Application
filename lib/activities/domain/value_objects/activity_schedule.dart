import '../../../shared/domain/value_objects/value_object.dart';

class ActivitySchedule extends ValueObject {
  final DateTime startTime;
  final DateTime endTime;

  const ActivitySchedule._(this.startTime, this.endTime);

  /// Factory que valida la regla de negocio antes de instanciar.
  /// Lanza un error de dominio si la validación falla.
  factory ActivitySchedule({
    required DateTime startTime,
    required DateTime endTime,
  }) {
    if (endTime.isBefore(startTime)) {
      throw ArgumentError('La fecha de fin no puede ser anterior a la fecha de inicio.');
    }
    return ActivitySchedule._(startTime, endTime);
  }

  /// Regla de negocio pura: ¿Está ocurriendo en este preciso instante?
  bool get isOngoing {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime);
  }

  @override
  List<Object?> get props => [startTime, endTime];
}