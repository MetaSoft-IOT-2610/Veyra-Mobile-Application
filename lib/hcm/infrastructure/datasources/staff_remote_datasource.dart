import '../../../shared/application/contracts/i_http_client.dart';
import '../../../shared/core/exceptions/exceptions.dart';
import '../models/staff_model.dart';

/// Remote data source interface responsible for fetching human capital management (HCM) data.
abstract class StaffRemoteDataSource {
  /// Retrieves a list of staff members assigned to a specific nursing home.
  ///
  /// Requires the [nursingHomeId] to fetch the relevant data.
  Future<List<StaffModel>> getStaff(int nursingHomeId);
}

/// Concrete implementation of [StaffRemoteDataSource] using the corporate [IHttpClient].
class StaffRemoteDataSourceImpl implements StaffRemoteDataSource {
  /// The HTTP client used to execute network requests.
  final IHttpClient client;

  /// Creates a new instance of [StaffRemoteDataSourceImpl] requiring an [IHttpClient].
  StaffRemoteDataSourceImpl({required this.client});

  @override
  Future<List<StaffModel>> getStaff(int nursingHomeId) async {
    try {
      // ✅ FIX: Pure relative path (without /api/v1/) to prevent URL duplication
      final response = await client.get('nursing-homes/$nursingHomeId/staff');

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
          // Print to console to inspect the actual structure if 'content' or 'data' keys are missing
          print('🚨 [HCM] DEBUG JSON: $response');
          throw ParsingException(message: 'Could not find the staff list in the server JSON response.');
        }
      } else {
        throw ParsingException(message: 'Unknown HTTP response format.');
      }

      return data.map((json) => StaffModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ServerException(message: 'Error fetching staff: $e');
    }
  }
}
