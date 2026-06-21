import '../../../shared/application/contracts/i_http_client.dart';
import '../../../shared/core/exceptions/exceptions.dart';
import '../models/activity_model.dart';

abstract class ActivitiesRemoteDataSource {
  Future<List<ActivityModel>> getActivities(int nursingHomeId);

  Future<ActivityModel> createActivity({
    required int nursingHomeId,
    required int residentId,
    required int healthcareStaffId,
    required String type,
    required String title,
    required bool isRecurring,
    required List<String> recurringDays,
  });

  Future<ActivityModel> advanceActivityStatus(int activityId);

  Future<void> deleteActivity(int activityId);
}

class ActivitiesRemoteDataSourceImpl implements ActivitiesRemoteDataSource {
  final IHttpClient client;

  ActivitiesRemoteDataSourceImpl({required this.client});

  @override
  Future<List<ActivityModel>> getActivities(int nursingHomeId) async {
    try {
      final response = await client.get(
        'nursing-homes/$nursingHomeId/activities',
      );
      final data = _extractList(response);
      return data
          .map((json) => ActivityModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(message: 'Error fetching activities: $e');
    }
  }

  @override
  Future<ActivityModel> createActivity({
    required int nursingHomeId,
    required int residentId,
    required int healthcareStaffId,
    required String type,
    required String title,
    required bool isRecurring,
    required List<String> recurringDays,
  }) async {
    try {
      final response = await client.post(
        'nursing-homes/$nursingHomeId/activities',
        data: {
          'residentId': residentId,
          'healthcareStaffId': healthcareStaffId,
          'type': type,
          'title': title,
          'isRecurring': isRecurring,
          'recurringDays': recurringDays,
        },
      );

      if (response is Map<String, dynamic>) {
        return ActivityModel.fromJson(response);
      }

      throw ParsingException(message: 'Activity data could not be parsed.');
    } catch (e) {
      throw ServerException(message: 'Error creating activity: $e');
    }
  }

  @override
  Future<ActivityModel> advanceActivityStatus(int activityId) async {
    try {
      final response = await client.patch('activities/$activityId/complete');
      if (response is Map<String, dynamic>) {
        return ActivityModel.fromJson(response);
      }
      throw ParsingException(message: 'Activity data could not be parsed.');
    } catch (e) {
      throw ServerException(message: 'Error updating activity status: $e');
    }
  }

  @override
  Future<void> deleteActivity(int activityId) async {
    try {
      await client.delete('activities/$activityId');
    } catch (e) {
      throw ServerException(message: 'Error deleting activity: $e');
    }
  }

  List<dynamic> _extractList(dynamic response) {
    if (response is List) return response;
    if (response is Map) {
      if (response['content'] is List) return response['content'] as List;
      if (response['data'] is List) return response['data'] as List;
    }
    throw ParsingException(
      message: 'Could not find activities in the server response.',
    );
  }
}
