import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../nursing/domain/entities/resident.dart';
import '../../application/queries/get_doctor_residents_query.dart';

abstract class DoctorEvent {}

class LoadDoctorResidentsEvent extends DoctorEvent {
  final int nursingHomeId;

  LoadDoctorResidentsEvent(this.nursingHomeId);
}

abstract class DoctorState {}

class DoctorInitial extends DoctorState {}

class DoctorLoading extends DoctorState {}

class DoctorResidentsLoaded extends DoctorState {
  final List<Resident> residents;

  DoctorResidentsLoaded(this.residents);
}

class DoctorError extends DoctorState {
  final String message;

  DoctorError(this.message);
}

class DoctorBloc extends Bloc<DoctorEvent, DoctorState> {
  final GetDoctorResidentsQuery _query;

  DoctorBloc(this._query) : super(DoctorInitial()) {
    on<LoadDoctorResidentsEvent>((event, emit) async {
      emit(DoctorLoading());
      final result = await _query.execute(event.nursingHomeId);
      result.fold(
        (failure) => emit(DoctorError(failure.message)),
        (residents) => emit(DoctorResidentsLoaded(residents)),
      );
    });
  }
}
