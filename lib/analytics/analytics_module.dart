import 'package:get_it/get_it.dart';
import 'domain/repositories/i_analytics_repository.dart';
import 'infrastructure/repositories/analytics_repository_impl.dart';
import 'infrastructure/datasources/analytics_remote_datasource.dart';
import 'application/queries/get_operational_metrics_query.dart';
import 'presentation/bloc/analytics_bloc.dart';

void initAnalyticsModule(GetIt locator) {
  locator.registerLazySingleton<AnalyticsRemoteDataSource>(
    () => AnalyticsRemoteDataSourceImpl(client: locator()), 
  );

  locator.registerLazySingleton<IAnalyticsRepository>(
    () => AnalyticsRepositoryImpl(remoteDataSource: locator()),
  );

  locator.registerLazySingleton(
    () => GetOperationalMetricsQuery(locator()),
  );

  locator.registerFactory(
    () => AnalyticsBloc(locator()),
  );
}