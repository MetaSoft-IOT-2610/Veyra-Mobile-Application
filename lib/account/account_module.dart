import 'package:get_it/get_it.dart';
import 'domain/repositories/i_account_repository.dart';
import 'infrastructure/datasources/account_remote_datasource.dart';
import 'infrastructure/repositories/account_repository_impl.dart';
import 'application/queries/get_active_subscription_query.dart';
import 'presentation/bloc/account_bloc.dart';

void initAccountModule(GetIt locator) {
  locator.registerLazySingleton<AccountRemoteDataSource>(
    () => AccountRemoteDataSourceImpl(client: locator()),
  );

  locator.registerLazySingleton<IAccountRepository>(
    () => AccountRepositoryImpl(remoteDataSource: locator()),
  );

  locator.registerLazySingleton(
    () => GetActiveSubscriptionQuery(locator()),
  );

  locator.registerFactory(
    () => AccountBloc(locator()),
  );
}
