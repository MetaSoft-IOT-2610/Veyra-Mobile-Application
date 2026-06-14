import '../../../shared/application/contracts/i_http_client.dart';
import '../../../shared/core/exceptions/exceptions.dart';
import '../../../shared/infrastructure/local/token_manager.dart';

/// Remote data source responsible for Identity and Access Management (IAM) network requests.
abstract class IamRemoteDataSource {
  /// Authenticates the user with the provided [username] and [password].
  ///
  /// Returns the Administrator ID associated with the authenticated user.
  Future<int> authenticate(String username, String password);

  /// Retrieves the Nursing Home ID managed by the specified [administratorId].
  Future<int> getNursingHomeId(int administratorId);
}

/// Implementation of [IamRemoteDataSource] using the corporate HTTP client.
class IamRemoteDataSourceImpl implements IamRemoteDataSource {
  final IHttpClient client;

  IamRemoteDataSourceImpl({required this.client});

  @override
  Future<int> authenticate(String username, String password) async {
    try {
      print('[IAM] Starting login request...');

      // FIX: Removed '/api/v1/' to prevent URL duplication.
      // Dio automatically prepends the Base URL (http://10.0.2.2:8080/api/v1/).
      final response = await client.post('authentication/sign-in', data: {
        'username': username,
        'password': password,
      });
      print('[IAM] JSON CRUDO DEL BACKEND: $response');

      if (response is Map) {
        // 1. Securely save the JWT token in memory
        if (response.containsKey('token')) {
          TokenManager.saveToken(response['token'] as String);
          print('[IAM] Token saved successfully.');
        }

        // 2. Extract the Aggregate ID (entityId) which directly maps to the Administrator ID
        if (response.containsKey('entityId')) {
          final int entityId = (response['entityId'] as num).toInt();
          print('[IAM] Successfully extracted entityId: $entityId');
          TokenManager.saveAdministratorId(entityId);
          return entityId;
        }
        // Fallback for edge cases where the backend might only return the legacy id
        else if (response.containsKey('id')) {
          final int fallbackId = (response['id'] as num).toInt();
          print('[IAM] Warning: entityId not found, falling back to legacy id: $fallbackId');
          TokenManager.saveAdministratorId(fallbackId);
          return fallbackId;
        }
      }
      throw ParsingException(message: 'Missing required auth fields (entityId) in server response.');
    } catch (e) {
      print('[IAM] Error in authenticate: $e');
      throw ServerException(message: 'Authentication failed. Please check your credentials.');
    }
  }

  @override
  Future<int> getNursingHomeId(int administratorId) async {
    try {
      print('[IAM] Requesting nursing home for admin ID: $administratorId');

      final response = await client.get('administrators/$administratorId/nursing-homes');

      if (response is Map && response.containsKey('id')) {
        return (response['id'] as num).toInt();
      }

      throw ParsingException(message: 'Nursing Home data could not be parsed from the response.');
    } catch (e) {
      print('[IAM] Error en getNursingHomeId: $e');

      // Lanzamos la excepción real con código 404 para que la capa de presentación
      // pueda redirigir a la pantalla de "Requiere Configuración Web".
      throw ServerException(
          message: 'No se encontró una Casa de Reposo asignada. Requiere configuración inicial.',
          statusCode: 404
      );
    }
  }
}
