import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../application/contracts/i_http_client.dart';
import '../../core/exceptions/exceptions.dart';
import '../local/token_manager.dart';

class DioHttpClientImpl implements IHttpClient {
  final Dio _dio;

  DioHttpClientImpl(String baseUrl)
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = TokenManager.getToken();

          if (token != null && token.isNotEmpty) {
            // Force the header directly onto the map
            options.headers['Authorization'] = 'Bearer $token';
            debugPrint(
              '[DIO] Sending request ${options.path} with valid token',
            );
          } else {
            debugPrint('[DIO] Sending request ${options.path} without token');
          }

          return handler.next(options); // Continue request
        },
      ),
    );
  }

  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ServerException(message: 'Unexpected error executing GET: $e');
    }
  }

  @override
  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ServerException(message: 'Unexpected error executing POST: $e');
    }
  }

  @override
  Future<dynamic> put(String path, {dynamic data}) async {
    try {
      final response = await _dio.put(path, data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ServerException(message: 'Unexpected error executing PUT: $e');
    }
  }

  @override
  Future<dynamic> patch(String path, {dynamic data}) async {
    try {
      final response = await _dio.patch(path, data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ServerException(message: 'Unexpected error executing PATCH: $e');
    }
  }

  @override
  Future<dynamic> delete(String path, {dynamic data}) async {
    try {
      final response = await _dio.delete(path, data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ServerException(message: 'Unexpected error executing DELETE: $e');
    }
  }

  ServerException _handleDioError(DioException e) {
    if (e.response != null) {
      debugPrint(
        '[DIO] Server error: ${e.response?.statusCode} - ${e.response?.data}',
      );
      return ServerException(
        message:
            'Server Error: ${e.response?.statusMessage ?? "Unknown payload"}',
        statusCode: e.response?.statusCode,
      );
    } else {
      debugPrint('[DIO] Network error: $e');
      return ServerException(
        message: 'Network Error: Failed to connect to the server.',
      );
    }
  }
}
