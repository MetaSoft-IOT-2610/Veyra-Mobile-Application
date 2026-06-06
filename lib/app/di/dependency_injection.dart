import 'package:flutter/foundation.dart'; // Importante para kIsWeb y defaultTargetPlatform
import 'package:get_it/get_it.dart';
import '../../shared/application/contracts/i_http_client.dart';
import '../../shared/infrastructure/network/dio_http_client_impl.dart';

// Importamos los barriles de los módulos activos
import '../../analytics/analytics.dart';
import '../../activities/activities.dart';
import '../../nursing/nursing.dart';
import '../../hcm/hcm.dart';

final locator = GetIt.instance;

/// Método principal que se llama en el main.dart antes de runApp()
Future<void> initDependencies() async {

  // 1. Inicializar Shared Kernel (Herramientas core)
  _initSharedKernel();

  // 2. Inicializar Bounded Contexts
  initAnalyticsModule(locator);
  initActivitiesModule(locator);
  initNursingModule(locator);
  initHcmModule(locator);
}

void _initSharedKernel() {
  // Función para determinar la URL base según la plataforma actual
  String getBaseUrl() {
    if (kIsWeb) {
      return 'http://localhost:8080/api/v1/'; // Navegadores web (Chrome, Edge, Safari)
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080/api/v1/';  // Emuladores Android
    } else {
      return 'http://localhost:8080/api/v1/'; // Simuladores iOS o Desktop
    }
  }

  // Registrar el cliente HTTP corporativo apuntando a tu backend de Spring Boot
  locator.registerLazySingleton<IHttpClient>(
    () => DioHttpClientImpl(getBaseUrl()), // Pasamos la URL dinámica
  );

  // Aquí en el futuro registrarás ILocalStorage, IConnectivityService, etc.
}
