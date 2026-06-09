import '../../../shared/core/failures/failures.dart';
import '../../../shared/core/result/result.dart';
import '../../domain/entities/operational_metrics.dart';
import '../../domain/repositories/i_analytics_repository.dart';

/// Application Query responsible for retrieving operational metrics.
///
/// This query serves as the entry point for analytics-related
/// read operations and can contain orchestration logic,
/// validations, auditing, or logging concerns.
class GetOperationalMetricsQuery {
  /// Repository used to retrieve analytics data.
  final IAnalyticsRepository _repository;

  /// Creates a new query instance.
  GetOperationalMetricsQuery(this._repository);

  /// Retrieves operational metrics for the specified nursing home.
  ///
  /// Validation Rules:
  /// - The nursing home identifier must be greater than zero.
  ///
  /// Returns:
  /// - [Result.success] with an [OperationalMetrics] entity.
  /// - [Result.failure] with a [ValidationFailure] or another
  ///   domain failure.
  Future<Result<Failure, OperationalMetrics>> execute(int nursingHomeId) async {
    if (nursingHomeId <= 0) {
      return Result.failure(ValidationFailure('ID de residencia inválido.'));
    }

    return await _repository.getOperationalMetrics(nursingHomeId);
  }
}
