import '../../../nursing/domain/entities/resident_health_record.dart';
import '../../../nursing/domain/repositories/i_nursing_repository.dart';
import '../../../shared/core/failures/failures.dart';
import '../../../shared/core/result/result.dart';

class RegisterDoctorAllergyCommand {
  final INursingRepository _repository;

  RegisterDoctorAllergyCommand(this._repository);

  Future<Result<Failure, ResidentAllergy>> execute({
    required int residentId,
    required String allergenName,
    required String reaction,
    required String typeOfAllergy,
    required String severityLevel,
  }) {
    if (allergenName.trim().isEmpty || reaction.trim().isEmpty) {
      return Future.value(
        Result.failure(
          const ValidationFailure('Complete allergen and reaction.'),
        ),
      );
    }
    return _repository.registerAllergy(
      residentId: residentId,
      allergenName: allergenName.trim(),
      reaction: reaction.trim(),
      typeOfAllergy: typeOfAllergy,
      severityLevel: severityLevel,
    );
  }
}
