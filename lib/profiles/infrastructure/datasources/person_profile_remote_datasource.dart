import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../shared/application/contracts/i_http_client.dart';
import '../../../shared/core/exceptions/exceptions.dart';
import '../models/person_profile_model.dart';

abstract class PersonProfileRemoteDataSource {
  Future<PersonProfileModel> createPersonProfile({
    required String dni,
    required String firstName,
    required String lastName,
    required String birthDate,
    required int age,
    required String emailAddress,
    required String street,
    required String number,
    required String city,
    required String postalCode,
    required String country,
    required String phoneNumber,
  });
}

class PersonProfileRemoteDataSourceImpl
    implements PersonProfileRemoteDataSource {
  final IHttpClient client;

  PersonProfileRemoteDataSourceImpl({required this.client});

  @override
  Future<PersonProfileModel> createPersonProfile({
    required String dni,
    required String firstName,
    required String lastName,
    required String birthDate,
    required int age,
    required String emailAddress,
    required String street,
    required String number,
    required String city,
    required String postalCode,
    required String country,
    required String phoneNumber,
  }) async {
    try {
      final formData = FormData.fromMap({
        'dni': dni,
        'firstName': firstName,
        'lastName': lastName,
        'birthDate': birthDate,
        'age': age,
        'emailAddress': emailAddress,
        'street': street,
        'number': number,
        'city': city,
        'postalCode': postalCode,
        'country': country,
        'phoneNumber': phoneNumber,
        'photo': MultipartFile.fromBytes(
          _placeholderPngBytes,
          filename: 'profile-placeholder.png',
          contentType: DioMediaType('image', 'png'),
        ),
      });

      final response = await client.post('person-profiles', data: formData);

      if (response is Map<String, dynamic>) {
        return PersonProfileModel.fromJson(response);
      }

      throw ParsingException(message: 'Unexpected person profile response.');
    } catch (e) {
      throw ServerException(message: 'Failed to create person profile: $e');
    }
  }

  static final Uint8List _placeholderPngBytes = Uint8List.fromList([
    137,
    80,
    78,
    71,
    13,
    10,
    26,
    10,
    0,
    0,
    0,
    13,
    73,
    72,
    68,
    82,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    1,
    8,
    6,
    0,
    0,
    0,
    31,
    21,
    196,
    137,
    0,
    0,
    0,
    13,
    73,
    68,
    65,
    84,
    120,
    156,
    99,
    248,
    15,
    4,
    0,
    9,
    251,
    3,
    253,
    167,
    73,
    164,
    169,
    0,
    0,
    0,
    0,
    73,
    69,
    78,
    68,
    174,
    66,
    96,
    130,
  ]);
}
