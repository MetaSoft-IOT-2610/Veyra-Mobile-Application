import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/activity.dart'; // Entidad del dominio
import '../../application/queries/get_today_activities_query.dart';

// --- EVENTOS ---
abstract class ActivitiesEvent {}

class FetchTodayActivitiesEvent extends ActivitiesEvent {
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

// --- BLOC ---
class ActivitiesBloc extends Bloc<ActivitiesEvent, ActivitiesState> {
  final GetTodayActivitiesQuery _getTodayActivitiesQuery;

  ActivitiesBloc(this._getTodayActivitiesQuery) : super(ActivitiesInitial()) {
    on<FetchTodayActivitiesEvent>(_onFetchTodayActivities);
  }

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