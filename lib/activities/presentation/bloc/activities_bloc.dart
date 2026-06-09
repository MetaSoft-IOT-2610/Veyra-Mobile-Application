import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/activity.dart'; // Entidad del dominio
import '../../application/queries/get_today_activities_query.dart';

/// BLoC responsible for managing the state of today's activities.
///
/// It coordinates communication between the Presentation
/// and Application layers.
abstract class ActivitiesEvent {}

class FetchTodayActivitiesEvent extends ActivitiesEvent {
  /// Query used to retrieve today's activities.
  final int nursingHomeId;
  FetchTodayActivitiesEvent({required this.nursingHomeId});
}

// --- ESTADOS ---
abstract class ActivitiesState {}

class ActivitiesInitial extends ActivitiesState {}

class ActivitiesLoading extends ActivitiesState {}

class ActivitiesLoaded extends ActivitiesState {
  final List<Activity> todayActivities;
  ActivitiesLoaded({required this.todayActivities});
}

class ActivitiesError extends ActivitiesState {
  final String message;
  ActivitiesError({required this.message});
}


/// Creates a new BLoC instance.
class ActivitiesBloc extends Bloc<ActivitiesEvent, ActivitiesState> {
  final GetTodayActivitiesQuery _getTodayActivitiesQuery;

  ActivitiesBloc(this._getTodayActivitiesQuery) : super(ActivitiesInitial()) {
    on<FetchTodayActivitiesEvent>(_onFetchTodayActivities);
  }
  /// Handles the retrieval of today's activities.
  ///
  /// Emits:
  /// - [ActivitiesLoading]
  /// - [ActivitiesLoaded]
  /// - [ActivitiesError]
  Future<void> _onFetchTodayActivities(
    FetchTodayActivitiesEvent event,
    Emitter<ActivitiesState> emit,
  ) async {
    emit(ActivitiesLoading());

    final result = await _getTodayActivitiesQuery.execute(event.nursingHomeId);

    result.fold(
      (failure) => emit(ActivitiesError(message: failure.message)),

      (activities) => emit(ActivitiesLoaded(todayActivities: activities)),
    );
  }
}
