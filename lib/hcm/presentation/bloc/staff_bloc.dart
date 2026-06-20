import 'package:flutter_bloc/flutter_bloc.dart';

import '../../application/commands/create_staff_command.dart';
import '../../application/queries/get_active_staff_query.dart';
import '../../domain/entities/staff_contract.dart';
import '../../domain/entities/staff_member.dart';
import '../../domain/repositories/i_staff_repository.dart';

abstract class StaffEvent {}

class LoadActiveStaffEvent extends StaffEvent {
  final int nursingHomeId;
  LoadActiveStaffEvent(this.nursingHomeId);
}

class CreateStaffEvent extends StaffEvent {
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
  final String emergencyContactFirstName;
  final String emergencyContactLastName;
  final String emergencyContactPhoneNumber;

  CreateStaffEvent({
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
    required this.emergencyContactFirstName,
    required this.emergencyContactLastName,
    required this.emergencyContactPhoneNumber,
  });
}

class LoadStaffContractsEvent extends StaffEvent {
  final int staffMemberId;
  LoadStaffContractsEvent(this.staffMemberId);
}

class AddStaffContractEvent extends StaffEvent {
  final int staffMemberId;
  final DateTime startDate;
  final DateTime endDate;
  final String typeOfContract;
  final String staffRole;
  final String workShift;

  AddStaffContractEvent({
    required this.staffMemberId,
    required this.startDate,
    required this.endDate,
    required this.typeOfContract,
    required this.staffRole,
    required this.workShift,
  });
}

abstract class StaffState {}

class StaffInitial extends StaffState {}

class StaffLoading extends StaffState {}

class StaffLoaded extends StaffState {
  final List<StaffMember> staffMembers;
  StaffLoaded(this.staffMembers);
}

class StaffCreated extends StaffState {
  final StaffMember staffMember;
  StaffCreated(this.staffMember);
}

class StaffContractsLoaded extends StaffState {
  final List<StaffContract> contracts;
  StaffContractsLoaded(this.contracts);
}

class StaffActionSuccess extends StaffState {
  final String message;
  StaffActionSuccess(this.message);
}

class StaffError extends StaffState {
  final String message;
  StaffError(this.message);
}

class StaffBloc extends Bloc<StaffEvent, StaffState> {
  final GetActiveStaffQuery _getActiveStaffQuery;
  final CreateStaffCommand _createStaffCommand;
  final IStaffRepository _repository;

  StaffBloc(
    this._getActiveStaffQuery,
    this._createStaffCommand,
    this._repository,
  ) : super(StaffInitial()) {
    on<LoadActiveStaffEvent>(_onLoadStaff);
    on<CreateStaffEvent>(_onCreateStaff);
    on<LoadStaffContractsEvent>(_onLoadContracts);
    on<AddStaffContractEvent>(_onAddContract);
  }

  Future<void> _onLoadStaff(
    LoadActiveStaffEvent event,
    Emitter<StaffState> emit,
  ) async {
    emit(StaffLoading());
    final result = await _getActiveStaffQuery.execute(event.nursingHomeId);
    result.fold(
      (failure) => emit(StaffError(failure.message)),
      (staff) => emit(StaffLoaded(staff)),
    );
  }

  Future<void> _onCreateStaff(
    CreateStaffEvent event,
    Emitter<StaffState> emit,
  ) async {
    emit(StaffLoading());
    final result = await _createStaffCommand.execute(
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
      emergencyContactFirstName: event.emergencyContactFirstName,
      emergencyContactLastName: event.emergencyContactLastName,
      emergencyContactPhoneNumber: event.emergencyContactPhoneNumber,
    );

    result.fold(
      (failure) => emit(StaffError(failure.message)),
      (staff) => emit(StaffCreated(staff)),
    );
  }

  Future<void> _onLoadContracts(
    LoadStaffContractsEvent event,
    Emitter<StaffState> emit,
  ) async {
    emit(StaffLoading());
    final result = await _repository.getContracts(event.staffMemberId);
    result.fold(
      (failure) => emit(StaffError(failure.message)),
      (contracts) => emit(StaffContractsLoaded(contracts)),
    );
  }

  Future<void> _onAddContract(
    AddStaffContractEvent event,
    Emitter<StaffState> emit,
  ) async {
    emit(StaffLoading());
    final result = await _repository.addContract(
      staffMemberId: event.staffMemberId,
      startDate: event.startDate,
      endDate: event.endDate,
      typeOfContract: event.typeOfContract.trim(),
      staffRole: event.staffRole,
      workShift: event.workShift,
    );
    result.fold(
      (failure) => emit(StaffError(failure.message)),
      (_) => emit(StaffActionSuccess('Contract registered successfully.')),
    );
  }
}
