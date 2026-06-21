import '../../core/failures/failures.dart';
import '../../core/result/result.dart';

/// Interfaz base para Casos de Uso que ejecutan acciones (Commands o Queries).
/// [Type] es el tipo de dato que devuelve en caso de éxito.
/// [Params] es la clase que empaqueta los parámetros de entrada.
abstract class UseCase<Output, Params> {
  Future<Result<Failure, Output>> execute(Params params);
}

/// Clase utilitaria para Casos de Uso que NO requieren parámetros de entrada.
class NoParams {
  const NoParams();
}
