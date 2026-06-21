import 'package:get_it/get_it.dart';

import 'application/commands/register_doctor_allergy_command.dart';
import 'application/commands/register_doctor_medical_condition_command.dart';
import 'application/queries/get_doctor_residents_query.dart';
import 'application/queries/get_resident_clinical_record_query.dart';
import 'presentation/bloc/doctor_bloc.dart';
import 'presentation/bloc/doctor_clinical_bloc.dart';

void initDoctorModule(GetIt locator) {
  locator.registerLazySingleton(() => GetDoctorResidentsQuery(locator()));
  locator.registerLazySingleton(
    () => GetResidentClinicalRecordQuery(locator()),
  );
  locator.registerLazySingleton(
    () => RegisterDoctorAllergyCommand(locator()),
  );
  locator.registerLazySingleton(
    () => RegisterDoctorMedicalConditionCommand(locator()),
  );
  locator.registerFactory(() => DoctorBloc(locator()));
  locator.registerFactory(
    () => DoctorClinicalBloc(locator(), locator(), locator()),
  );
}
