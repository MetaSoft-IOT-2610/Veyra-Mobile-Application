import '../../application/contracts/i_http_client.dart';
import '../../core/exceptions/exceptions.dart'; // Tu clase de ServerException
import 'package:dio/dio.dart'; // Comentado asumiendo que lo instalarás

/// Implementación real del cliente HTTP usando Dio (recomendado para Enterprise)
class DioHttpClientImpl implements IHttpClient {
  // final Dio _dio;
  
  // DioHttpClientImpl(this._dio);

  @override
  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      // final response = await _dio.get(path, queryParameters: queryParameters);
      // return response.data;
      return {}; // Mock para compilación
    } catch (e) {
      // Aquí el interceptor lanza un ServerException que será capturado por los repositorios
      throw Exception('Server Error'); 
    }
  }

  @override
  Future<dynamic> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    // Implementación similar...
    return {};
  }
  
  @override
  Future<dynamic> put(String path, {dynamic data}) async => {};
  
  @override
  Future<dynamic> delete(String path, {dynamic data}) async => {};
}