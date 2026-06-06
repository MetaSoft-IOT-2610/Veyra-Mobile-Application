import '../../../shared/application/contracts/i_http_client.dart';
import '../../../shared/core/exceptions/exceptions.dart';
import '../models/staff_model.dart';

abstract class StaffRemoteDataSource {
  Future<List<StaffModel>> getStaff(int nursingHomeId);
}

class StaffRemoteDataSourceImpl implements StaffRemoteDataSource {
  final IHttpClient client;

  StaffRemoteDataSourceImpl({required this.client});

  @override
  Future<List<StaffModel>> getStaff(int nursingHomeId) async {
    try {
      final response = await client.get('/api/v1/nursing-homes/$nursingHomeId/staff');

      List<dynamic> data;

      if (response is List) {
        data = response;
      } else if (response is Map) {
        if (response.containsKey('content')) {
          data = response['content'] as List<dynamic>;
        } else if (response.containsKey('data')) {
          data = response['data'] as List<dynamic>;
        } else {
          // Imprimimos en consola para ver la estructura real si no es 'content' ni 'data'
          print('DEBUG JSON HCM: $response');
          throw ParsingException(message: 'No se encontró la lista en el JSON del servidor.');
        }
      } else {
        throw ParsingException(message: 'Formato de respuesta HTTP desconocido.');
      }

      return data.map((json) => StaffModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ServerException(message: 'Error fetching staff: $e');
    }
  }
}
