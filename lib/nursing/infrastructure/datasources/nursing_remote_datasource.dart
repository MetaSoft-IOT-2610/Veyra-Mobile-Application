import 'package:dio/dio.dart';

import '../../../shared/application/contracts/i_http_client.dart';
import '../../../shared/core/exceptions/exceptions.dart';
import '../models/family_user_model.dart';
import '../models/resident_health_models.dart';
import '../models/resident_model.dart';
import '../models/relative_model.dart';
import '../models/room_model.dart';

abstract class NursingRemoteDataSource {
  Future<List<ResidentModel>> getResidents(int nursingHomeId);

  Future<ResidentModel> createResident({
    required int nursingHomeId,
    required String dni,
    required String firstName,
    required String lastName,
    required DateTime birthDate,
    required int age,
    required String emailAddress,
    required String street,
    required String number,
    required String city,
    required String postalCode,
    required String country,
    required String phoneNumber,
    required String legalRepresentativeFirstName,
    required String legalRepresentativeLastName,
    required String legalRepresentativePhoneNumber,
    required String emergencyContactFirstName,
    required String emergencyContactLastName,
    required String emergencyContactPhoneNumber,
  });

  Future<List<RoomModel>> getRooms(int nursingHomeId);

  Future<ResidentModel> assignRoom({
    required int nursingHomeId,
    required int residentId,
    required String roomNumber,
  });

  Future<List<ResidentAllergyModel>> getAllergies(int residentId);

  Future<ResidentAllergyModel> registerAllergy({
    required int residentId,
    required String allergenName,
    required String reaction,
    required String typeOfAllergy,
    required String severityLevel,
  });

  Future<List<ResidentMedicalConditionModel>> getMedicalConditions(
    int residentId,
  );

  Future<ResidentMedicalConditionModel> registerMedicalCondition({
    required int residentId,
    required String diagnosisName,
    required DateTime diagnosisDate,
    required String status,
    required String notes,
  });

  Future<List<ResidentVitalSignModel>> getVitalSigns(int residentId);

  Future<List<FamilyUserModel>> getFamilyUsers();

  Future<List<RelativeModel>> getRelatives(int nursingHomeId);

  Future<RelativeModel> createRelative({
    required int nursingHomeId,
    required int residentId,
    required String firstName,
    required String lastName,
    required String email,
    required int userId,
  });
}

class NursingRemoteDataSourceImpl implements NursingRemoteDataSource {
  final IHttpClient client;

  NursingRemoteDataSourceImpl({required this.client});

  @override
  Future<List<ResidentModel>> getResidents(int nursingHomeId) async {
    try {
      final response = await client.get(
        'nursing-homes/$nursingHomeId/residents',
      );
      final data = _extractList(response);
      return Future.wait(
        data.map((json) => _enrichResident(json as Map<String, dynamic>)),
      );
    } catch (e) {
      throw ServerException(message: 'Error fetching residents: $e');
    }
  }

  Future<ResidentModel> _enrichResident(Map<String, dynamic> residentJson) async {
    final enrichedJson = Map<String, dynamic>.from(residentJson);
    final personProfileId =
        (residentJson['personProfileId'] as num?)?.toInt() ?? 0;

    if (personProfileId > 0) {
      try {
        final profileResponse = await client.get(
          'person-profiles/$personProfileId',
        );
        if (profileResponse is Map) {
          final photo = profileResponse['photo'] as String?;
          if (photo != null && photo.isNotEmpty) {
            enrichedJson['photo'] = photo;
          }
        }
      } on ServerException catch (e) {
        if (e.statusCode != 404) rethrow;
      }
    }

    return ResidentModel.fromJson(enrichedJson);
  }

  @override
  Future<ResidentModel> createResident({
    required int nursingHomeId,
    required String dni,
    required String firstName,
    required String lastName,
    required DateTime birthDate,
    required int age,
    required String emailAddress,
    required String street,
    required String number,
    required String city,
    required String postalCode,
    required String country,
    required String phoneNumber,
    required String legalRepresentativeFirstName,
    required String legalRepresentativeLastName,
    required String legalRepresentativePhoneNumber,
    required String emergencyContactFirstName,
    required String emergencyContactLastName,
    required String emergencyContactPhoneNumber,
  }) async {
    try {
      final formData = FormData.fromMap({
        'dni': dni,
        'firstName': firstName,
        'lastName': lastName,
        'birthDate': _formatDate(birthDate),
        'age': age,
        'emailAddress': emailAddress,
        'street': street,
        'number': number,
        'city': city,
        'postalCode': postalCode,
        'country': country,
        'phoneNumber': phoneNumber,
        'legalRepresentativeFirstName': legalRepresentativeFirstName,
        'legalRepresentativeLastName': legalRepresentativeLastName,
        'legalRepresentativePhoneNumber': legalRepresentativePhoneNumber,
        'emergencyContactFirstName': emergencyContactFirstName,
        'emergencyContactLastName': emergencyContactLastName,
        'emergencyContactPhoneNumber': emergencyContactPhoneNumber,
        'photo': MultipartFile.fromBytes(
          _placeholderPhotoBytes,
          filename: 'resident-photo.png',
        ),
      });

      final response = await client.post(
        'nursing-homes/$nursingHomeId/residents',
        data: formData,
      );

      if (response is Map<String, dynamic>) {
        return ResidentModel.fromJson(response);
      }

      throw ParsingException(
        message: 'Resident data could not be parsed from the response.',
      );
    } catch (e) {
      throw ServerException(message: 'Error creating resident: $e');
    }
  }

  @override
  Future<List<RoomModel>> getRooms(int nursingHomeId) async {
    try {
      final response = await client.get('nursing-homes/$nursingHomeId/rooms');
      final data = _extractList(response);
      return data
          .map((json) => RoomModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(message: 'Error fetching rooms: $e');
    }
  }

  @override
  Future<ResidentModel> assignRoom({
    required int nursingHomeId,
    required int residentId,
    required String roomNumber,
  }) async {
    try {
      final response = await client.post(
        'nursing-homes/$nursingHomeId/rooms/$residentId',
        data: {'roomNumber': roomNumber},
      );
      if (response is Map<String, dynamic>) {
        return ResidentModel.fromJson(response);
      }
      throw ParsingException(
        message: 'Resident room assignment could not be parsed.',
      );
    } catch (e) {
      throw ServerException(message: 'Error assigning room: $e');
    }
  }

  @override
  Future<List<ResidentAllergyModel>> getAllergies(int residentId) async {
    try {
      final response = await client.get('residents/$residentId/allergies');
      final data = _extractList(response);
      return data
          .map(
            (json) =>
                ResidentAllergyModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } on ServerException catch (e) {
      if (e.statusCode == 404) return [];
      throw ServerException(
        message: 'Error fetching allergies: $e',
        statusCode: e.statusCode,
      );
    } catch (e) {
      throw ServerException(message: 'Error fetching allergies: $e');
    }
  }

  @override
  Future<ResidentAllergyModel> registerAllergy({
    required int residentId,
    required String allergenName,
    required String reaction,
    required String typeOfAllergy,
    required String severityLevel,
  }) async {
    try {
      final response = await client.post(
        'residents/$residentId/allergies',
        data: {
          'allergenName': allergenName,
          'reaction': reaction,
          'typeOfAllergy': typeOfAllergy,
          'severityLevel': severityLevel,
        },
      );
      if (response is Map<String, dynamic>) {
        return ResidentAllergyModel.fromJson(response);
      }
      throw ParsingException(message: 'Allergy data could not be parsed.');
    } catch (e) {
      throw ServerException(message: 'Error registering allergy: $e');
    }
  }

  @override
  Future<List<ResidentMedicalConditionModel>> getMedicalConditions(
    int residentId,
  ) async {
    try {
      final response = await client.get(
        'residents/$residentId/medical-conditions',
      );
      final data = _extractList(response);
      return data
          .map(
            (json) => ResidentMedicalConditionModel.fromJson(
              json as Map<String, dynamic>,
            ),
          )
          .toList();
    } catch (e) {
      throw ServerException(message: 'Error fetching medical conditions: $e');
    }
  }

  @override
  Future<ResidentMedicalConditionModel> registerMedicalCondition({
    required int residentId,
    required String diagnosisName,
    required DateTime diagnosisDate,
    required String status,
    required String notes,
  }) async {
    try {
      final response = await client.post(
        'residents/$residentId/medical-conditions',
        data: {
          'diagnosisName': diagnosisName,
          'diagnosisDate': _formatDate(diagnosisDate),
          'status': status,
          'notes': notes,
        },
      );
      if (response is Map<String, dynamic>) {
        return ResidentMedicalConditionModel.fromJson(response);
      }
      throw ParsingException(
        message: 'Medical condition data could not be parsed.',
      );
    } catch (e) {
      throw ServerException(message: 'Error registering medical condition: $e');
    }
  }

  @override
  Future<List<ResidentVitalSignModel>> getVitalSigns(int residentId) async {
    try {
      final response = await client.get('resident/$residentId/vital-signs');
      final data = response is Map && response['content'] is List
          ? response['content'] as List<dynamic>
          : _extractList(response);
      return data
          .map(
            (json) =>
                ResidentVitalSignModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      throw ServerException(message: 'Error fetching vital signs: $e');
    }
  }

  @override
  Future<List<RelativeModel>> getRelatives(int nursingHomeId) async {
    try {
      final response = await client.get(
        'nursing-homes/$nursingHomeId/relatives',
      );
      final data = _extractList(response);
      return data
          .map((json) => RelativeModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(message: 'Error fetching relatives: $e');
    }
  }

  @override
  Future<List<FamilyUserModel>> getFamilyUsers() async {
    try {
      final response = await client.get('users');
      final data = _extractList(response);
      return data
          .map((json) => FamilyUserModel.fromJson(json as Map<String, dynamic>))
          .where((user) => user.roles.contains('ROLE_FAMILIAR'))
          .toList();
    } catch (e) {
      throw ServerException(message: 'Error fetching family users: $e');
    }
  }

  @override
  Future<RelativeModel> createRelative({
    required int nursingHomeId,
    required int residentId,
    required String firstName,
    required String lastName,
    required String email,
    required int userId,
  }) async {
    try {
      final normalizedEmail = email.trim().toLowerCase();
      final existingRelatives = await getRelatives(nursingHomeId);
      final existingRelative = _findRelativeByEmail(
        existingRelatives,
        normalizedEmail,
      );

      if (existingRelative != null) {
        if (existingRelative.residentId != residentId) {
          throw ServerException(
            message:
                'This family account is already assigned to another resident.',
          );
        }

        if (existingRelative.userId != null &&
            existingRelative.userId != userId) {
          throw ServerException(
            message:
                'This relative is already linked to another family account.',
          );
        }

        if (existingRelative.userId == userId) {
          return existingRelative;
        }

        return await _linkUserToRelative(email: email, userId: userId);
      }

      final response = await client.post(
        'nursing-homes/$nursingHomeId/relatives',
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'residentId': residentId,
        },
      );
      if (response is Map<String, dynamic>) {
        return await _linkUserToRelative(email: email, userId: userId);
      }
      throw ParsingException(message: 'Relative data could not be parsed.');
    } catch (e) {
      throw ServerException(message: 'Error creating relative: $e');
    }
  }

  Future<RelativeModel> _linkUserToRelative({
    required String email,
    required int userId,
  }) async {
    final linkedResponse = await client.post(
      'relatives/user-link',
      data: {'email': email, 'userId': userId},
    );
    if (linkedResponse is Map<String, dynamic>) {
      return RelativeModel.fromJson(linkedResponse);
    }
    throw ParsingException(
      message: 'Linked relative data could not be parsed.',
    );
  }

  RelativeModel? _findRelativeByEmail(
    List<RelativeModel> relatives,
    String normalizedEmail,
  ) {
    for (final relative in relatives) {
      if (relative.email.trim().toLowerCase() == normalizedEmail) {
        return relative;
      }
    }
    return null;
  }

  List<dynamic> _extractList(dynamic response) {
    if (response is List) {
      return response;
    } else if (response is Map) {
      if (response.containsKey('content')) {
        return response['content'] as List<dynamic>;
      }
      if (response.containsKey('data')) {
        return response['data'] as List<dynamic>;
      }

      throw ParsingException(
        message: 'Could not find the list in the JSON response.',
      );
    }
    throw ParsingException(message: 'Unknown HTTP response format.');
  }

  String _formatDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  static const List<int> _placeholderPhotoBytes = [
    0x89,
    0x50,
    0x4E,
    0x47,
    0x0D,
    0x0A,
    0x1A,
    0x0A,
    0x00,
    0x00,
    0x00,
    0x0D,
    0x49,
    0x48,
    0x44,
    0x52,
    0x00,
    0x00,
    0x00,
    0x01,
    0x00,
    0x00,
    0x00,
    0x01,
    0x08,
    0x06,
    0x00,
    0x00,
    0x00,
    0x1F,
    0x15,
    0xC4,
    0x89,
    0x00,
    0x00,
    0x00,
    0x0A,
    0x49,
    0x44,
    0x41,
    0x54,
    0x78,
    0x9C,
    0x63,
    0x00,
    0x01,
    0x00,
    0x00,
    0x05,
    0x00,
    0x01,
    0x0D,
    0x0A,
    0x2D,
    0xB4,
    0x00,
    0x00,
    0x00,
    0x00,
    0x49,
    0x45,
    0x4E,
    0x44,
    0xAE,
    0x42,
    0x60,
    0x82,
  ];
}
