import '../../../shared/core/failures/failures.dart';
import '../../../shared/core/result/result.dart';
import '../../../shared/core/exceptions/exceptions.dart';
import '../../domain/entities/operational_metrics.dart';
import '../../domain/repositories/i_analytics_repository.dart';
import '../datasources/analytics_remote_datasource.dart';

class AnalyticsRepositoryImpl implements IAnalyticsRepository {
  final AnalyticsRemoteDataSource remoteDataSource;

  AnalyticsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<Failure, OperationalMetrics>> getOperationalMetrics(int nursingHomeId) async {
    try {
      final metricsModel = await remoteDataSource.getOperationalMetrics(nursingHomeId);

      return Result.success(metricsModel.toEntity());

    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message, code: e.statusCode?.toString()));
    } catch (e) {
      return Result.failure(ServerFailure('Error inesperado procesando métricas: $e'));
    }
  }
}
