import '../../domain/entities/subscription.dart';

class SubscriptionModel {
  final int id;
  final String plan;
  final String status;
  final String startDate;
  final String endDate;

  const SubscriptionModel({
    required this.id,
    required this.plan,
    required this.status,
    required this.startDate,
    required this.endDate,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: (json['id'] as num? ?? 0).toInt(),
      plan: json['plan'] as String?
          ?? json['planName'] as String?
          ?? 'N/A',
      status: json['status'] as String? ?? 'UNKNOWN',
      startDate: json['startDate'] as String?
          ?? json['start_date'] as String?
          ?? '',
      endDate: json['endDate'] as String?
          ?? json['end_date'] as String?
          ?? '',
    );
  }

  Subscription toEntity() => Subscription(
        id: id,
        plan: plan,
        status: status,
        startDate: startDate,
        endDate: endDate,
      );
}
