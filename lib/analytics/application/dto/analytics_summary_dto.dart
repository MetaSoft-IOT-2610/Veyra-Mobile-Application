import '../../domain/entities/operational_metrics.dart';

/// DTO de Aplicación: Formatea los datos de la Entidad para que la 
/// capa de Presentación (BLoC) no tenga que hacer cálculos de UI (ej. formatear %).
class AnalyticsSummaryDto {
  final String admissions;
  final String terminations;
  final String hires;
  final String turnoverPercentage;
  final bool isCritical;

  AnalyticsSummaryDto._({
    required this.admissions,
    required this.terminations,
    required this.hires,
    required this.turnoverPercentage,
    required this.isCritical,
  });

  /// Crea el DTO a partir de la Entidad del Dominio.
  factory AnalyticsSummaryDto.fromEntity(OperationalMetrics entity) {
    final percentage = (entity.staffTurnoverRatio * 100).toStringAsFixed(1);
    
    return AnalyticsSummaryDto._(
      admissions: entity.admissionsCount.toString(),
      terminations: entity.terminationsCount.toString(),
      hires: entity.hiresCount.toString(),
      turnoverPercentage: '$percentage%',
      isCritical: entity.hasCriticalStaffTurnover,
    );
  }
}