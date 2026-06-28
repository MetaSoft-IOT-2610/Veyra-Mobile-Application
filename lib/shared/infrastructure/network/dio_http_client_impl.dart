import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../application/contracts/i_http_client.dart';
import '../../core/exceptions/exceptions.dart';
import '../local/token_manager.dart';

class DioHttpClientImpl implements IHttpClient {
  final Dio _dio;
  final Map<String, Future<dynamic>> _inFlightGets = {};

  DioHttpClientImpl(String baseUrl)
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = TokenManager.getToken();

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
            if (kDebugMode) {
              debugPrint(
                '[DIO] Sending request ${options.path} with valid token',
              );
            }
          } else if (kDebugMode) {
            debugPrint('[DIO] Sending request ${options.path} without token');
          }

          return handler.next(options);
        },
      ),
    );
  }

  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final key = _getRequestKey(path, queryParameters);
    final activeRequest = _inFlightGets[key];
    if (activeRequest != null) return activeRequest;

    final request = _executeGet(path, queryParameters);
    _inFlightGets[key] = request;

    try {
      return await request;
    } finally {
      if (identical(_inFlightGets[key], request)) {
        _inFlightGets.remove(key);
      }
    }
  }

  Future<dynamic> _executeGet(
    String path,
    Map<String, dynamic>? queryParameters,
  ) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ServerException(message: 'Unexpected error executing GET: $e');
    }
  }

  String _getRequestKey(String path, Map<String, dynamic>? queryParameters) {
    if (queryParameters == null || queryParameters.isEmpty) return path;
    final keys = queryParameters.keys.toList()..sort();
    final query = keys.map((key) => '$key=${queryParameters[key]}').join('&');
    return '$path?$query';
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
      if (kDebugMode) {
        debugPrint(
          '[DIO] Server error: ${e.response?.statusCode} - ${e.response?.data}',
        );
      }
      return ServerException(
        message:
            'Server Error: ${e.response?.statusMessage ?? "Unknown payload"}',
        statusCode: e.response?.statusCode,
      );
    } else {
      if (kDebugMode) debugPrint('[DIO] Network error: $e');
      return ServerException(
        message: 'Network Error: Failed to connect to the server.',
      );
    }
  }
}
