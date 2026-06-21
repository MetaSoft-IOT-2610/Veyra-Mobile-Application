/// Servicio transversal para monitorear el estado de red del dispositivo.
abstract class IConnectivityService {
  /// Devuelve verdadero si el dispositivo tiene acceso activo a internet.
  Future<bool> get isConnected;

  /// Stream para escuchar cambios en tiempo real de la conexión (Online/Offline).
  Stream<bool> get onConnectivityChanged;
}
