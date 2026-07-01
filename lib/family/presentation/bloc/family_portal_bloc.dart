import 'package:flutter_bloc/flutter_bloc.dart';

import '../../application/queries/get_family_portal_query.dart';
import '../../domain/entities/family_portal_data.dart';
import '../../domain/repositories/i_family_portal_repository.dart';

abstract class FamilyPortalEvent {}

class LoadFamilyPortalEvent extends FamilyPortalEvent {
  final int userId;

  LoadFamilyPortalEvent(this.userId);
}

abstract class FamilyPortalState {}

class FamilyPortalInitial extends FamilyPortalState {}

class FamilyPortalLoading extends FamilyPortalState {}

class FamilyPortalLoaded extends FamilyPortalState {
  final FamilyPortalData data;

  FamilyPortalLoaded(this.data);
}

class FamilyPortalUnlinked extends FamilyPortalState {
  final String message;

  FamilyPortalUnlinked(this.message);
}

class FamilyPortalError extends FamilyPortalState {
  final String message;

  FamilyPortalError(this.message);
}
class PollMeasurementsEvent extends FamilyPortalEvent {}

class FamilyPortalBloc extends Bloc<FamilyPortalEvent, FamilyPortalState> {
  final GetFamilyPortalQuery _query;
  final IFamilyPortalRepository _repository;

  FamilyPortalBloc(this._query, this._repository) : super(FamilyPortalInitial()) {

    on<LoadFamilyPortalEvent>((event, emit) async {
      emit(FamilyPortalLoading());
      final result = await _query.execute(event.userId);
      result.fold(
            (failure) => failure.code == '404'
            ? emit(FamilyPortalUnlinked(failure.message))
            : emit(FamilyPortalError(failure.message)),
            (data) => emit(FamilyPortalLoaded(data)),
      );
    });
    on<PollMeasurementsEvent>((event, emit) async {
      if (state is FamilyPortalLoaded) {
        final currentState = state as FamilyPortalLoaded;
        final currentData = currentState.data;

        final deviceIds = currentData.devices.map((d) => d.id).toList();
        if (deviceIds.isEmpty) return;

        final result = await _repository.getMeasurementsOnly(deviceIds);

        await result.fold(
              (failure) async {
          },
              (newMeasurements) async {
            final updatedData = FamilyPortalData(
              relative: currentData.relative,
              resident: currentData.resident,
              residentProfile: currentData.residentProfile,
              allergies: currentData.allergies,
              medications: currentData.medications,
              devices: currentData.devices,
              activities: currentData.activities,
              measurements: newMeasurements,
            );

            emit(FamilyPortalLoaded(updatedData));
          },
        );
      }
    });
  }
}
