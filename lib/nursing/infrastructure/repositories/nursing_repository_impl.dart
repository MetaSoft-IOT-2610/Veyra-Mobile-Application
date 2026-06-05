import '../../../shared/core/failures/failures.dart';
import '../../../shared/core/result/result.dart';
import '../../../shared/core/exceptions/exceptions.dart';
import '../../domain/entities/resident.dart';
import '../../domain/entities/room.dart';
import '../../domain/repositories/i_nursing_repository.dart';
import '../datasources/nursing_remote_datasource.dart';

class NursingRepositoryImpl implements INursingRepository {
  final NursingRemoteDataSource remoteDataSource;

  NursingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<Failure, List<Resident>>> getResidents(int nursingHomeId) async {
    try {
      final models = await remoteDataSource.getResidents(nursingHomeId);
      return Result.success(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message));
    } catch (e) {
      return Result.failure(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Result<Failure, List<Room>>> getRooms(int nursingHomeId) async {
    try {
      final models = await remoteDataSource.getRooms(nursingHomeId);
      return Result.success(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message));
    } catch (e) {
      return Result.failure(ServerFailure('Unexpected error: $e'));
    }
  }
}