import '../../domain/entities/operational_metrics.dart';

/// Application DTO responsible for transforming domain entities
/// into presentation-friendly data structures.
///
/// This DTO prevents the Presentation layer from performing
/// formatting operations or UI-specific calculations.
///
/// Typical transformations include:
/// - Number-to-string conversion.
/// - Percentage formatting.
/// - UI state preparation.
class AnalyticsSummaryDto {
  /// Formatted admissions count.
  final String admissions;

  /// Formatted terminations count.
  final String terminations;

  /// Formatted hires count.
  final String hires;

  /// Formatted turnover percentage.
  final String turnoverPercentage;

  /// Indicates whether the turnover ratio should be displayed
  /// as a critical warning in the UI.
  final bool isCritical;

  AnalyticsSummaryDto._({
    required this.admissions,
    required this.terminations,
    required this.hires,
    required this.turnoverPercentage,
    required this.isCritical,
  });

  /// Creates a presentation DTO from a domain entity.
  ///
  /// Business calculations remain inside the Domain layer,
  /// while this method only formats values for display.
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
