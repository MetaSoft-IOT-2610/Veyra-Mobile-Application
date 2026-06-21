import '../../../shared/core/result/result.dart';
import '../../../shared/core/failures/failures.dart';
import '../../domain/repositories/i_nursing_repository.dart';
import '../dto/resident_summary_dto.dart';

class GetResidentSummaryQuery {
  final INursingRepository _repository;

  GetResidentSummaryQuery(this._repository);

  Future<Result<Failure, ResidentSummaryDto>> execute(int nursingHomeId) async {
    final results = await Future.wait([
      _repository.getResidents(nursingHomeId),
      _repository.getRooms(nursingHomeId),
    ]);

    final residentsResult = results[0] as Result<Failure, List<dynamic>>;
    final roomsResult = results[1] as Result<Failure, List<dynamic>>;

    // Si alguna de las dos falla, retornamos el fallo
    if (residentsResult.isFailure) {
      return Result.failure(const ServerFailure('Error obteniendo residentes'));
    }
    if (roomsResult.isFailure) {
      return Result.failure(
        const ServerFailure('Error obteniendo habitaciones'),
      );
    }

    int residentsCount = 0;
    int roomsCount = 0;
    int availableCount = 0;

    residentsResult.fold(
      (f) {},
      (residents) => residentsCount = residents.length,
    );

    roomsResult.fold((f) {}, (rooms) {
      roomsCount = rooms.length;
      availableCount = rooms.where((r) => r.isAvailable).length;
    });

    return Result.success(
      ResidentSummaryDto(
        totalResidents: residentsCount,
        totalRooms: roomsCount,
        availableRooms: availableCount,
      ),
    );
  }
}
