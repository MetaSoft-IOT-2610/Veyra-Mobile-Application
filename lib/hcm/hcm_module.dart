import 'package:get_it/get_it.dart';

import 'application/commands/create_staff_command.dart';
import 'application/queries/get_active_staff_query.dart';
import 'domain/repositories/i_staff_repository.dart';
import 'infrastructure/datasources/staff_remote_datasource.dart';
import 'infrastructure/repositories/staff_repository_impl.dart';
import 'presentation/bloc/staff_bloc.dart';

void initHcmModule(GetIt locator) {
  locator.registerLazySingleton<StaffRemoteDataSource>(
    () => StaffRemoteDataSourceImpl(client: locator()),
  );

  locator.registerLazySingleton<IStaffRepository>(
    () => StaffRepositoryImpl(remoteDataSource: locator()),
  );

  locator.registerLazySingleton(() => GetActiveStaffQuery(locator()));

  locator.registerLazySingleton(() => CreateStaffCommand(locator()));

  locator.registerFactory(() => StaffBloc(locator(), locator(), locator()));
}
