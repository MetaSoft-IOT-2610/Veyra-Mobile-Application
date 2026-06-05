/// Clase base para todos los fallos manejados en el sistema.
abstract class Failure {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  @override
  String toString() => 'Failure(message: $message, code: $code)';
}

/// Errores provenientes del backend (HTTP 500, 404, etc.)
class ServerFailure extends Failure {
  const ServerFailure(String message, {String? code}) : super(message, code: code);
}

/// Errores de validación de reglas de negocio o formularios (HTTP 400)
class ValidationFailure extends Failure {
  const ValidationFailure(String message) : super(message);
}

/// Errores de almacenamiento local (SQLite/Hive)
class CacheFailure extends Failure {
  const CacheFailure(String message) : super(message);
}

/// Errores cuando no hay internet disponible
class NetworkFailure extends Failure {
  const NetworkFailure() : super('No hay conexión a internet.');
}