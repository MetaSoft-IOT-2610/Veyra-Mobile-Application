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

      if (response is Map) {
        // 1. Securely save the JWT token in memory
        if (response.containsKey('token')) {
          TokenManager.saveToken(response['token'] as String);
          print('[IAM] Token saved successfully.');
        }

        // 2. Extract the User ID and map it to the Administrator ID
        if (response.containsKey('id')) {
          final int userId = (response['id'] as num).toInt();

          // TEMPORARY WORKAROUND (MOCK MAPPING)
          // The backend currently returns the User ID instead of the Administrator ID.
          // This mapping forces the correct Administrator ID to unblock frontend development.
          // TODO: Remove this mapping once the backend DTO includes 'administratorId'.
          if (userId == 2 && username == 'Renzo1') {
            print('[IAM] Applying mock mapping: User 2 -> Admin 1');
            return 1; // Real Administrator ID matching the database
          }

          return userId;
        }
      }
      throw ParsingException(message: 'Missing required auth fields in server response.');
    } catch (e) {
      print('[IAM] Error in authenticate: $e');
      throw ServerException(message: 'Authentication failed. Please check your credentials.');
    }
  }

  @override
  Future<int> getNursingHomeId(int administratorId) async {
    try {
      print('[IAM] Requesting nursing home for admin ID: $administratorId');

      // FIX: Removed '/api/v1/' to prevent URL duplication.
      final response = await client.get('administrators/$administratorId/nursing-homes');

      // Defensive parsing to extract the Nursing Home ID
      if (response is Map && response.containsKey('id')) {
        return (response['id'] as num).toInt();
      }

      throw ParsingException(message: 'Nursing Home data could not be parsed from the response.');
    } catch (e) {
      print('[IAM] Error in getNursingHomeId: $e');
      throw ServerException(message: 'Error fetching Nursing Home details: $e');
    }
  }
}
