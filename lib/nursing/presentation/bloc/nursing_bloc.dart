import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/commands/create_resident_command.dart';
import '../../application/queries/get_resident_summary_query.dart';
import '../../application/queries/get_resident_list_query.dart';
import '../../application/dto/resident_summary_dto.dart';
import '../../domain/entities/resident.dart';
import '../../domain/entities/resident_health_record.dart';
import '../../domain/repositories/i_nursing_repository.dart';

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

class CreateResidentEvent extends NursingEvent {
  final int nursingHomeId;
  final String dni;
  final String firstName;
  final String lastName;
  final DateTime? birthDate;
  final String emailAddress;
  final String street;
  final String number;
  final String city;
  final String postalCode;
  final String country;
  final String phoneNumber;
  final String legalRepresentativeFirstName;
  final String legalRepresentativeLastName;
  final String legalRepresentativePhoneNumber;
  final String emergencyContactFirstName;
  final String emergencyContactLastName;
  final String emergencyContactPhoneNumber;

  CreateResidentEvent({
    required this.nursingHomeId,
    required this.dni,
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    required this.emailAddress,
    required this.street,
    required this.number,
    required this.city,
    required this.postalCode,
    required this.country,
    required this.phoneNumber,
    required this.legalRepresentativeFirstName,
    required this.legalRepresentativeLastName,
    required this.legalRepresentativePhoneNumber,
    required this.emergencyContactFirstName,
    required this.emergencyContactLastName,
    required this.emergencyContactPhoneNumber,
  });
}

class LoadResidentDetailsEvent extends NursingEvent {
  final int residentId;
  LoadResidentDetailsEvent({required this.residentId});
}

class AssignResidentRoomEvent extends NursingEvent {
  final int nursingHomeId;
  final int residentId;
  final String roomNumber;

  AssignResidentRoomEvent({
    required this.nursingHomeId,
    required this.residentId,
    required this.roomNumber,
  });
}

class RegisterResidentAllergyEvent extends NursingEvent {
  final int residentId;
  final String allergenName;
  final String reaction;
  final String typeOfAllergy;
  final String severityLevel;

  RegisterResidentAllergyEvent({
    required this.residentId,
    required this.allergenName,
    required this.reaction,
    required this.typeOfAllergy,
    required this.severityLevel,
  });
}

class RegisterMedicalConditionEvent extends NursingEvent {
  final int residentId;
  final String diagnosisName;
  final DateTime diagnosisDate;
  final String status;
  final String notes;

  RegisterMedicalConditionEvent({
    required this.residentId,
    required this.diagnosisName,
    required this.diagnosisDate,
    required this.status,
    required this.notes,
  });
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

class NursingResidentCreated extends NursingState {
  final Resident resident;
  NursingResidentCreated({required this.resident});
}

class ResidentDetailsLoaded extends NursingState {
  final List<ResidentAllergy> allergies;
  final List<ResidentMedicalCondition> medicalConditions;
  final List<ResidentVitalSign> vitalSigns;

  ResidentDetailsLoaded({
    required this.allergies,
    required this.medicalConditions,
    required this.vitalSigns,
  });
}

class ResidentActionSuccess extends NursingState {
  final String message;
  final Resident? resident;

  ResidentActionSuccess(this.message, {this.resident});
}

class NursingError extends NursingState {
  final String message;
  NursingError(this.message);
}

// BLOC
class NursingBloc extends Bloc<NursingEvent, NursingState> {
  final GetResidentSummaryQuery _getResidentSummaryQuery;
  final GetResidentListQuery _getResidentListQuery;
  final CreateResidentCommand _createResidentCommand;
  final INursingRepository _repository;

  // Inyectamos ambos casos de uso
  NursingBloc(
    this._getResidentSummaryQuery,
    this._getResidentListQuery,
    this._createResidentCommand,
    this._repository,
  ) : super(NursingInitial()) {
    on<LoadResidentSummaryEvent>(_onLoadResidentSummary);
    on<LoadResidentListEvent>(_onLoadResidentList);
    on<CreateResidentEvent>(_onCreateResident);
    on<LoadResidentDetailsEvent>(_onLoadResidentDetails);
    on<AssignResidentRoomEvent>(_onAssignRoom);
    on<RegisterResidentAllergyEvent>(_onRegisterAllergy);
    on<RegisterMedicalConditionEvent>(_onRegisterMedicalCondition);
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

  Future<void> _onCreateResident(
    CreateResidentEvent event,
    Emitter<NursingState> emit,
  ) async {
    emit(NursingLoading());

    final result = await _createResidentCommand.execute(
      nursingHomeId: event.nursingHomeId,
      dni: event.dni,
      firstName: event.firstName,
      lastName: event.lastName,
      birthDate: event.birthDate,
      emailAddress: event.emailAddress,
      street: event.street,
      number: event.number,
      city: event.city,
      postalCode: event.postalCode,
      country: event.country,
      phoneNumber: event.phoneNumber,
      legalRepresentativeFirstName: event.legalRepresentativeFirstName,
      legalRepresentativeLastName: event.legalRepresentativeLastName,
      legalRepresentativePhoneNumber: event.legalRepresentativePhoneNumber,
      emergencyContactFirstName: event.emergencyContactFirstName,
      emergencyContactLastName: event.emergencyContactLastName,
      emergencyContactPhoneNumber: event.emergencyContactPhoneNumber,
    );

    result.fold(
      (failure) => emit(NursingError(failure.message)),
      (resident) => emit(NursingResidentCreated(resident: resident)),
    );
  }

  Future<void> _onLoadResidentDetails(
    LoadResidentDetailsEvent event,
    Emitter<NursingState> emit,
  ) async {
    emit(NursingLoading());
    final allergiesResult = await _repository.getAllergies(event.residentId);
    final conditionsResult = await _repository.getMedicalConditions(
      event.residentId,
    );
    final vitalsResult = await _repository.getVitalSigns(event.residentId);

    String? error;
    List<ResidentAllergy> allergies = [];
    List<ResidentMedicalCondition> conditions = [];
    List<ResidentVitalSign> vitals = [];

    allergiesResult.fold((failure) => error ??= failure.message, (value) {
      allergies = value;
    });
    conditionsResult.fold((failure) => error ??= failure.message, (value) {
      conditions = value;
    });
    vitalsResult.fold((failure) => error ??= failure.message, (value) {
      vitals = value;
    });

    if (error != null) {
      emit(NursingError(error!));
      return;
    }

    emit(
      ResidentDetailsLoaded(
        allergies: allergies,
        medicalConditions: conditions,
        vitalSigns: vitals,
      ),
    );
  }

  Future<void> _onAssignRoom(
    AssignResidentRoomEvent event,
    Emitter<NursingState> emit,
  ) async {
    emit(NursingLoading());
    final result = await _repository.assignRoom(
      nursingHomeId: event.nursingHomeId,
      residentId: event.residentId,
      roomNumber: event.roomNumber.trim(),
    );
    result.fold(
      (failure) => emit(NursingError(failure.message)),
      (resident) => emit(
        ResidentActionSuccess(
          'Room assigned successfully.',
          resident: resident,
        ),
      ),
    );
  }

  Future<void> _onRegisterAllergy(
    RegisterResidentAllergyEvent event,
    Emitter<NursingState> emit,
  ) async {
    emit(NursingLoading());
    final result = await _repository.registerAllergy(
      residentId: event.residentId,
      allergenName: event.allergenName.trim(),
      reaction: event.reaction.trim(),
      typeOfAllergy: event.typeOfAllergy,
      severityLevel: event.severityLevel,
    );
    result.fold(
      (failure) => emit(NursingError(failure.message)),
      (_) => emit(ResidentActionSuccess('Allergy registered successfully.')),
    );
  }

  Future<void> _onRegisterMedicalCondition(
    RegisterMedicalConditionEvent event,
    Emitter<NursingState> emit,
  ) async {
    emit(NursingLoading());
    final result = await _repository.registerMedicalCondition(
      residentId: event.residentId,
      diagnosisName: event.diagnosisName.trim(),
      diagnosisDate: event.diagnosisDate,
      status: event.status,
      notes: event.notes.trim(),
    );
    result.fold(
      (failure) => emit(NursingError(failure.message)),
      (_) => emit(
        ResidentActionSuccess('Medical condition registered successfully.'),
      ),
    );
  }
}
