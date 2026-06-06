import '../../../shared/application/contracts/i_http_client.dart';
import '../../../shared/core/exceptions/exceptions.dart';
import '../models/resident_model.dart';
import '../models/room_model.dart';

abstract class NursingRemoteDataSource {
  Future<List<ResidentModel>> getResidents(int nursingHomeId);
  Future<List<RoomModel>> getRooms(int nursingHomeId);
}

class NursingRemoteDataSourceImpl implements NursingRemoteDataSource {
  final IHttpClient client;

  NursingRemoteDataSourceImpl({required this.client});

  @override
  Future<List<ResidentModel>> getResidents(int nursingHomeId) async {
    try {
      final response = await client.get('/api/v1/nursing-homes/$nursingHomeId/residents');
      final data = _extractList(response);
      return data.map((json) => ResidentModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ServerException(message: 'Error fetching residents: $e');
    }
  }

  @override
  Future<List<RoomModel>> getRooms(int nursingHomeId) async {
    try {
      final response = await client.get('/api/v1/nursing-homes/$nursingHomeId/rooms');
      final data = _extractList(response);
      return data.map((json) => RoomModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ServerException(message: 'Error fetching rooms: $e');
    }
  }

  List<dynamic> _extractList(dynamic response) {
    if (response is List) {
      return response;
    } else if (response is Map) {
      if (response.containsKey('content')) return response['content'] as List<dynamic>;
      if (response.containsKey('data')) return response['data'] as List<dynamic>;
      print('DEBUG JSON NURSING: $response');
      throw ParsingException(message: 'No se encontró la lista en el JSON.');
    }
    throw ParsingException(message: 'Formato HTTP desconocido.');
  }
}
