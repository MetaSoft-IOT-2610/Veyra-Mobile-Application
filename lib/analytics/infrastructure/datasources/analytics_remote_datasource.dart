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
  Future<OperationalMetricsModel> getOperationalMetrics(
    int nursingHomeId,
  ) async {
    final year = DateTime.now().year;

    final admissions = await _fetchMetricTotal(
      nursingHomeId: nursingHomeId,
      metricPath: 'residents-admissions',
      year: year,
    );
    final terminations = await _fetchMetricTotal(
      nursingHomeId: nursingHomeId,
      metricPath: 'staff-terminations',
      year: year,
    );
    final hires = await _fetchMetricTotal(
      nursingHomeId: nursingHomeId,
      metricPath: 'staff-hires',
      year: year,
    );

    return OperationalMetricsModel(
      admissionsCount: admissions,
      terminationsCount: terminations,
      hiresCount: hires,
    );
  }

  Future<int> _fetchMetricTotal({
    required int nursingHomeId,
    required String metricPath,
    required int year,
  }) async {
    try {
      final response = await client.get(
        'nursing-homes/$nursingHomeId/$metricPath',
        queryParameters: {'year': year},
      );
      return _extractTotal(response);
    } on ServerException catch (e) {
      if (e.statusCode == 404) {
        return _fetchAnalyticsMetricTotal(
          nursingHomeId: nursingHomeId,
          metricPath: metricPath,
          year: year,
        );
      }
      if (e.statusCode == 400 && year != 2025) {
        return _fetchMetricTotal(
          nursingHomeId: nursingHomeId,
          metricPath: metricPath,
          year: 2025,
        );
      }
      return 0;
    } catch (_) {
      return 0;
    }
  }

  Future<int> _fetchAnalyticsMetricTotal({
    required int nursingHomeId,
    required String metricPath,
    required int year,
  }) async {
    try {
      final response = await client.get(
        'nursing-homes/$nursingHomeId/analytics/$metricPath',
        queryParameters: {'year': year},
      );
      return _extractTotal(response);
    } on ServerException catch (e) {
      if (e.statusCode == 400 && year != 2025) {
        return _fetchAnalyticsMetricTotal(
          nursingHomeId: nursingHomeId,
          metricPath: metricPath,
          year: 2025,
        );
      }
      return 0;
    } catch (_) {
      return 0;
    }
  }

  int _extractTotal(dynamic response) {
    if (response is Map) {
      final total = response['total'];
      if (total is num) return total.toInt();

      final values = response['values'];
      if (values is List) {
        return values.whereType<num>().fold<int>(
          0,
          (previous, value) => previous + value.toInt(),
        );
      }
    }
    return 0;
  }
}
