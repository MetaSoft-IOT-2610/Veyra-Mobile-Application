import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/commands/login_command.dart';
import '../../application/commands/sign_up_command.dart';
import '../../domain/entities/auth_session.dart';

/// Events processed by the [AuthBloc].
abstract class AuthEvent {}

/// Event triggered when the user attempts to sign in.
class PerformLoginEvent extends AuthEvent {
  final String username;
  final String password;
  PerformLoginEvent(this.username, this.password);
}

/// Event triggered when the user creates a new account.
class PerformSignUpEvent extends AuthEvent {
  final String username;
  final String password;
  final String confirmPassword;

  PerformSignUpEvent({
    required this.username,
    required this.password,
    required this.confirmPassword,
  });
}

class PerformAdministratorSignUpEvent extends AuthEvent {
  final String username;
  final String password;
  final String confirmPassword;

  PerformAdministratorSignUpEvent({
    required this.username,
    required this.password,
    required this.confirmPassword,
  });
}

/// States emitted by the [AuthBloc].
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSignUpSuccess extends AuthState {}

class AuthAdministratorSignUpSuccess extends AuthState {
  final int administratorId;

  AuthAdministratorSignUpSuccess(this.administratorId);
}

/// State emitted when authentication is successful.
class AuthSuccess extends AuthState {
  final AuthSession session;
  AuthSuccess(this.session);
}

/// State emitted when authentication fails.
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

/// Business Logic Component managing the Authentication state.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginCommand _loginCommand;
  final SignUpCommand _signUpCommand;

  AuthBloc(this._loginCommand, this._signUpCommand) : super(AuthInitial()) {
    on<PerformLoginEvent>((event, emit) async {
      emit(AuthLoading());

      final result = await _loginCommand.execute(
        event.username,
        event.password,
      );

      result.fold(
        (failure) => emit(AuthError(failure.message)),
        (session) => emit(AuthSuccess(session)),
      );
    });

    on<PerformSignUpEvent>((event, emit) async {
      emit(AuthLoading());

      final result = await _signUpCommand.execute(
        username: event.username,
        password: event.password,
        confirmPassword: event.confirmPassword,
      );

      result.fold(
        (failure) => emit(AuthError(failure.message)),
        (_) => emit(AuthSignUpSuccess()),
      );
    });

    on<PerformAdministratorSignUpEvent>((event, emit) async {
      emit(AuthLoading());

      final result = await _signUpCommand.executeAdministrator(
        username: event.username,
        password: event.password,
        confirmPassword: event.confirmPassword,
      );

      result.fold(
        (failure) => emit(AuthError(failure.message)),
        (administratorId) =>
            emit(AuthAdministratorSignUpSuccess(administratorId)),
      );
    });
  }
}
