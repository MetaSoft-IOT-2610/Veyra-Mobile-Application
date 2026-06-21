import '../../../activities/infrastructure/models/activity_model.dart';
import '../../../nursing/infrastructure/models/relative_model.dart';
import '../../../nursing/infrastructure/models/resident_health_models.dart';
import '../../../nursing/infrastructure/models/resident_model.dart';
import '../../../shared/application/contracts/i_http_client.dart';
import '../../../shared/core/exceptions/exceptions.dart';

class FamilyPortalRemoteData {
  final RelativeModel relative;
  final ResidentModel resident;
  final List<ResidentAllergyModel> allergies;
  final List<ResidentMedicalConditionModel> medicalConditions;
  final List<ResidentVitalSignModel> vitalSigns;
  final List<ActivityModel> activities;

  const FamilyPortalRemoteData({
    required this.relative,
    required this.resident,
    required this.allergies,
    required this.medicalConditions,
    required this.vitalSigns,
    required this.activities,
  });
}

abstract class FamilyPortalRemoteDataSource {
  Future<FamilyPortalRemoteData> getPortalData(int userId);
}

class FamilyPortalRemoteDataSourceImpl implements FamilyPortalRemoteDataSource {
  final IHttpClient client;

  FamilyPortalRemoteDataSourceImpl({required this.client});

  @override
  Future<FamilyPortalRemoteData> getPortalData(int userId) async {
    try {
      final relativeResponse = await client.get('relatives/by-user/$userId');
      if (relativeResponse is! Map<String, dynamic>) {
        throw ParsingException(message: 'Relative response is invalid.');
      }
      final relative = RelativeModel.fromJson(relativeResponse);

      final residentsResponse = await client.get(
        'relatives/${relative.id}/residents',
      );
      final residents = _extractList(residentsResponse)
          .map((json) => ResidentModel.fromJson(json as Map<String, dynamic>))
          .toList();
      if (residents.isEmpty) {
        throw ServerException(
          message: 'No resident is assigned to this family account.',
          statusCode: 404,
        );
      }
      final resident = residents.first;

      final results = await Future.wait<dynamic>([
        _getOptionalList('residents/${resident.id}/allergies'),
        _getOptionalList('residents/${resident.id}/medical-conditions'),
        _getOptionalList('resident/${resident.id}/vital-signs'),
        _getOptionalList('nursing-homes/${relative.nursingHomeId}/activities'),
      ]);

      return FamilyPortalRemoteData(
        relative: relative,
        resident: resident,
        allergies: (results[0] as List<dynamic>)
            .map(
              (json) =>
                  ResidentAllergyModel.fromJson(json as Map<String, dynamic>),
            )
            .toList(),
        medicalConditions: (results[1] as List<dynamic>)
            .map(
              (json) => ResidentMedicalConditionModel.fromJson(
                json as Map<String, dynamic>,
              ),
            )
            .toList(),
        vitalSigns: (results[2] as List<dynamic>)
            .map(
              (json) =>
                  ResidentVitalSignModel.fromJson(json as Map<String, dynamic>),
            )
            .toList(),
        activities: (results[3] as List<dynamic>)
            .map((json) => ActivityModel.fromJson(json as Map<String, dynamic>))
            .where((activity) => activity.residentId == resident.id)
            .toList(),
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Failed to load family portal: $e');
    }
  }

  Future<List<dynamic>> _getOptionalList(String path) async {
    try {
      return _extractList(await client.get(path));
    } on ServerException catch (e) {
      if (e.statusCode == 404) return [];
      rethrow;
    }
  }

  List<dynamic> _extractList(dynamic response) {
    if (response is List) return response;
    if (response is Map) {
      if (response['content'] is List) return response['content'] as List;
      if (response['data'] is List) return response['data'] as List;
    }
    throw ParsingException(message: 'Expected a list response.');
  }
}
