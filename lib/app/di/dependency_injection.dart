import 'package:get_it/get_it.dart';
import '../../shared/application/contracts/i_http_client.dart';
import '../../shared/infrastructure/network/dio_http_client_impl.dart';
// import '../../analytics/analytics_module.dart';
// import '../../nursing/nursing_module.dart';

final locator = GetIt.instance;

/// Método principal que se llama en el main.dart antes de runApp()
Future<void> initDependencies() async {
  
  // 1. Inicializar Shared Kernel (Herramientas core)
  _initSharedKernel();

  // 2. Inicializar Bounded Contexts (De forma aislada)
  // initIamModule(locator);
  // initNursingModule(locator);
  // initAnalyticsModule(locator);
}

void _initSharedKernel() {
  // Configuración de Dio con interceptores de Auth y Logging
  // final dio = Dio(BaseOptions(baseUrl: 'https://api.tudominio.com'));
  
  // Registrar el cliente HTTP corporativo
  locator.registerLazySingleton<IHttpClient>(
    () => DioHttpClientImpl(), // O la implementación que pases con Dio
  );
  
  // Aquí también se registrarían servicios como IAnalyticsTracker, ILocalStorage, etc.
}