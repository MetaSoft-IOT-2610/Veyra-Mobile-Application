import 'package:get_it/get_it.dart';
import 'domain/repositories/i_nursing_repository.dart';
import 'infrastructure/datasources/nursing_remote_datasource.dart';
import 'infrastructure/repositories/nursing_repository_impl.dart';
import 'application/queries/get_resident_summary_query.dart';
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
  locator.registerLazySingleton(
    () => GetResidentSummaryQuery(locator()),
  );

  // 4. BLoCs (Siempre como Factory)
  locator.registerFactory(
    () => NursingBloc(locator()),
  );
}