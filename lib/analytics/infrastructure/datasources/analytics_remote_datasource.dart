import 'dart:math' as math;
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
    // 1. Calculate the current year automatically.
    // Limited to 2025 to prevent backend validation errors (year must be between 1900 and 2025).
    final currentYear = math.min(DateTime.now().year, 2025);
    print('[Analytics] Fetching metrics for year: $currentYear');

    int admissions = 0;
    int terminations = 0;
    int hires = 0;

    // 2. Fetch Admissions (Defensive parsing)
    try {
      final admissionsResponse = await client.get(
        'nursing-homes/$nursingHomeId/analytics/residents-admissions',
        queryParameters: {'year': currentYear},
      );
      admissions = _extractTotal(admissionsResponse);
    } catch (e) {
      print('[Analytics] Warning: Error fetching admissions: $e');
    }

    // 3. Fetch Terminations (Defensive parsing)
    try {
      final terminationsResponse = await client.get(
        'nursing-homes/$nursingHomeId/analytics/staff-terminations',
        queryParameters: {'year': currentYear},
      );
      terminations = _extractTotal(terminationsResponse);
    } catch (e) {
      print('[Analytics] Warning: Error fetching terminations (Probably 404): $e');
    }

    // 4. Fetch Hires (Defensive parsing)
    try {
      final hiresResponse = await client.get(
        'nursing-homes/$nursingHomeId/analytics/staff-hires',
        queryParameters: {'year': currentYear},
      );
      hires = _extractTotal(hiresResponse);
    } catch (e) {
      print('[Analytics] Warning: Error fetching hires: $e');
    }

    // 5. Return the model with the successfully fetched data.
    // If an endpoint fails, its corresponding value safely remains 0.
    return OperationalMetricsModel(
      admissionsCount: admissions,
      terminationsCount: terminations,
      hiresCount: hires,
    );
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
    print('[Analytics] Warning: "total" key not found in response. Falling back to 0.');
    return 0; // Default fallback if the structure is empty or unexpected
  }
}
