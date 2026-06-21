import 'package:flutter_bloc/flutter_bloc.dart';

import '../../application/commands/create_activity_command.dart';
import '../../application/queries/get_today_activities_query.dart';
import '../../domain/entities/activity.dart';
import '../../domain/repositories/i_activities_repository.dart';

abstract class ActivitiesEvent {}

class FetchTodayActivitiesEvent extends ActivitiesEvent {
  final int nursingHomeId;

  FetchTodayActivitiesEvent({required this.nursingHomeId});
}

class CreateActivityEvent extends ActivitiesEvent {
  final int nursingHomeId;
  final int residentId;
  final int healthcareStaffId;
  final String type;
  final String title;
  final bool isRecurring;
  final List<String> recurringDays;

  CreateActivityEvent({
    required this.nursingHomeId,
    required this.residentId,
    required this.healthcareStaffId,
    required this.type,
    required this.title,
    required this.isRecurring,
    required this.recurringDays,
  });
}

class AdvanceActivityStatusEvent extends ActivitiesEvent {
  final int nursingHomeId;
  final int activityId;

  AdvanceActivityStatusEvent({
    required this.nursingHomeId,
    required this.activityId,
  });
}

class DeleteActivityEvent extends ActivitiesEvent {
  final int nursingHomeId;
  final int activityId;

  DeleteActivityEvent({required this.nursingHomeId, required this.activityId});
}

abstract class ActivitiesState {}

class ActivitiesInitial extends ActivitiesState {}

class ActivitiesLoading extends ActivitiesState {}

class ActivitiesLoaded extends ActivitiesState {
  final List<Activity> todayActivities;
  final String? message;

  ActivitiesLoaded({required this.todayActivities, this.message});
}

class ActivitiesActionInProgress extends ActivitiesState {
  final List<Activity> todayActivities;

  ActivitiesActionInProgress({required this.todayActivities});
}

class ActivitiesError extends ActivitiesState {
  final String message;

  ActivitiesError({required this.message});
}

class ActivitiesBloc extends Bloc<ActivitiesEvent, ActivitiesState> {
  final GetTodayActivitiesQuery _getTodayActivitiesQuery;
  final CreateActivityCommand _createActivityCommand;
  final IActivitiesRepository _repository;

  ActivitiesBloc(
    this._getTodayActivitiesQuery,
    this._createActivityCommand,
    this._repository,
  ) : super(ActivitiesInitial()) {
    on<FetchTodayActivitiesEvent>(_onFetchTodayActivities);
    on<CreateActivityEvent>(_onCreateActivity);
    on<AdvanceActivityStatusEvent>(_onAdvanceActivityStatus);
    on<DeleteActivityEvent>(_onDeleteActivity);
  }

  Future<void> _onFetchTodayActivities(
    FetchTodayActivitiesEvent event,
    Emitter<ActivitiesState> emit,
  ) async {
    emit(ActivitiesLoading());
    await _loadActivities(event.nursingHomeId, emit);
  }

  Future<void> _onCreateActivity(
    CreateActivityEvent event,
    Emitter<ActivitiesState> emit,
  ) async {
    final current = _currentActivities;
    emit(ActivitiesActionInProgress(todayActivities: current));

    final result = await _createActivityCommand.execute(
      nursingHomeId: event.nursingHomeId,
      residentId: event.residentId,
      healthcareStaffId: event.healthcareStaffId,
      type: event.type,
      title: event.title,
      isRecurring: event.isRecurring,
      recurringDays: event.recurringDays,
    );

    await result.fold(
      (failure) async => emit(ActivitiesError(message: failure.message)),
      (_) async => _loadActivities(
        event.nursingHomeId,
        emit,
        message: 'Activity created.',
      ),
    );
  }

  Future<void> _onAdvanceActivityStatus(
    AdvanceActivityStatusEvent event,
    Emitter<ActivitiesState> emit,
  ) async {
    final current = _currentActivities;
    emit(ActivitiesActionInProgress(todayActivities: current));

    final result = await _repository.advanceActivityStatus(event.activityId);
    await result.fold(
      (failure) async => emit(ActivitiesError(message: failure.message)),
      (_) async => _loadActivities(
        event.nursingHomeId,
        emit,
        message: 'Activity status updated.',
      ),
    );
  }

  Future<void> _onDeleteActivity(
    DeleteActivityEvent event,
    Emitter<ActivitiesState> emit,
  ) async {
    final current = _currentActivities;
    emit(ActivitiesActionInProgress(todayActivities: current));

    final result = await _repository.deleteActivity(event.activityId);
    await result.fold(
      (failure) async => emit(ActivitiesError(message: failure.message)),
      (_) async => _loadActivities(
        event.nursingHomeId,
        emit,
        message: 'Activity deleted.',
      ),
    );
  }

  Future<void> _loadActivities(
    int nursingHomeId,
    Emitter<ActivitiesState> emit, {
    String? message,
  }) async {
    final result = await _getTodayActivitiesQuery.execute(nursingHomeId);
    result.fold(
      (failure) => emit(ActivitiesError(message: failure.message)),
      (activities) =>
          emit(ActivitiesLoaded(todayActivities: activities, message: message)),
    );
  }

  List<Activity> get _currentActivities {
    final current = state;
    if (current is ActivitiesLoaded) return current.todayActivities;
    if (current is ActivitiesActionInProgress) return current.todayActivities;
    return const [];
  }
}
