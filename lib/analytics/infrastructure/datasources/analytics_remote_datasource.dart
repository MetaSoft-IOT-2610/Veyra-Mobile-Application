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
      // 1. Calculate the current year automatically
      final currentYear = DateTime.now().year;
      print('🚀 [Analytics] Fetching metrics for year: $currentYear');

      // 2. Fetch Admissions (Passing the REQUIRED 'year' query parameter)
      final admissionsResponse = await client.get(
        'nursing-homes/$nursingHomeId/analytics/residents-admissions',
        queryParameters: {'year': currentYear},
      );

      // 3. Fetch Terminations (Assuming it also requires the 'year' parameter)
      final terminationsResponse = await client.get(
        'nursing-homes/$nursingHomeId/analytics/staff-terminations',
        queryParameters: {'year': currentYear},
      );

      // 4. Fetch Hires (Assuming it also requires the 'year' parameter)
      final hiresResponse = await client.get(
        'nursing-homes/$nursingHomeId/analytics/staff-hires',
        queryParameters: {'year': currentYear},
      );

      // 5. Map the results using the correct JSON key ('total') as per Swagger
      return OperationalMetricsModel(
        admissionsCount: _extractTotal(admissionsResponse),
        terminationsCount: _extractTotal(terminationsResponse),
        hiresCount: _extractTotal(hiresResponse),
      );
    } catch (e) {
      throw ServerException(message: 'Error fetching operational metrics from server: $e');
    }
  }

  /// Helper method to safely extract the 'total' value from the backend's Analytics JSON response.
  ///
  /// According to Swagger, the response format is:
  /// { "labels": [...], "values": [...], "metricType": "...", "total": 0 }
  int _extractTotal(dynamic response) {
    if (response is Map) {
      if (response.containsKey('total')) {
        return (response['total'] as num).toInt();
      }
    }
    print('⚠️ [Analytics] Warning: "total" key not found in response. Falling back to 0.');
    return 0; // Default fallback if the structure is empty or unexpected
  }
}
