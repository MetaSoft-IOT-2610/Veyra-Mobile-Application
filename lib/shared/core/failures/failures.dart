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
  const ServerFailure(super.message, {super.code});
}

/// Errores de validación de reglas de negocio o formularios (HTTP 400)
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Errores de almacenamiento local (SQLite/Hive)
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Errores cuando no hay internet disponible
class NetworkFailure extends Failure {
  const NetworkFailure() : super('No hay conexión a internet.');
}
