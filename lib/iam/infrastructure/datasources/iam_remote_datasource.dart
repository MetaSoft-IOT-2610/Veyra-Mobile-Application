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

  /// Retrieves the nursing home assigned to the specified staff member.
  Future<int> getStaffNursingHomeId(int staffId);

  /// Checks whether a person profile already exists for a family email.
  Future<bool> hasPersonProfileForEmail(String email);

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
      // FIX: Removed '/api/v1/' to prevent URL duplication.
      // Dio automatically prepends the Base URL (http://10.0.2.2:8080/api/v1/).
      final response = await client.post(
        'authentication/sign-in',
        data: {'username': username, 'password': password},
      );

      if (response is Map) {
        // 1. Securely save the JWT token in memory
        if (response.containsKey('token')) {
          TokenManager.saveToken(response['token'] as String);
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
      throw ServerException(
        message: 'Authentication failed. Please check your credentials.',
      );
    }
  }

  @override
  Future<int> getNursingHomeId(int administratorId) async {
    try {
      final response = await client.get(
        'administrators/$administratorId/nursing-homes',
      );

      if (response is Map && response.containsKey('id')) {
        final nursingHomeId = (response['id'] as num).toInt();
        TokenManager.saveNursingHomeId(nursingHomeId);
        return nursingHomeId;
      }

      throw ParsingException(
        message: 'Nursing Home data could not be parsed from the response.',
      );
    } catch (e) {
      // Lanzamos la excepción real con código 404 para que la capa de presentación
      // pueda redirigir a la pantalla de "Requiere Configuración Web".
      throw ServerException(
        message:
            'No se encontró una Casa de Reposo asignada. Requiere configuración inicial.',
        statusCode: 404,
      );
    }
  }

  @override
  Future<int> getStaffNursingHomeId(int staffId) async {
    try {
      final response = await client.get('staff/$staffId/nursing-homes');
      if (response is Map && response['businessProfileId'] is num) {
        return (response['businessProfileId'] as num).toInt();
      }
      throw ParsingException(
        message: 'The staff nursing home could not be parsed.',
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'Failed to find the nursing home assigned to this doctor.',
      );
    }
  }

  @override
  Future<bool> hasPersonProfileForEmail(String email) async {
    try {
      final response = await client.get('person-profiles');
      if (response is! List) return false;

      final normalizedEmail = email.trim().toLowerCase();
      return response.whereType<Map>().any(
        (profile) =>
            profile['emailAddress']?.toString().trim().toLowerCase() ==
            normalizedEmail,
      );
    } on ServerException catch (e) {
      if (e.statusCode == 404) return false;
      rethrow;
    }
  }
}
