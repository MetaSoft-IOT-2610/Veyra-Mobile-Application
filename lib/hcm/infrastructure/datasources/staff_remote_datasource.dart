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
      final data = response as List<dynamic>;
      return data.map((json) => StaffModel.fromJson(json)).toList();
    } catch (e) {
      throw ServerException(message: 'Error fetching staff: $e');
    }
  }
}
