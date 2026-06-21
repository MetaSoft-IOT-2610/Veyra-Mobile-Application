import '../../../nursing/domain/entities/resident_health_record.dart';
import '../../../nursing/domain/repositories/i_nursing_repository.dart';
import '../../../shared/core/failures/failures.dart';
import '../../../shared/core/result/result.dart';

class RegisterDoctorMedicalConditionCommand {
  final INursingRepository _repository;

  RegisterDoctorMedicalConditionCommand(this._repository);

  Future<Result<Failure, ResidentMedicalCondition>> execute({
    required int residentId,
    required String diagnosisName,
    required DateTime diagnosisDate,
    required String status,
    required String notes,
  }) {
    if (diagnosisName.trim().isEmpty) {
      return Future.value(
        Result.failure(const ValidationFailure('Enter a diagnosis name.')),
      );
    }
    return _repository.registerMedicalCondition(
      residentId: residentId,
      diagnosisName: diagnosisName.trim(),
      diagnosisDate: diagnosisDate,
      status: status,
      notes: notes.trim(),
    );
  }
}
