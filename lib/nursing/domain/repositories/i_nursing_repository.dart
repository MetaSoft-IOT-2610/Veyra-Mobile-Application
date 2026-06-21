import 'package:veyra_mobile_app/nursing/domain/entities/resident.dart';

import '../../../shared/core/result/result.dart';
import '../../../shared/core/failures/failures.dart';
import '../entities/relative.dart';
import '../entities/resident_health_record.dart';
import '../entities/room.dart';

abstract class INursingRepository {
  /// Mapea: GET /api/v1/nursing-homes/{nursingHomeId}/residents
  Future<Result<Failure, List<Resident>>> getResidents(int nursingHomeId);

  /// Mapea: POST /api/v1/nursing-homes/{nursingHomeId}/residents
  Future<Result<Failure, Resident>> createResident({
    required int nursingHomeId,
    required String dni,
    required String firstName,
    required String lastName,
    required DateTime birthDate,
    required int age,
    required String emailAddress,
    required String street,
    required String number,
    required String city,
    required String postalCode,
    required String country,
    required String phoneNumber,
    required String legalRepresentativeFirstName,
    required String legalRepresentativeLastName,
    required String legalRepresentativePhoneNumber,
    required String emergencyContactFirstName,
    required String emergencyContactLastName,
    required String emergencyContactPhoneNumber,
  });

  /// Mapea: GET /api/v1/nursing-homes/{nursingHomeId}/rooms
  Future<Result<Failure, List<Room>>> getRooms(int nursingHomeId);

  Future<Result<Failure, Resident>> assignRoom({
    required int nursingHomeId,
    required int residentId,
    required String roomNumber,
  });

  Future<Result<Failure, List<ResidentAllergy>>> getAllergies(int residentId);

  Future<Result<Failure, ResidentAllergy>> registerAllergy({
    required int residentId,
    required String allergenName,
    required String reaction,
    required String typeOfAllergy,
    required String severityLevel,
  });

  Future<Result<Failure, List<ResidentMedicalCondition>>> getMedicalConditions(
    int residentId,
  );

  Future<Result<Failure, ResidentMedicalCondition>> registerMedicalCondition({
    required int residentId,
    required String diagnosisName,
    required DateTime diagnosisDate,
    required String status,
    required String notes,
  });

  Future<Result<Failure, List<ResidentVitalSign>>> getVitalSigns(
    int residentId,
  );

  Future<Result<Failure, List<Relative>>> getRelatives(int nursingHomeId);

  Future<Result<Failure, Relative>> createRelative({
    required int nursingHomeId,
    required int residentId,
    required String firstName,
    required String lastName,
    required String email,
  });
}
