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
        admissionsCount: _extractCount(admissionsResponse),
        terminationsCount: _extractCount(terminationsResponse),
        hiresCount: _extractCount(hiresResponse),
      );
    } catch (e) {
      throw ServerException(message: 'Error al obtener métricas del servidor: $e');
    }
  }

  int _extractCount(dynamic response) {
    if (response is int) return response;
    if (response is Map) {
      if (response.containsKey('count')) return (response['count'] as num).toInt();
      if (response.containsKey('value')) return (response['value'] as num).toInt();
    }
    return 0;
  }
}
