abstract class AnalyticsEvent {}

class LoadOperationalMetricsEvent extends AnalyticsEvent {
  final int nursingHomeId;
  LoadOperationalMetricsEvent({required this.nursingHomeId});
}
