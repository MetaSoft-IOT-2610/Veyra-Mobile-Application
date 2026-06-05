import '../../domain/entities/operational_metrics.dart';

/// DTO (Data Transfer Object) de Infraestructura.
/// Se encarga exclusivamente de la serialización/deserialización de datos externos.
class OperationalMetricsModel {
  final int admissionsCount;
  final int terminationsCount;
  final int hiresCount;

  OperationalMetricsModel({
    required this.admissionsCount,
    required this.terminationsCount,
    required this.hiresCount,
  });

  /// Factory para construir el modelo a partir de JSON.
  /// Protegemos la app con valores por defecto (0) si el backend omite un campo.
  factory OperationalMetricsModel.fromJson(Map<String, dynamic> json) {
    return OperationalMetricsModel(
      admissionsCount: json['admissionsCount'] as int? ?? 0,
      terminationsCount: json['terminationsCount'] as int? ?? 0,
      hiresCount: json['hiresCount'] as int? ?? 0,
    );
  }

  /// Método vital: Transforma este DTO técnico en una Entidad pura de negocio.
  OperationalMetrics toEntity() {
    return OperationalMetrics(
      admissionsCount: admissionsCount,
      terminationsCount: terminationsCount,
      hiresCount: hiresCount,
    );
  }
}