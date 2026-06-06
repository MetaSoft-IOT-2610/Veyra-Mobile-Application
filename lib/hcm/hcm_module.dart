import 'package:get_it/get_it.dart';
import 'domain/repositories/i_staff_repository.dart';
import 'infrastructure/datasources/staff_remote_datasource.dart';
import 'infrastructure/repositories/staff_repository_impl.dart';
import 'application/queries/get_active_staff_query.dart';
import 'presentation/bloc/staff_bloc.dart';

void initHcmModule(GetIt locator) {
  // 1. Data Sources
  locator.registerLazySingleton<StaffRemoteDataSource>(
        () => StaffRemoteDataSourceImpl(client: locator()),
  );

  // 2. Repositories
  locator.registerLazySingleton<IStaffRepository>(
        () => StaffRepositoryImpl(remoteDataSource: locator()),
  );

  // 3. Use Cases / Queries
  locator.registerLazySingleton(
        () => GetActiveStaffQuery(locator()),
  );

  // 4. BLoCs
  locator.registerFactory(
        () => StaffBloc(locator()),
  );
}
