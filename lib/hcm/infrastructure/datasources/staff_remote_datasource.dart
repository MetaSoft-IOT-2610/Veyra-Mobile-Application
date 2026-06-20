import 'package:dio/dio.dart';

import '../../../shared/application/contracts/i_http_client.dart';
import '../../../shared/core/exceptions/exceptions.dart';
import '../models/staff_contract_model.dart';
import '../models/staff_model.dart';

abstract class StaffRemoteDataSource {
  Future<List<StaffModel>> getStaff(int nursingHomeId);

  Future<StaffModel> createStaff({
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
    required String emergencyContactFirstName,
    required String emergencyContactLastName,
    required String emergencyContactPhoneNumber,
  });

  Future<List<StaffContractModel>> getContracts(int staffMemberId);

  Future<StaffContractModel> addContract({
    required int staffMemberId,
    required DateTime startDate,
    required DateTime endDate,
    required String typeOfContract,
    required String staffRole,
    required String workShift,
  });
}

class StaffRemoteDataSourceImpl implements StaffRemoteDataSource {
  final IHttpClient client;

  StaffRemoteDataSourceImpl({required this.client});

  @override
  Future<List<StaffModel>> getStaff(int nursingHomeId) async {
    try {
      final response = await client.get('nursing-homes/$nursingHomeId/staff');
      final data = _extractList(response);
      return data
          .map((json) => StaffModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(message: 'Error fetching staff: $e');
    }
  }

  @override
  Future<StaffModel> createStaff({
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
        'emergencyContactFirstName': emergencyContactFirstName,
        'emergencyContactLastName': emergencyContactLastName,
        'emergencyContactPhoneNumber': emergencyContactPhoneNumber,
        'photo': MultipartFile.fromBytes(
          _placeholderPhotoBytes,
          filename: 'staff-photo.png',
        ),
      });

      final response = await client.post(
        'nursing-homes/$nursingHomeId/staff',
        data: formData,
      );

      if (response is Map<String, dynamic>) {
        return StaffModel.fromJson(response);
      }

      throw ParsingException(
        message: 'Staff data could not be parsed from the response.',
      );
    } catch (e) {
      throw ServerException(message: 'Error creating staff: $e');
    }
  }

  @override
  Future<List<StaffContractModel>> getContracts(int staffMemberId) async {
    try {
      final response = await client.get('staff/$staffMemberId/contracts');
      final data = _extractList(response);
      return data
          .map(
            (json) => StaffContractModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } on ServerException catch (e) {
      if (e.statusCode == 404) return [];
      throw ServerException(
        message: 'Error fetching staff contracts: $e',
        statusCode: e.statusCode,
      );
    } catch (e) {
      throw ServerException(message: 'Error fetching staff contracts: $e');
    }
  }

  @override
  Future<StaffContractModel> addContract({
    required int staffMemberId,
    required DateTime startDate,
    required DateTime endDate,
    required String typeOfContract,
    required String staffRole,
    required String workShift,
  }) async {
    try {
      final response = await client.post(
        'staff/$staffMemberId/contracts',
        data: {
          'startDate': _formatDate(startDate),
          'endDate': _formatDate(endDate),
          'typeOfContract': typeOfContract,
          'staffRole': staffRole,
          'workShift': workShift,
        },
      );

      if (response is Map<String, dynamic>) {
        return StaffContractModel.fromJson(response);
      }

      throw ParsingException(
        message: 'Contract data could not be parsed from the response.',
      );
    } catch (e) {
      throw ServerException(message: 'Error adding staff contract: $e');
    }
  }

  List<dynamic> _extractList(dynamic response) {
    if (response is List) {
      return response;
    }
    if (response is Map) {
      if (response.containsKey('content')) {
        return response['content'] as List<dynamic>;
      }
      if (response.containsKey('data')) {
        return response['data'] as List<dynamic>;
      }
      throw ParsingException(
        message: 'Could not find the list in the server JSON response.',
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
