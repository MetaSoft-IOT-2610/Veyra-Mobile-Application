import 'package:flutter_bloc/flutter_bloc.dart';

import '../../application/commands/register_doctor_allergy_command.dart';
import '../../application/queries/get_resident_clinical_record_query.dart';
import '../../domain/entities/resident_clinical_record.dart';

abstract class DoctorClinicalEvent {}

class LoadDoctorClinicalRecordEvent extends DoctorClinicalEvent {
  final int residentId;

  LoadDoctorClinicalRecordEvent(this.residentId);
}

class RegisterDoctorAllergyEvent extends DoctorClinicalEvent {
  final int residentId;
  final String allergenName;
  final String reaction;
  final String typeOfAllergy;
  final String severityLevel;

  RegisterDoctorAllergyEvent({
    required this.residentId,
    required this.allergenName,
    required this.reaction,
    required this.typeOfAllergy,
    required this.severityLevel,
  });
}

abstract class DoctorClinicalState {}

class DoctorClinicalInitial extends DoctorClinicalState {}

class DoctorClinicalLoading extends DoctorClinicalState {}

class DoctorClinicalLoaded extends DoctorClinicalState {
  final ResidentClinicalRecord record;
  final String? successMessage;

  DoctorClinicalLoaded(this.record, {this.successMessage});
}

class DoctorClinicalError extends DoctorClinicalState {
  final String message;

  DoctorClinicalError(this.message);
}

class DoctorClinicalBloc
    extends Bloc<DoctorClinicalEvent, DoctorClinicalState> {
  final GetResidentClinicalRecordQuery _getRecord;
  final RegisterDoctorAllergyCommand _registerAllergy;

  DoctorClinicalBloc(this._getRecord, this._registerAllergy)
    : super(DoctorClinicalInitial()) {
    on<LoadDoctorClinicalRecordEvent>((event, emit) async {
      await _load(event.residentId, emit);
    });
    on<RegisterDoctorAllergyEvent>((event, emit) async {
      emit(DoctorClinicalLoading());
      final result = await _registerAllergy.execute(
        residentId: event.residentId,
        allergenName: event.allergenName,
        reaction: event.reaction,
        typeOfAllergy: event.typeOfAllergy,
        severityLevel: event.severityLevel,
      );
      await result.fold(
        (failure) async => emit(DoctorClinicalError(failure.message)),
        (_) => _load(
          event.residentId,
          emit,
          successMessage: 'Allergy registered successfully.',
        ),
      );
    });
  }

  Future<void> _load(
    int residentId,
    Emitter<DoctorClinicalState> emit, {
    String? successMessage,
  }) async {
    if (successMessage == null) emit(DoctorClinicalLoading());
    final result = await _getRecord.execute(residentId);
    result.fold(
      (failure) => emit(DoctorClinicalError(failure.message)),
      (record) =>
          emit(DoctorClinicalLoaded(record, successMessage: successMessage)),
    );
  }
}
