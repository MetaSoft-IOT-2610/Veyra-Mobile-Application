import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/queries/get_resident_summary_query.dart';
import '../../application/queries/get_resident_list_query.dart';
import '../../application/dto/resident_summary_dto.dart';
import '../../domain/entities/resident.dart';

// EVENTS
abstract class NursingEvent {}

class LoadResidentSummaryEvent extends NursingEvent {
  final int nursingHomeId;
  LoadResidentSummaryEvent({required this.nursingHomeId});
}

class LoadResidentListEvent extends NursingEvent {
  final int nursingHomeId;
  LoadResidentListEvent({required this.nursingHomeId});
}

// STATES
abstract class NursingState {}

class NursingInitial extends NursingState {}

class NursingLoading extends NursingState {}

class NursingSummaryLoaded extends NursingState {
  final ResidentSummaryDto summary;
  NursingSummaryLoaded({required this.summary});
}

class NursingListLoaded extends NursingState {
  final List<Resident> residents;
  NursingListLoaded({required this.residents});
}

class NursingError extends NursingState {
  final String message;
  NursingError(this.message);
}

// BLOC
class NursingBloc extends Bloc<NursingEvent, NursingState> {
  final GetResidentSummaryQuery _getResidentSummaryQuery;
  final GetResidentListQuery _getResidentListQuery;

  // Inyectamos ambos casos de uso
  NursingBloc(
      this._getResidentSummaryQuery,
      this._getResidentListQuery,
      ) : super(NursingInitial()) {
    on<LoadResidentSummaryEvent>(_onLoadResidentSummary);
    on<LoadResidentListEvent>(_onLoadResidentList);
  }

  Future<void> _onLoadResidentSummary(
      LoadResidentSummaryEvent event,
      Emitter<NursingState> emit,
      ) async {
    emit(NursingLoading());

    final result = await _getResidentSummaryQuery.execute(event.nursingHomeId);

    result.fold(
          (failure) => emit(NursingError(failure.message)),
          (summary) => emit(NursingSummaryLoaded(summary: summary)),
    );
  }

  Future<void> _onLoadResidentList(
      LoadResidentListEvent event,
      Emitter<NursingState> emit,
      ) async {
    emit(NursingLoading());

    final result = await _getResidentListQuery.execute(event.nursingHomeId);

    result.fold(
          (failure) => emit(NursingError(failure.message)),
          (residents) => emit(NursingListLoaded(residents: residents)),
    );
  }
}
