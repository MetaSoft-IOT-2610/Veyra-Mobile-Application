import '../../../shared/core/failures/failures.dart';
import '../../../shared/core/result/result.dart';
import '../entities/person_profile.dart';

abstract class IPersonProfileRepository {
  Future<Result<Failure, PersonProfile>> createPersonProfile({
    required String dni,
    required String firstName,
    required String lastName,
    required String birthDate,
    required int age,
    required String emailAddress,
    required String street,
    required String number,
    required String city,
    required String postalCode,
    required String country,
    required String phoneNumber,
  });
}
