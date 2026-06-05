import 'package:veyra_mobile_app/analytics/infrastructure/models/operational_metrics.dart';

import '../../../shared/application/contracts/i_http_client.dart';
import '../../../shared/core/exceptions/exceptions.dart';

abstract class AnalyticsRemoteDataSource {
  Future<OperationalMetricsModel> getOperationalMetrics(int nursingHomeId);
}

class AnalyticsRemoteDataSourceImpl implements AnalyticsRemoteDataSource {
  final IHttpClient client;

  AnalyticsRemoteDataSourceImpl({required this.client});

  @override
  Future<OperationalMetricsModel> getOperationalMetrics(int nursingHomeId) async {
    try {
      final admissionsResponse = await client.get('/api/v1/nursing-homes/$nursingHomeId/analytics/residents-admissions');
      final terminationsResponse = await client.get('/api/v1/nursing-homes/$nursingHomeId/analytics/staff-terminations');
      final hiresResponse = await client.get('/api/v1/nursing-homes/$nursingHomeId/analytics/staff-hires');

      return OperationalMetricsModel(
        admissionsCount: admissionsResponse['count'] ?? 0,
        terminationsCount: terminationsResponse['count'] ?? 0,
        hiresCount: hiresResponse['count'] ?? 0,
      );
    } catch (e) {
      throw ServerException(message: 'Error al obtener métricas del servidor: $e');
    }
  }
}