abstract class AnalyticsState {}

class AnalyticsInitial extends AnalyticsState {}

class AnalyticsLoading extends AnalyticsState {}

class AnalyticsLoaded extends AnalyticsState {
  final int admissionsCount;
  final int terminationsCount;
  final int hiresCount;

  AnalyticsLoaded({
    required this.admissionsCount,
    required this.terminationsCount,
    required this.hiresCount,
  });
}

class AnalyticsError extends AnalyticsState {
  final String message;
  AnalyticsError(this.message);
}