import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/queries/get_operational_metrics_query.dart';
import 'analytics_event.dart';
import 'analytics_state.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final GetOperationalMetricsQuery _getOperationalMetricsQuery;

  AnalyticsBloc(this._getOperationalMetricsQuery) : super(AnalyticsInitial()) {
    on<LoadOperationalMetricsEvent>(_onLoadOperationalMetrics);
  }

  Future<void> _onLoadOperationalMetrics(
    LoadOperationalMetricsEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(AnalyticsLoading());

    final result = await _getOperationalMetricsQuery.execute(
      event.nursingHomeId,
    );

    result.fold(
      (failure) => emit(AnalyticsError(failure.message)),
      (metrics) => emit(
        AnalyticsLoaded(
          admissionsCount: metrics.admissionsCount,
          terminationsCount: metrics.terminationsCount,
          hiresCount: metrics.hiresCount,
        ),
      ),
    );
  }
}
