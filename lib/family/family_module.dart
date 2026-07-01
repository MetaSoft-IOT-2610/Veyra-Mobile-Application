import 'package:get_it/get_it.dart';

import 'application/queries/get_family_portal_query.dart';
import 'domain/repositories/i_family_portal_repository.dart';
import 'infrastructure/datasources/family_portal_remote_datasource.dart';
import 'infrastructure/repositories/family_portal_repository_impl.dart';
import 'presentation/bloc/family_portal_bloc.dart';

void initFamilyModule(GetIt locator) {
  locator.registerLazySingleton<FamilyPortalRemoteDataSource>(
    () => FamilyPortalRemoteDataSourceImpl(client: locator()),
  );
  locator.registerLazySingleton<IFamilyPortalRepository>(
    () => FamilyPortalRepositoryImpl(remoteDataSource: locator()),
  );
  locator.registerLazySingleton(() => GetFamilyPortalQuery(locator()));
  locator.registerFactory(() => FamilyPortalBloc(locator(), locator()));
}
