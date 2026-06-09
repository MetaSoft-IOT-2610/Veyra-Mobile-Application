import '../../../shared/domain/entities/entity.dart';

/// Domain entity that represents operational metrics related to workforce
/// management within an organization.
///
/// This entity encapsulates key human resources indicators such as:
/// - Total admissions.
/// - Total employee terminations.
/// - Total hires.
///
/// It also contains business rules that help evaluate workforce growth
/// and identify potential staff turnover issues.
class OperationalMetrics extends Entity<int> {
  /// Total number of admissions recorded.
  final int admissionsCount;

  /// Total number of employee terminations recorded.
  final int terminationsCount;

  /// Total number of hires recorded.
  final int hiresCount;

  /// Creates an instance of [OperationalMetrics].
  ///
  /// The [id] parameter is optional and defaults to `0`.
  ///
  /// All other parameters are required.
  const OperationalMetrics({
    int id = 0,
    required this.admissionsCount,
    required this.terminationsCount,
    required this.hiresCount,
  }) : super(id: id);

  /// Business Rule #1: Determines whether the organization is growing
  /// its workforce.
  ///
  /// Returns `true` when the number of hires exceeds the number of
  /// employee terminations.
  ///
  /// Example:
  /// ```dart
  /// final metrics = OperationalMetrics(
  ///   admissionsCount: 10,
  ///   terminationsCount: 2,
  ///   hiresCount: 5,
  /// );
  ///
  /// print(metrics.isGrowingStaff); // true
  /// ```
  bool get isGrowingStaff => hiresCount > terminationsCount;

  /// Business Rule #2: Calculates a simplified staff turnover ratio.
  ///
  /// The formula used is:
  /// ```text
  /// terminationsCount / hiresCount
  /// ```
  ///
  /// Special cases:
  /// - Returns `0.0` when there are no hires and no terminations.
  /// - Returns `1.0` when there are terminations but no hires,
  ///   preventing division by zero.
  ///
  /// Interpretation:
  /// - Less than `1.0`: workforce growth or stable retention.
  /// - Equal to `1.0`: hires and terminations are balanced.
  /// - Greater than `1.0`: more employees are leaving than being hired.
  double get staffTurnoverRatio {
    if (hiresCount == 0 && terminationsCount == 0) return 0.0;
    if (hiresCount == 0) return 1.0;
    return terminationsCount / hiresCount;
  }

  /// Business Rule #3: Indicates whether staff turnover has reached
  /// a critical level.
  ///
  /// Returns `true` when the turnover ratio exceeds the threshold of `1.5`,
  /// which may indicate significant employee retention problems.
  ///
  /// This property can be used directly by the presentation layer to
  /// display alerts, warnings, or visual indicators.
  ///
  /// Example:
  /// ```dart
  /// if (metrics.hasCriticalStaffTurnover) {
  ///   // Display critical turnover alert
  /// }
  /// ```
  bool get hasCriticalStaffTurnover => staffTurnoverRatio > 1.5;
}
