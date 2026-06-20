import 'package:flutter_bloc/flutter_bloc.dart';

import '../../application/commands/create_person_profile_command.dart';
import '../../domain/entities/person_profile.dart';

abstract class PersonProfileEvent {}

class CreatePersonProfileEvent extends PersonProfileEvent {
  final String dni;
  final String firstName;
  final String lastName;
  final String birthDate;
  final String age;
  final String emailAddress;
  final String street;
  final String number;
  final String city;
  final String postalCode;
  final String country;
  final String phoneNumber;

  CreatePersonProfileEvent({
    required this.dni,
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    required this.age,
    required this.emailAddress,
    required this.street,
    required this.number,
    required this.city,
    required this.postalCode,
    required this.country,
    required this.phoneNumber,
  });
}

abstract class PersonProfileState {}

class PersonProfileInitial extends PersonProfileState {}

class PersonProfileLoading extends PersonProfileState {}

class PersonProfileCreated extends PersonProfileState {
  final PersonProfile profile;

  PersonProfileCreated(this.profile);
}

class PersonProfileError extends PersonProfileState {
  final String message;

  PersonProfileError(this.message);
}

class PersonProfileBloc extends Bloc<PersonProfileEvent, PersonProfileState> {
  final CreatePersonProfileCommand _createPersonProfileCommand;

  PersonProfileBloc(this._createPersonProfileCommand)
    : super(PersonProfileInitial()) {
    on<CreatePersonProfileEvent>((event, emit) async {
      emit(PersonProfileLoading());

      final result = await _createPersonProfileCommand.execute(
        dni: event.dni,
        firstName: event.firstName,
        lastName: event.lastName,
        birthDate: event.birthDate,
        age: event.age,
        emailAddress: event.emailAddress,
        street: event.street,
        number: event.number,
        city: event.city,
        postalCode: event.postalCode,
        country: event.country,
        phoneNumber: event.phoneNumber,
      );

      result.fold(
        (failure) => emit(PersonProfileError(failure.message)),
        (profile) => emit(PersonProfileCreated(profile)),
      );
    });
  }
}
