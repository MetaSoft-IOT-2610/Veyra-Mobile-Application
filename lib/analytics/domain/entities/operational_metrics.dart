import '../../../shared/domain/entities/entity.dart';

class OperationalMetrics extends Entity<int> {
  final int admissionsCount;
  final int terminationsCount;
  final int hiresCount;

  const OperationalMetrics({
    int id = 0, 
    required this.admissionsCount,
    required this.terminationsCount,
    required this.hiresCount,
  }) : super(id: id);

  /// Regla de negocio 1: ¿Estamos contratando más de lo que despedimos?
  bool get isGrowingStaff => hiresCount > terminationsCount;

  /// Regla de negocio 2: Tasa de rotación (Turnover Ratio) simplificada.
  /// Retorna un porcentaje del 0.0 al 1.0 (o superior si hay crisis).
  double get staffTurnoverRatio {
    if (hiresCount == 0 && terminationsCount == 0) return 0.0;
    if (hiresCount == 0) return 1.0; // Evitar división por cero
    return terminationsCount / hiresCount;
  }

  /// Regla de negocio 3: Alerta crítica para la UI.
  bool get hasCriticalStaffTurnover => staffTurnoverRatio > 1.5;
}