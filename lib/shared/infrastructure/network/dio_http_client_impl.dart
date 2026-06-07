import 'package:dio/dio.dart';
import '../../application/contracts/i_http_client.dart';
import '../../core/exceptions/exceptions.dart';
import '../local/token_manager.dart';

/// Enterprise-grade implementation of the HTTP client using the [Dio] package.
///
/// This client automatically handles base URLs, connection timeouts, and
/// intercepts outgoing requests to inject authorization tokens.
class DioHttpClientImpl implements IHttpClient {
  final Dio _dio;

  /// Creates a new instance of [DioHttpClientImpl].
  ///
  /// The [baseUrl] parameter sets the root URL for all API requests.
  /// It also configures default timeouts and sets up the JWT interceptor.
  DioHttpClientImpl(String baseUrl)
      : _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  )) {
    // Interceptor to inject the JWT Token automatically into ALL requests
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = TokenManager.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  /// Performs an HTTP GET request to the specified [path].
  ///
  /// Optional [queryParameters] can be passed to append to the URL.
  /// Returns the dynamic JSON data from the response.
  /// Throws a [ServerException] if the request fails.
  @override
  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ServerException(message: 'Unexpected error executing GET: $e');
    }
  }

  /// Performs an HTTP POST request to the specified [path].
  ///
  /// The payload is passed through the [data] parameter.
  /// Optional [queryParameters] can also be included.
  /// Returns the dynamic JSON data from the response.
  /// Throws a [ServerException] if the request fails.
  @override
  Future<dynamic> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.post(path, data: data, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ServerException(message: 'Unexpected error executing POST: $e');
    }
  }

  /// Performs an HTTP PUT request to the specified [path].
  ///
  /// The payload is passed through the [data] parameter.
  /// Returns the dynamic JSON data from the response.
  /// Throws a [ServerException] if the request fails.
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

  /// Performs an HTTP DELETE request to the specified [path].
  ///
  /// Optional [data] can be passed if the API requires a body for deletion.
  /// Returns the dynamic JSON data from the response.
  /// Throws a [ServerException] if the request fails.
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

  /// Centralized error handler that maps a [DioException] to the domain's [ServerException].
  ServerException _handleDioError(DioException e) {
    if (e.response != null) {
      return ServerException(
        message: 'Server Error: ${e.response?.statusMessage ?? "Unknown payload"}',
        statusCode: e.response?.statusCode,
      );
    }
    else {
      // Network error, timeout, or DNS resolution failure
      return ServerException(
        message: 'Network Error: Failed to connect to the server.',
      );
    }
  }
}
