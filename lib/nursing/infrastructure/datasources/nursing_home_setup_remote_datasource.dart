import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../shared/application/contracts/i_http_client.dart';
import '../../../shared/core/exceptions/exceptions.dart';
import '../models/nursing_home_model.dart';

abstract class NursingHomeSetupRemoteDataSource {
  Future<NursingHomeModel> createNursingHome({
    required int administratorId,
    required String businessName,
    required String emailAddress,
    required String phoneNumber,
    required String street,
    required String number,
    required String city,
    required String postalCode,
    required String country,
    required String ruc,
  });
}

class NursingHomeSetupRemoteDataSourceImpl
    implements NursingHomeSetupRemoteDataSource {
  final IHttpClient client;

  NursingHomeSetupRemoteDataSourceImpl({required this.client});

  @override
  Future<NursingHomeModel> createNursingHome({
    required int administratorId,
    required String businessName,
    required String emailAddress,
    required String phoneNumber,
    required String street,
    required String number,
    required String city,
    required String postalCode,
    required String country,
    required String ruc,
  }) async {
    try {
      final formData = FormData.fromMap({
        'businessName': businessName,
        'emailAddress': emailAddress,
        'phoneNumber': phoneNumber,
        'street': street,
        'number': number,
        'city': city,
        'postalCode': postalCode,
        'country': country,
        'ruc': ruc,
        'photo': MultipartFile.fromBytes(
          _placeholderPngBytes,
          filename: 'nursing-home-placeholder.png',
          contentType: DioMediaType('image', 'png'),
        ),
      });

      final response = await client.post(
        'administrators/$administratorId/nursing-homes',
        data: formData,
      );

      if (response is Map<String, dynamic>) {
        return NursingHomeModel.fromJson(response);
      }

      throw ParsingException(message: 'Unexpected nursing home response.');
    } catch (e) {
      throw ServerException(message: 'Failed to create nursing home: $e');
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
