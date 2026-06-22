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
            .map(_normalizeRole)
            .where((role) => role.isNotEmpty)
            .toList();
        TokenManager.saveRoles(roles);

        int? entityId;
        if (response['entityId'] != null) {
          entityId = (response['entityId'] as num).toInt();
          if (roles.contains('ROLE_ADMIN')) {
            TokenManager.saveAdministratorId(entityId);
          }
          if (roles.contains('ROLE_DOCTOR')) {
            TokenManager.saveStaffId(entityId);
          }
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

  String _normalizeRole(dynamic value) {
    final rawRole = value is Map
        ? value['name'] ?? value['authority'] ?? value['role'] ?? ''
        : value;
    final role = rawRole.toString().trim().toUpperCase();

    return switch (role) {
      'FAMILIAR' ||
      'FAMILY' ||
      'RELATIVE' ||
      'ROLE_FAMILY' ||
      'ROLE_RELATIVE' => 'ROLE_FAMILIAR',
      'ADMIN' || 'ADMINISTRATOR' || 'ROLE_ADMINISTRATOR' => 'ROLE_ADMIN',
      'DOCTOR' => 'ROLE_DOCTOR',
      _ => role,
    };
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
        final nursingHomeId = (response['businessProfileId'] as num).toInt();
        TokenManager.saveNursingHomeId(nursingHomeId);
        return nursingHomeId;
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
}
