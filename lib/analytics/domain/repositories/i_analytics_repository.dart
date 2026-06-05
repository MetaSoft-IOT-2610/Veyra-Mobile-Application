import '../../../shared/core/failures/failures.dart';
import '../../../shared/core/result/result.dart';
import '../entities/operational_metrics.dart';

abstract class IAnalyticsRepository {
  /// Devuelve métricas operativas o un Failure estandarizado.
  Future<Result<Failure, OperationalMetrics>> getOperationalMetrics(int nursingHomeId);
}