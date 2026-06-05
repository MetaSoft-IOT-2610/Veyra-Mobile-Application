/// Clase base para el manejo funcional de respuestas.
/// [L] representa el tipo de Error (Left/Failure).
/// [R] representa el tipo de Éxito (Right/Success).
abstract class Result<L, R> {
  const Result();

  /// Permite retornar un estado de error
  factory Result.failure(L failure) = _Failure<L, R>;

  /// Permite retornar un estado de éxito
  factory Result.success(R data) = _Success<L, R>;

  /// Obliga a la capa superior (UI/BLoC) a definir qué hacer en caso de error o éxito.
  T fold<T>(T Function(L failure) onFailure, T Function(R data) onSuccess);

  bool get isSuccess => this is _Success<L, R>;
  bool get isFailure => this is _Failure<L, R>;
}

class _Failure<L, R> extends Result<L, R> {
  final L failure;
  const _Failure(this.failure);

  @override
  T fold<T>(T Function(L failure) onFailure, T Function(R data) onSuccess) {
    return onFailure(failure);
  }
}

class _Success<L, R> extends Result<L, R> {
  final R data;
  const _Success(this.data);

  @override
  T fold<T>(T Function(L failure) onFailure, T Function(R data) onSuccess) {
    return onSuccess(data);
  }
}