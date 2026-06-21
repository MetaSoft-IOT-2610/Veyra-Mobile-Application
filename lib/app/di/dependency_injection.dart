import 'package:get_it/get_it.dart';
import '../../shared/application/contracts/i_http_client.dart';
import '../../shared/infrastructure/network/dio_http_client_impl.dart';

// Import the active module barrels
import '../../account/account.dart';
import '../../analytics/analytics.dart';
import '../../activities/activities.dart';
import '../../nursing/nursing.dart';
import '../../hcm/hcm.dart';
import '../../iam/iam.dart';
import '../../profiles/profiles.dart';
import '../../family/family.dart';
import '../../doctor/doctor.dart';

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
  initIamModule(locator);
  initAccountModule(locator);
  initProfilesModule(locator);
  initFamilyModule(locator);
  initDoctorModule(locator);
}

/// Initializes core services like the HTTP Client
void _initSharedKernel() {
  const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue:
        'https://veyra-backend-production-f22c.up.railway.app/api/v1/',
  );

  // Register the corporate HTTP client pointing to the Spring Boot backend
  locator.registerLazySingleton<IHttpClient>(
    () => DioHttpClientImpl(baseUrl),
  );
}
