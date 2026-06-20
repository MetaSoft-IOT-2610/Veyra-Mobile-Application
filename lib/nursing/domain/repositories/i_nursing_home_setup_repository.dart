import '../../../shared/core/failures/failures.dart';
import '../../../shared/core/result/result.dart';
import '../entities/nursing_home.dart';

abstract class INursingHomeSetupRepository {
  Future<Result<Failure, NursingHome>> createNursingHome({
    required int administratorId,
    required String businessName,
    required String emailAddress,
    required String phoneNumber,
    required String street,
    required String number,
    required String city,
    required String postalCode,
    required String country,
    required String ruc,
  });
}
