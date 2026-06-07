import '../../../shared/application/contracts/i_http_client.dart';
import '../../../shared/core/exceptions/exceptions.dart';
import '../../../shared/infrastructure/local/token_manager.dart';

/// Remote data source responsible for IAM network requests.
abstract class IamRemoteDataSource {
  /// Authenticates the user and returns their Administrator ID.
  Future<int> authenticate(String username, String password);

  /// Retrieves the Nursing Home ID associated with the [administratorId].
  Future<int> getNursingHomeId(int administratorId);
}

/// Implementation of [IamRemoteDataSource] using the corporate HTTP client.
class IamRemoteDataSourceImpl implements IamRemoteDataSource {
  final IHttpClient client;

  IamRemoteDataSourceImpl({required this.client});

  @override
  Future<int> authenticate(String username, String password) async {
    try {
      final response = await client.post('/api/v1/auth/sign-in', data: {
        'username': username,
        'password': password,
      });

      if (response is Map) {
        // Extract and save the JWT token globally
        if (response.containsKey('token')) {
          TokenManager.saveToken(response['token'] as String);
        }

        // Extract the Administrator ID securely
        if (response.containsKey('administratorId')) {
          return (response['administratorId'] as num).toInt();
        } else if (response.containsKey('id')) {
          return (response['id'] as num).toInt();
        }
      }
      throw ParsingException(message: 'Missing required auth fields in server response.');
    } catch (e) {
      throw ServerException(message: 'Authentication failed. Please check your credentials.');
    }
  }

  @override
  Future<int> getNursingHomeId(int administratorId) async {
    try {
      final response = await client.get('/api/v1/administrators/$administratorId/nursing-homes');

      // Defensive parsing based on your provided Swagger documentation
      if (response is Map && response.containsKey('id')) {
        return (response['id'] as num).toInt();
      }

      throw ParsingException(message: 'Nursing Home data could not be parsed.');
    } catch (e) {
      throw ServerException(message: 'Error fetching Nursing Home details: $e');
    }
  }
}
