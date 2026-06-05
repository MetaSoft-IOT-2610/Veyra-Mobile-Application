import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as developer;

/// Observador centralizado para auditoría de flujos de estado reactivos.
class AppBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    developer.log('[BLOC EVENT] -> ${bloc.runtimeType} | Event: $event');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    developer.log(
      '[BLOC TRANSITION] -> ${bloc.runtimeType}\n'
      '   From: ${transition.currentState}\n'
      '   Next: ${transition.nextState}'
    );
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    developer.log('[BLOC CRITICAL ERROR] -> ${bloc.runtimeType} | Error: $error', error: error, stackTrace: stackTrace);
    // Aquí se conectaría el servicio de telemetría corporativo (ej. Sentry/Crashlytics)
  }
}