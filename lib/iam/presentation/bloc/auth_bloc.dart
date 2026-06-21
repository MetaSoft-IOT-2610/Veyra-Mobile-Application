import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/commands/login_command.dart';
import '../../domain/entities/auth_session.dart';

/// Events processed by the [AuthBloc].
abstract class AuthEvent {}

/// Event triggered when the user attempts to sign in.
class PerformLoginEvent extends AuthEvent {
  final String username;
  final String password;
  PerformLoginEvent(this.username, this.password);
}

/// States emitted by the [AuthBloc].
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

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

  AuthBloc(this._loginCommand) : super(AuthInitial()) {
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

  }
}
