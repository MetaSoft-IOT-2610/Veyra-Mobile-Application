import 'package:get_it/get_it.dart';

import 'application/commands/create_person_profile_command.dart';
import 'domain/repositories/i_person_profile_repository.dart';
import 'infrastructure/datasources/person_profile_remote_datasource.dart';
import 'infrastructure/repositories/person_profile_repository_impl.dart';
import 'presentation/bloc/person_profile_bloc.dart';

void initProfilesModule(GetIt locator) {
  locator.registerLazySingleton<PersonProfileRemoteDataSource>(
    () => PersonProfileRemoteDataSourceImpl(client: locator()),
  );

  locator.registerLazySingleton<IPersonProfileRepository>(
    () => PersonProfileRepositoryImpl(remoteDataSource: locator()),
  );

  locator.registerLazySingleton(() => CreatePersonProfileCommand(locator()));

  locator.registerFactory(() => PersonProfileBloc(locator()));
}
