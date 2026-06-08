import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import '../../shared/application/contracts/i_http_client.dart';
import '../../shared/infrastructure/network/dio_http_client_impl.dart';

// Import the active module barrels
import '../../analytics/analytics.dart';
import '../../activities/activities.dart';
import '../../nursing/nursing.dart';
import '../../hcm/hcm.dart';
import '../../iam/iam.dart'; // <-- 1. ADDED: IAM import

final locator = GetIt.instance;

/// Main initialization method called in main.dart before runApp()
Future<void> initDependencies() async {
  // 1. Initialize Shared Kernel (Core tools)
  _initSharedKernel();

  // 2. Initialize Bounded Contexts
  initAnalyticsModule(locator);
  initActivitiesModule(locator);
  initNursingModule(locator);
  initHcmModule(locator);

  initIamModule(locator); // <-- 2. ADDED: IAM initialization
}

/// Initializes core services like the HTTP Client
void _initSharedKernel() {
  // Function to determine the base URL based on the current platform
  String getBaseUrl() {
    if (kIsWeb) {
      return 'http://localhost:8080/api/v1/'; // Web browsers (Chrome, Edge, Safari)
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080/api/v1/';  // Android Emulators
    } else {
      return 'http://localhost:8080/api/v1/'; // iOS Simulators or Desktop
    }
  }

  // Register the corporate HTTP client pointing to the Spring Boot backend
  locator.registerLazySingleton<IHttpClient>(
        () => DioHttpClientImpl(getBaseUrl()),
  );
}
