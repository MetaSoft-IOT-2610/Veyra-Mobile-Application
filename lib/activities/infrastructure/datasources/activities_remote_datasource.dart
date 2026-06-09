import '../../../shared/application/contracts/i_http_client.dart';
import '../../../shared/core/exceptions/exceptions.dart';
import '../models/activity_model.dart';

/// Remote data source responsible for retrieving activity data
/// from external services.
abstract class ActivitiesRemoteDataSource {
  /// Retrieves activities associated with a nursing home.
  ///
  /// Parameters:
  /// - [nursingHomeId]: Nursing home identifier.
  ///
  /// Returns a list of [ActivityModel] instances.
  Future<List<ActivityModel>> getActivities(int nursingHomeId);
}

/// HTTP implementation of [ActivitiesRemoteDataSource].
///
/// Uses the application's standardized [IHttpClient]
/// to communicate with remote APIs.
class ActivitiesRemoteDataSourceImpl implements ActivitiesRemoteDataSource {
  /// HTTP client used to perform network requests.
  final IHttpClient client;

  /// Creates a new remote data source instance.
  ActivitiesRemoteDataSourceImpl({required this.client});


  /// Retrieves activities from the backend service.
  ///
  /// Supports multiple response formats:
  /// - Direct JSON arrays.
  /// - Wrapped responses using `content`.
  /// - Wrapped responses using `data`.
  ///
  /// Throws:
  /// - [ParsingException] when the response format is invalid.
  /// - [ServerException] when a communication error occurs.
  @override
  Future<List<ActivityModel>> getActivities(int nursingHomeId) async {
    try {
      // FIX: Pure relative path (without /api/v1/) to prevent URL duplication
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
