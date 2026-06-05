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
      // Petición al endpoint: GET /api/v1/nursing-homes/{nursingHomeId}/activities
      final response = await client.get('/api/v1/nursing-homes/$nursingHomeId/activities');
      
      // Asumimos que la respuesta es una lista JSON
      final List<dynamic> data = response as List<dynamic>;
      
      return data.map((json) => ActivityModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ServerException(message: 'Error al obtener las actividades: $e');
    }
  }
}