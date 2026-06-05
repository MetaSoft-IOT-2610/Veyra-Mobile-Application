/// Contrato corporativo para todas las llamadas de red externas.
abstract class IHttpClient {
  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters});
  
  Future<dynamic> post(String path, {dynamic data, Map<String, dynamic>? queryParameters});
  
  Future<dynamic> put(String path, {dynamic data});
  
  Future<dynamic> delete(String path, {dynamic data});
}