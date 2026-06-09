import '../../domain/entities/operational_metrics.dart';

/// Infrastructure Data Transfer Object (DTO) responsible for
/// serializing and deserializing operational metrics received
/// from external data sources.
///
/// This model belongs to the Infrastructure layer and should
/// never contain business rules or domain logic.
///
/// Its primary responsibility is to transform raw JSON data
/// into strongly typed objects and map them into domain entities.
class OperationalMetricsModel {
  /// Total number of admissions.
  final int admissionsCount;

  /// Total number of employee terminations.
  final int terminationsCount;

  /// Total number of hires.
  final int hiresCount;

  /// Creates a new [OperationalMetricsModel].
  OperationalMetricsModel({
    required this.admissionsCount,
    required this.terminationsCount,
    required this.hiresCount,
  });

  /// Creates an instance from a JSON object.
  ///
  /// Missing fields are automatically assigned a default value
  /// of `0` to improve resilience against incomplete API responses.
  factory OperationalMetricsModel.fromJson(Map<String, dynamic> json) {
    return OperationalMetricsModel(
      admissionsCount: json['admissionsCount'] as int? ?? 0,
      terminationsCount: json['terminationsCount'] as int? ?? 0,
      hiresCount: json['hiresCount'] as int? ?? 0,
    );
  }

  /// Converts this infrastructure model into a pure
  /// domain [OperationalMetrics] entity.
  ///
  /// This transformation prevents infrastructure concerns
  /// from leaking into the Domain layer.
  OperationalMetrics toEntity() {
    return OperationalMetrics(
      admissionsCount: admissionsCount,
      terminationsCount: terminationsCount,
      hiresCount: hiresCount,
    );
  }
}
