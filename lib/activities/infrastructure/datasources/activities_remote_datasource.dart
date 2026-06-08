import '../../../shared/application/contracts/i_http_client.dart';
import '../../../shared/core/exceptions/exceptions.dart';
import '../models/activity_model.dart';

/// Remote data source interface responsible for fetching nursing home activities.
abstract class ActivitiesRemoteDataSource {
  /// Retrieves a list of activities scheduled for a specific nursing home.
  ///
  /// Requires the [nursingHomeId] to fetch the relevant data.
  Future<List<ActivityModel>> getActivities(int nursingHomeId);
}

/// Concrete implementation of [ActivitiesRemoteDataSource] using the corporate [IHttpClient].
class ActivitiesRemoteDataSourceImpl implements ActivitiesRemoteDataSource {
  /// The HTTP client used to execute network requests.
  final IHttpClient client;

  /// Creates a new instance of [ActivitiesRemoteDataSourceImpl] requiring an [IHttpClient].
  ActivitiesRemoteDataSourceImpl({required this.client});

  @override
  Future<List<ActivityModel>> getActivities(int nursingHomeId) async {
    try {
      // ✅ FIX: Pure relative path (without /api/v1/) to prevent URL duplication
      final response = await client.get('nursing-homes/$nursingHomeId/activities');

      List<dynamic> data;

      // Defensive parsing to handle both direct arrays and paginated/wrapped responses
      if (response is List) {
        data = response;
      } else if (response is Map) {
        if (response.containsKey('content')) {
          data = response['content'] as List<dynamic>;
        } else if (response.containsKey('data')) {
          data = response['data'] as List<dynamic>;
        } else {
          print('🚨 [Activities] DEBUG JSON: $response');
          throw ParsingException(message: 'Could not find the activities list in the server JSON response.');
        }
      } else {
        throw ParsingException(message: 'Unknown HTTP response format.');
      }

      return data.map((json) => ActivityModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ServerException(message: 'Error fetching activities: $e');
    }
  }
}
