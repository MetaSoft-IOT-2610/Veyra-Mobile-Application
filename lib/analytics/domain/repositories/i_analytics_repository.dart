import '../../../shared/core/failures/failures.dart';
import '../../../shared/core/result/result.dart';
import '../entities/operational_metrics.dart';

/// Repository contract for accessing analytics and operational metrics data.
///
/// This abstraction defines the operations required to retrieve analytics
/// information from a data source, regardless of whether the implementation
/// uses a remote API, local database, or another provider.
///
/// Implementations are responsible for handling data retrieval and mapping
/// infrastructure errors into standardized [Failure] objects.
abstract class IAnalyticsRepository {
  /// Retrieves operational metrics for a specific nursing home.
  ///
  /// Returns a [Result] containing:
  /// - A [Failure] if the operation fails.
  /// - An [OperationalMetrics] instance if the operation succeeds.
  ///
  /// Parameters:
  /// - [nursingHomeId]: Unique identifier of the nursing home whose
  ///   operational metrics are being requested.
  ///
  /// Example:
  /// ```dart
  /// final result =
  ///     await repository.getOperationalMetrics(1);
  /// ```
  Future<Result<Failure, OperationalMetrics>> getOperationalMetrics(
    int nursingHomeId,
  );
}
