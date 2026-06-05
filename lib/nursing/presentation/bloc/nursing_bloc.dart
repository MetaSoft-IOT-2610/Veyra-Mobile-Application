import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/queries/get_resident_summary_query.dart';
import '../../application/dto/resident_summary_dto.dart';

// EVENTOS
abstract class NursingEvent {}
class LoadResidentSummaryEvent extends NursingEvent {
  final int nursingHomeId;
  LoadResidentSummaryEvent({required this.nursingHomeId});
}

// ESTADOS
abstract class NursingState {}
class NursingInitial extends NursingState {}
class NursingLoading extends NursingState {}
class NursingSummaryLoaded extends NursingState {
  final ResidentSummaryDto summary;
  NursingSummaryLoaded({required this.summary});
}
class NursingError extends NursingState {
  final String message;
  NursingError(this.message);
}

// BLOC
class NursingBloc extends Bloc<NursingEvent, NursingState> {
  final GetResidentSummaryQuery _getResidentSummaryQuery;

  NursingBloc(this._getResidentSummaryQuery) : super(NursingInitial()) {
    on<LoadResidentSummaryEvent>(_onLoadResidentSummary);
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
}