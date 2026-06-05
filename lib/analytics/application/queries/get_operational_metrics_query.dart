import '../../../shared/core/failures/failures.dart';
import '../../../shared/core/result/result.dart';
import '../../domain/entities/operational_metrics.dart';
import '../../domain/repositories/i_analytics_repository.dart';

class GetOperationalMetricsQuery {
  final IAnalyticsRepository _repository;

  GetOperationalMetricsQuery(this._repository);

  Future<Result<Failure, OperationalMetrics>> execute(int nursingHomeId) async {
    if (nursingHomeId <= 0) {
      return Result.failure(ValidationFailure('ID de residencia inválido.'));
    }

    // Aquí podríamos agregar lógica adicional, como guardar logs analíticos
    return await _repository.getOperationalMetrics(nursingHomeId);
  }
}