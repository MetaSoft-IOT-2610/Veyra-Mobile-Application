import 'package:veyra_mobile_app/analytics/infrastructure/models/operational_metrics.dart';

import '../../../shared/application/contracts/i_http_client.dart';
import '../../../shared/core/exceptions/exceptions.dart';

/// Remote data source interface responsible for fetching analytics and operational metrics.
abstract class AnalyticsRemoteDataSource {
  /// Retrieves the operational metrics for a specific nursing home.
  ///
  /// Requires the [nursingHomeId] to fetch data such as resident admissions,
  /// staff terminations, and staff hires.
  Future<OperationalMetricsModel> getOperationalMetrics(int nursingHomeId);
}

/// Concrete implementation of [AnalyticsRemoteDataSource] using the corporate [IHttpClient].
class AnalyticsRemoteDataSourceImpl implements AnalyticsRemoteDataSource {
  /// The HTTP client used to execute network requests.
  final IHttpClient client;

  /// Creates a new instance of [AnalyticsRemoteDataSourceImpl] requiring an [IHttpClient].
  AnalyticsRemoteDataSourceImpl({required this.client});

  @override
  Future<OperationalMetricsModel> getOperationalMetrics(int nursingHomeId) async {
    try {
      // ✅ FIX: Pure relative paths (without /api/v1/) to prevent URL duplication
      final admissionsResponse = await client.get('nursing-homes/$nursingHomeId/analytics/residents-admissions');
      final terminationsResponse = await client.get('nursing-homes/$nursingHomeId/analytics/staff-terminations');
      final hiresResponse = await client.get('nursing-homes/$nursingHomeId/analytics/staff-hires');

      return OperationalMetricsModel(
        admissionsCount: _extractCount(admissionsResponse),
        terminationsCount: _extractCount(terminationsResponse),
        hiresCount: _extractCount(hiresResponse),
      );
    } catch (e) {
      throw ServerException(message: 'Error fetching operational metrics from server: $e');
    }
  }

  /// Helper method to safely extract integer counts from dynamic JSON responses.
  ///
  /// Checks if the response is directly an [int], or if it is a [Map] containing
  /// keys like 'count' or 'value'. Defaults to 0 if parsing fails or data is missing.
  int _extractCount(dynamic response) {
    if (response is int) return response;
    if (response is Map) {
      if (response.containsKey('count')) return (response['count'] as num).toInt();
      if (response.containsKey('value')) return (response['value'] as num).toInt();
    }
    return 0; // Default fallback
  }
}
