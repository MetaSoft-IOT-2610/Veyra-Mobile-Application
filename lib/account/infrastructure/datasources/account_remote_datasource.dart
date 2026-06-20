import '../../../shared/application/contracts/i_http_client.dart';
import '../../../shared/core/exceptions/exceptions.dart';
import '../models/subscription_model.dart';

abstract class AccountRemoteDataSource {
  Future<SubscriptionModel> getActiveSubscription(int userId);

  Future<SubscriptionModel> createSubscription({
    required int userId,
    required String planType,
    required String period,
    required String paymentMethodId,
  });
}

class AccountRemoteDataSourceImpl implements AccountRemoteDataSource {
  final IHttpClient client;

  AccountRemoteDataSourceImpl({required this.client});

  @override
  Future<SubscriptionModel> getActiveSubscription(int userId) async {
    try {
      final response = await client.get('users/$userId/subscriptions/active');
      if (response is Map<String, dynamic>) {
        return SubscriptionModel.fromJson(response);
      }
      throw ParsingException(
        message: 'Unexpected format in subscription response.',
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Failed to fetch subscription: $e');
    }
  }

  @override
  Future<SubscriptionModel> createSubscription({
    required int userId,
    required String planType,
    required String period,
    required String paymentMethodId,
  }) async {
    try {
      final response = await client.post(
        'users/$userId/subscriptions',
        data: {
          'planType': planType,
          'period': period,
          'paymentMethodId': paymentMethodId,
        },
      );

      if (response is Map<String, dynamic>) {
        return SubscriptionModel.fromJson(response);
      }

      throw ParsingException(
        message: 'Unexpected format in subscription creation response.',
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Failed to create subscription: $e');
    }
  }
}
