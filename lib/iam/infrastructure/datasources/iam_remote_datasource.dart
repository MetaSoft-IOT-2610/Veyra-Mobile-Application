import '../../../shared/application/contracts/i_http_client.dart';
import '../../../shared/core/exceptions/exceptions.dart';
import '../../../shared/infrastructure/local/token_manager.dart';
import '../../domain/entities/authenticated_user.dart';

/// Remote data source responsible for Identity and Access Management (IAM) network requests.
abstract class IamRemoteDataSource {
  /// Authenticates the user with the provided [username] and [password].
  ///
  /// Returns the authenticated user and role metadata.
  Future<AuthenticatedUser> authenticate(String username, String password);

  /// Retrieves the Nursing Home ID managed by the specified [administratorId].
  Future<int> getNursingHomeId(int administratorId);

  /// Registers a new family user in IAM.
  Future<void> signUp(String username, String password);

  /// Registers a new administrator user and aggregate.
  Future<int> signUpAdministrator(String username, String password);
}

/// Implementation of [IamRemoteDataSource] using the corporate HTTP client.
class IamRemoteDataSourceImpl implements IamRemoteDataSource {
  final IHttpClient client;

  IamRemoteDataSourceImpl({required this.client});

  @override
  Future<AuthenticatedUser> authenticate(
    String username,
    String password,
  ) async {
    try {
      print('[IAM] Starting login request...');

      // FIX: Removed '/api/v1/' to prevent URL duplication.
      // Dio automatically prepends the Base URL (http://10.0.2.2:8080/api/v1/).
      final response = await client.post(
        'authentication/sign-in',
        data: {'username': username, 'password': password},
      );
      print('[IAM] JSON CRUDO DEL BACKEND: $response');

      if (response is Map) {
        // 1. Securely save the JWT token in memory
        if (response.containsKey('token')) {
          TokenManager.saveToken(response['token'] as String);
          print('[IAM] Token saved successfully.');
        }

        final id = (response['id'] as num?)?.toInt();
        if (id == null) {
          throw ParsingException(message: 'Missing user id in auth response.');
        }
        TokenManager.saveUserId(id);

        final roles = (response['roles'] as List<dynamic>? ?? [])
            .map((role) => role.toString())
            .toList();

        int? entityId;
        if (response['entityId'] != null) {
          entityId = (response['entityId'] as num).toInt();
          print('[IAM] Successfully extracted entityId: $entityId');
          TokenManager.saveAdministratorId(entityId);
        }

        return AuthenticatedUser(
          id: id,
          username: response['username'] as String? ?? username,
          roles: roles,
          entityId: entityId,
        );
      }
      throw ParsingException(
        message: 'Authentication response could not be parsed.',
      );
    } catch (e) {
      print('[IAM] Error in authenticate: $e');
      throw ServerException(
        message: 'Authentication failed. Please check your credentials.',
      );
    }
  }

  @override
  Future<void> signUp(String username, String password) async {
    try {
      final response = await client.post(
        'authentication/sign-up',
        data: {
          'username': username,
          'password': password,
          'roles': ['ROLE_FAMILIAR'],
        },
      );

      if (response is Map && response.containsKey('id')) {
        return;
      }

      throw ParsingException(message: 'User data could not be parsed.');
    } catch (e) {
      print('[IAM] Error in signUp: $e');
      throw ServerException(message: 'Sign up failed. Please try again.');
    }
  }

  @override
  Future<int> signUpAdministrator(String username, String password) async {
    try {
      final response = await client.post(
        'administrators',
        data: {'username': username, 'password': password},
      );

      if (response is Map && response.containsKey('id')) {
        final nursingHomeId = (response['id'] as num).toInt();
        TokenManager.saveNursingHomeId(nursingHomeId);
        return nursingHomeId;
      }

      throw ParsingException(
        message: 'Administrator data could not be parsed.',
      );
    } catch (e) {
      print('[IAM] Error in signUpAdministrator: $e');
      throw ServerException(
        message: 'Administrator sign up failed. Please try again.',
      );
    }
  }

  @override
  Future<int> getNursingHomeId(int administratorId) async {
    try {
      print('[IAM] Requesting nursing home for admin ID: $administratorId');

      final response = await client.get(
        'administrators/$administratorId/nursing-homes',
      );

      if (response is Map && response.containsKey('id')) {
        return (response['id'] as num).toInt();
      }

      throw ParsingException(
        message: 'Nursing Home data could not be parsed from the response.',
      );
    } catch (e) {
      print('[IAM] Error en getNursingHomeId: $e');

      // Lanzamos la excepción real con código 404 para que la capa de presentación
      // pueda redirigir a la pantalla de "Requiere Configuración Web".
      throw ServerException(
        message:
            'No se encontró una Casa de Reposo asignada. Requiere configuración inicial.',
        statusCode: 404,
      );
    }
  }
}
