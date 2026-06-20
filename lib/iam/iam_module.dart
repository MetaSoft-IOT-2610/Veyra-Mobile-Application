import 'package:get_it/get_it.dart';
import 'domain/repositories/i_auth_repository.dart';
import 'infrastructure/datasources/iam_remote_datasource.dart';
import 'infrastructure/repositories/auth_repository_impl.dart';
import 'application/commands/login_command.dart';
import 'application/commands/sign_up_command.dart';
import 'presentation/bloc/auth_bloc.dart';

/// Initializes and registers all dependencies for the IAM Bounded Context.
void initIamModule(GetIt locator) {
  // Data Sources
  locator.registerLazySingleton<IamRemoteDataSource>(
    () => IamRemoteDataSourceImpl(client: locator()),
  );

  // Repositories
  locator.registerLazySingleton<IAuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: locator()),
  );

  // Use Cases / Commands
  locator.registerLazySingleton(() => LoginCommand(locator()));
  locator.registerLazySingleton(() => SignUpCommand(locator()));

  // BLoCs
  locator.registerFactory(() => AuthBloc(locator(), locator()));
}
