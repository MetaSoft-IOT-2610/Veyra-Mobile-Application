import '../../../activities/infrastructure/models/activity_model.dart';
import '../../../nursing/infrastructure/models/relative_model.dart';
import '../../../nursing/infrastructure/models/resident_health_models.dart';
import '../../../nursing/infrastructure/models/resident_model.dart';
import '../../../shared/application/contracts/i_http_client.dart';
import '../../../shared/core/exceptions/exceptions.dart';
import '../models/family_health_models.dart';

class FamilyPortalRemoteData {
  final RelativeModel relative;
  final ResidentModel resident;
  final FamilyResidentProfileModel residentProfile;
  final List<ResidentAllergyModel> allergies;
  final List<FamilyMedicationModel> medications;
  final List<FamilyDeviceModel> devices;
  final List<ResidentVitalSignModel> vitalSigns;
  final List<ActivityModel> activities;
  final List<MeasurementModel> measurements;

  const FamilyPortalRemoteData({
    required this.relative,
    required this.resident,
    required this.residentProfile,
    required this.allergies,
    required this.medications,
    required this.devices,
    required this.vitalSigns,
    required this.activities,
    required this.measurements,
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
      final relative = await _findRelative(userId);

      final residentsResponse = await client.get(
        'relatives/${relative.id}/residents',
      );
      final residentJsonList = _extractList(residentsResponse);
      if (residentJsonList.isEmpty) {
        throw ServerException(
          message: 'No resident is assigned to this family account.',
          statusCode: 404,
        );
      }
      final residentJson = Map<String, dynamic>.from(
        residentJsonList.first as Map,
      );
      final personProfileId = _asInt(residentJson['personProfileId']);
      var residentProfile = FamilyResidentProfileModel.fromJson(
        const <String, dynamic>{},
      );
      if (personProfileId > 0) {
        final profileResponse = await client.get(
          'person-profiles/$personProfileId',
        );
        if (profileResponse is Map) {
          final profileJson = Map<String, dynamic>.from(profileResponse);
          residentJson['personProfile'] = profileJson;
          residentProfile = FamilyResidentProfileModel.fromJson(profileJson);
        }
      }
      final resident = ResidentModel.fromJson(residentJson);

      final results = await Future.wait<dynamic>([
        _getOptionalList('residents/${resident.id}/allergies'),
        _getOptionalList('residents/${resident.id}/devices'),
        _getOptionalList('resident/${resident.id}/vital-signs'),
        _getOptionalList('nursing-homes/${relative.nursingHomeId}/activities'),
      ]);

      final devices = (results[1] as List<dynamic>)
          .map(
            (json) =>
                FamilyDeviceModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();

      final List<MeasurementModel> measurements = [];
      if (devices.isNotEmpty) {
        final measurementsResults = await Future.wait(
          devices.map((device) => _getOptionalList('devices/${device.id}/measurements')),
        );
        for (final list in measurementsResults) {
          measurements.addAll(
            list.map((json) => MeasurementModel.fromJson(json as Map<String, dynamic>)),
          );
        }
      }

      return FamilyPortalRemoteData(
        relative: relative,
        resident: resident,
        residentProfile: residentProfile,
        allergies: (results[0] as List<dynamic>)
            .map(
              (json) =>
                  ResidentAllergyModel.fromJson(json as Map<String, dynamic>),
            )
            .toList(),
        medications: const [],
        devices: devices,
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
        measurements: measurements,
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Failed to load family portal: $e');
    }
  }

  Future<RelativeModel> _findRelative(int userId) async {
    final nursingHomes = _extractList(await client.get('nursing-homes'));
    for (final nursingHomeJson in nursingHomes) {
      if (nursingHomeJson is! Map) continue;
      final nursingHomeId = _asInt(nursingHomeJson['id']);
      if (nursingHomeId == 0) continue;

      final relatives = await _getOptionalList(
        'nursing-homes/$nursingHomeId/relatives',
      );
      for (final relativeJson in relatives) {
        if (relativeJson is! Map) continue;
        final relative = RelativeModel.fromJson(
          Map<String, dynamic>.from(relativeJson),
        );
        if (relative.userId == userId) return relative;
      }
    }

    throw ServerException(
      message: 'No resident is assigned to this family account.',
      statusCode: 404,
    );
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

  int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
