import '../../../shared/domain/entities/entity.dart';

class Subscription extends Entity<int> {
  final String plan;
  final String status;
  final String startDate;
  final String endDate;

  const Subscription({
    required super.id,
    required this.plan,
    required this.status,
    required this.startDate,
    required this.endDate,
  });

  bool get isActive => status.toUpperCase() == 'ACTIVE';
}
