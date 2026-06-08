import '../../../shared/application/contracts/i_http_client.dart';
import '../../../shared/core/exceptions/exceptions.dart';
import '../models/resident_model.dart';
import '../models/room_model.dart';

/// Remote data source interface responsible for fetching nursing-related data.
abstract class NursingRemoteDataSource {
  /// Retrieves a list of residents associated with a specific nursing home.
  ///
  /// Requires the [nursingHomeId] to fetch the relevant data.
  Future<List<ResidentModel>> getResidents(int nursingHomeId);

  /// Retrieves a list of rooms available in a specific nursing home.
  ///
  /// Requires the [nursingHomeId] to fetch the relevant data.
  Future<List<RoomModel>> getRooms(int nursingHomeId);
}

/// Concrete implementation of [NursingRemoteDataSource] using the corporate [IHttpClient].
class NursingRemoteDataSourceImpl implements NursingRemoteDataSource {
  /// The HTTP client used to execute network requests.
  final IHttpClient client;

  /// Creates a new instance of [NursingRemoteDataSourceImpl] requiring an [IHttpClient].
  NursingRemoteDataSourceImpl({required this.client});

  @override
  Future<List<ResidentModel>> getResidents(int nursingHomeId) async {
    try {
      // ✅ FIX: Pure relative path (without /api/v1/) to prevent URL duplication
      final response = await client.get('nursing-homes/$nursingHomeId/residents');
      final data = _extractList(response);
      return data.map((json) => ResidentModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ServerException(message: 'Error fetching residents: $e');
    }
  }

  @override
  Future<List<RoomModel>> getRooms(int nursingHomeId) async {
    try {
      // ✅ FIX: Pure relative path (without /api/v1/) to prevent URL duplication
      final response = await client.get('nursing-homes/$nursingHomeId/rooms');
      final data = _extractList(response);
      return data.map((json) => RoomModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ServerException(message: 'Error fetching rooms: $e');
    }
  }

  /// Helper method to safely extract a list from dynamic JSON responses.
  ///
  /// Handles both direct JSON arrays and paginated/wrapped responses containing
  /// a 'content' or 'data' key. Throws a [ParsingException] if the format is invalid.
  List<dynamic> _extractList(dynamic response) {
    if (response is List) {
      return response;
    } else if (response is Map) {
      if (response.containsKey('content')) return response['content'] as List<dynamic>;
      if (response.containsKey('data')) return response['data'] as List<dynamic>;

      print('🚨 [Nursing] DEBUG JSON: $response');
      throw ParsingException(message: 'Could not find the list in the JSON response.');
    }
    throw ParsingException(message: 'Unknown HTTP response format.');
  }
}
