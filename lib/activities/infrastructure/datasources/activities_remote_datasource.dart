import '../../../shared/application/contracts/i_http_client.dart';
import '../../../shared/core/exceptions/exceptions.dart';
import '../models/activity_model.dart';

abstract class ActivitiesRemoteDataSource {
  Future<List<ActivityModel>> getActivities(int nursingHomeId);
}

class ActivitiesRemoteDataSourceImpl implements ActivitiesRemoteDataSource {
  final IHttpClient client;

  ActivitiesRemoteDataSourceImpl({required this.client});

  @override
  Future<List<ActivityModel>> getActivities(int nursingHomeId) async {
    try {
      final response = await client.get('/api/v1/nursing-homes/$nursingHomeId/activities');

      List<dynamic> data;

      if (response is List) {
        data = response;
      } else if (response is Map) {
        if (response.containsKey('content')) {
          data = response['content'] as List<dynamic>;
        } else if (response.containsKey('data')) {
          data = response['data'] as List<dynamic>;
        } else {
          print('DEBUG JSON ACTIVITIES: $response');
          throw ParsingException(message: 'No se encontró la lista en el JSON del servidor.');
        }
      } else {
        throw ParsingException(message: 'Formato de respuesta HTTP desconocido.');
      }

      return data.map((json) => ActivityModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ServerException(message: 'Error al obtener las actividades: $e');
    }
  }
}
