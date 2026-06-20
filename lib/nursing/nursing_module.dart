import 'package:get_it/get_it.dart';
import 'domain/repositories/i_nursing_repository.dart';
import 'domain/repositories/i_nursing_home_setup_repository.dart';
import 'infrastructure/datasources/nursing_home_setup_remote_datasource.dart';
import 'infrastructure/datasources/nursing_remote_datasource.dart';
import 'infrastructure/repositories/nursing_home_setup_repository_impl.dart';
import 'infrastructure/repositories/nursing_repository_impl.dart';
import 'application/commands/create_nursing_home_command.dart';
import 'application/queries/get_resident_summary_query.dart';
import 'application/queries/get_resident_list_query.dart';
import 'presentation/bloc/nursing_home_setup_bloc.dart';
import 'presentation/bloc/nursing_bloc.dart';

void initNursingModule(GetIt locator) {
  // 1. Data Sources
  locator.registerLazySingleton<NursingRemoteDataSource>(
    () => NursingRemoteDataSourceImpl(client: locator()),
  );
  locator.registerLazySingleton<NursingHomeSetupRemoteDataSource>(
    () => NursingHomeSetupRemoteDataSourceImpl(client: locator()),
  );

  // 2. Repositories
  locator.registerLazySingleton<INursingRepository>(
    () => NursingRepositoryImpl(remoteDataSource: locator()),
  );
  locator.registerLazySingleton<INursingHomeSetupRepository>(
    () => NursingHomeSetupRepositoryImpl(remoteDataSource: locator()),
  );

  // 3. Use Cases / Queries
  locator.registerLazySingleton(() => GetResidentSummaryQuery(locator()));
  locator.registerLazySingleton(() => GetResidentListQuery(locator()));
  locator.registerLazySingleton(() => CreateNursingHomeCommand(locator()));

  // 4. BLoCs (Siempre como Factory)
  locator.registerFactory(
    // Ahora pasamos los dos casos de uso al BLoC
    () => NursingBloc(locator(), locator()),
  );
  locator.registerFactory(() => NursingHomeSetupBloc(locator()));
}
