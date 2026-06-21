import '../../../nursing/domain/entities/resident_health_record.dart';
import '../../../nursing/domain/repositories/i_nursing_repository.dart';
import '../../../shared/core/failures/failures.dart';
import '../../../shared/core/result/result.dart';
import '../../domain/entities/resident_clinical_record.dart';

class GetResidentClinicalRecordQuery {
  final INursingRepository _repository;

  GetResidentClinicalRecordQuery(this._repository);

  Future<Result<Failure, ResidentClinicalRecord>> execute(int residentId) async {
    if (residentId <= 0) {
      return Result.failure(
        const ValidationFailure('A valid resident is required.'),
      );
    }

    final allergyResult = await _repository.getAllergies(residentId);
    final conditionResult = await _repository.getMedicalConditions(residentId);
    final vitalResult = await _repository.getVitalSigns(residentId);

    Failure? failure;
    var allergies = <ResidentAllergy>[];
    var conditions = <ResidentMedicalCondition>[];
    var vitalSigns = <ResidentVitalSign>[];

    allergyResult.fold((value) => failure ??= value, (value) => allergies = value);
    conditionResult.fold(
      (value) => failure ??= value,
      (value) => conditions = value,
    );
    vitalResult.fold((value) => failure ??= value, (value) => vitalSigns = value);

    if (failure != null) return Result.failure(failure!);
    return Result.success(
      ResidentClinicalRecord(
        allergies: allergies,
        medicalConditions: conditions,
        vitalSigns: vitalSigns,
      ),
    );
  }
}
