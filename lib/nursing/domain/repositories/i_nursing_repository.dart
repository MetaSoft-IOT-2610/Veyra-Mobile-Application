import 'package:veyra_mobile_app/nursing/domain/entities/resident.dart';

import '../../../shared/core/result/result.dart';
import '../../../shared/core/failures/failures.dart';
import '../entities/room.dart';

abstract class INursingRepository {
  /// Mapea: GET /api/v1/nursing-homes/{nursingHomeId}/residents
  Future<Result<Failure, List<Resident>>> getResidents(int nursingHomeId);

  /// Mapea: GET /api/v1/nursing-homes/{nursingHomeId}/rooms
  Future<Result<Failure, List<Room>>> getRooms(int nursingHomeId);
}