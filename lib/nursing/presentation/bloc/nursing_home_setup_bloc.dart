import 'package:flutter_bloc/flutter_bloc.dart';

import '../../application/commands/create_nursing_home_command.dart';
import '../../domain/entities/nursing_home.dart';

abstract class NursingHomeSetupEvent {}

class CreateNursingHomeEvent extends NursingHomeSetupEvent {
  final int administratorId;
  final String businessName;
  final String emailAddress;
  final String phoneNumber;
  final String street;
  final String number;
  final String city;
  final String postalCode;
  final String country;
  final String ruc;

  CreateNursingHomeEvent({
    required this.administratorId,
    required this.businessName,
    required this.emailAddress,
    required this.phoneNumber,
    required this.street,
    required this.number,
    required this.city,
    required this.postalCode,
    required this.country,
    required this.ruc,
  });
}

abstract class NursingHomeSetupState {}

class NursingHomeSetupInitial extends NursingHomeSetupState {}

class NursingHomeSetupLoading extends NursingHomeSetupState {}

class NursingHomeSetupCreated extends NursingHomeSetupState {
  final NursingHome nursingHome;

  NursingHomeSetupCreated(this.nursingHome);
}

class NursingHomeSetupError extends NursingHomeSetupState {
  final String message;

  NursingHomeSetupError(this.message);
}

class NursingHomeSetupBloc
    extends Bloc<NursingHomeSetupEvent, NursingHomeSetupState> {
  final CreateNursingHomeCommand _createNursingHomeCommand;

  NursingHomeSetupBloc(this._createNursingHomeCommand)
    : super(NursingHomeSetupInitial()) {
    on<CreateNursingHomeEvent>((event, emit) async {
      emit(NursingHomeSetupLoading());

      final result = await _createNursingHomeCommand.execute(
        administratorId: event.administratorId,
        businessName: event.businessName,
        emailAddress: event.emailAddress,
        phoneNumber: event.phoneNumber,
        street: event.street,
        number: event.number,
        city: event.city,
        postalCode: event.postalCode,
        country: event.country,
        ruc: event.ruc,
      );

      result.fold(
        (failure) => emit(NursingHomeSetupError(failure.message)),
        (nursingHome) => emit(NursingHomeSetupCreated(nursingHome)),
      );
    });
  }
}
