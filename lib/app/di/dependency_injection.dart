import 'package:get_it/get_it.dart';
import '../../shared/application/contracts/i_http_client.dart';
import '../../shared/infrastructure/network/dio_http_client_impl.dart';

// Importamos los barriles de los módulos activos
import '../../analytics/analytics.dart';
import '../../activities/activities.dart';
import '../../nursing/nursing.dart';

final locator = GetIt.instance;

/// Método principal que se llama en el main.dart antes de runApp()
Future<void> initDependencies() async {
  
  // 1. Inicializar Shared Kernel (Herramientas core)
  _initSharedKernel();

  // 2. Inicializar Bounded Contexts
  initAnalyticsModule(locator);
  initActivitiesModule(locator);
  initNursingModule(locator);
}

void _initSharedKernel() {
  // Registrar el cliente HTTP corporativo apuntando a tu backend de Spring Boot
  locator.registerLazySingleton<IHttpClient>(
    () => DioHttpClientImpl('http://localhost:8080/api/v1/'), 
  );
  
  // Aquí en el futuro registrarás ILocalStorage, IConnectivityService, etc.
}