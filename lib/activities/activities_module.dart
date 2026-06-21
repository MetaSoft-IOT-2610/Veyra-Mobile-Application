import 'package:get_it/get_it.dart';
import 'domain/repositories/i_activities_repository.dart';
import 'infrastructure/datasources/activities_remote_datasource.dart';
import 'infrastructure/repositories/activities_repository_impl.dart';
import 'application/commands/create_activity_command.dart';
import 'application/queries/get_today_activities_query.dart';
import 'presentation/bloc/activities_bloc.dart';

void initActivitiesModule(GetIt locator) {
  // 1. Data Sources
  locator.registerLazySingleton<ActivitiesRemoteDataSource>(
    () => ActivitiesRemoteDataSourceImpl(client: locator()),
  );

  // 2. Repositories
  locator.registerLazySingleton<IActivitiesRepository>(
    () => ActivitiesRepositoryImpl(remoteDataSource: locator()),
  );

  // 3. Use Cases / Queries
  locator.registerLazySingleton(() => GetTodayActivitiesQuery(locator()));

  locator.registerLazySingleton(() => CreateActivityCommand(locator()));

  // 4. BLoCs (Siempre como Factory)
  locator.registerFactory(
    () => ActivitiesBloc(locator(), locator(), locator()),
  );
}
