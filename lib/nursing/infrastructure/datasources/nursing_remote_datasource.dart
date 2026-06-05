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
      final data = response as List<dynamic>;
      return data.map((json) => ResidentModel.fromJson(json)).toList();
    } catch (e) {
      throw ServerException(message: 'Error fetching residents: $e');
    }
  }

  @override
  Future<List<RoomModel>> getRooms(int nursingHomeId) async {
    try {
      final response = await client.get('/api/v1/nursing-homes/$nursingHomeId/rooms');
      final data = response as List<dynamic>;
      return data.map((json) => RoomModel.fromJson(json)).toList();
    } catch (e) {
      throw ServerException(message: 'Error fetching rooms: $e');
    }
  }
}