import 'package:get_it/get_it.dart';
import 'domain/repositories/i_nursing_repository.dart';
import 'infrastructure/datasources/nursing_remote_datasource.dart';
import 'infrastructure/repositories/nursing_repository_impl.dart';
import 'application/commands/create_relative_command.dart';
import 'application/commands/create_resident_command.dart';
import 'application/queries/get_family_users_query.dart';
import 'application/queries/get_resident_relatives_query.dart';
import 'application/queries/get_resident_summary_query.dart';
import 'application/queries/get_resident_list_query.dart';
import 'presentation/bloc/nursing_bloc.dart';

void initNursingModule(GetIt locator) {
  // 1. Data Sources
  locator.registerLazySingleton<NursingRemoteDataSource>(
    () => NursingRemoteDataSourceImpl(client: locator()),
  );
  // 2. Repositories
  locator.registerLazySingleton<INursingRepository>(
    () => NursingRepositoryImpl(remoteDataSource: locator()),
  );
  // 3. Use Cases / Queries
  locator.registerLazySingleton(() => GetResidentSummaryQuery(locator()));
  locator.registerLazySingleton(() => GetResidentListQuery(locator()));
  locator.registerLazySingleton(() => GetFamilyUsersQuery(locator()));
  locator.registerLazySingleton(() => GetResidentRelativesQuery(locator()));
  locator.registerLazySingleton(() => CreateResidentCommand(locator()));
  locator.registerLazySingleton(() => CreateRelativeCommand(locator()));

  // 4. BLoCs (Siempre como Factory)
  locator.registerFactory(
    () => NursingBloc(
      locator(),
      locator(),
      locator(),
      locator(),
      locator(),
      locator(),
      locator(),
    ),
  );
}
