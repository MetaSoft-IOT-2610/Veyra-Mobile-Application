import '../../../shared/core/result/result.dart';
import '../../../shared/core/failures/failures.dart';
import '../../domain/entities/activity.dart';
import '../../domain/repositories/i_activities_repository.dart';

class GetTodayActivitiesQuery {
  final IActivitiesRepository _repository;

  GetTodayActivitiesQuery(this._repository);

  /// Obtiene y filtra las actividades correspondientes al día actual.
  Future<Result<Failure, List<Activity>>> execute(int nursingHomeId) async {
    if (nursingHomeId <= 0) {
      return Result.failure(const ValidationFailure('ID de residencia inválido.'));
    }

    final result = await _repository.getActivitiesByNursingHome(nursingHomeId);

    // Utilizamos fold para interceptar el éxito y aplicar la regla de negocio de filtrado
    return result.fold(
      (failure) => Result.failure(failure), // Si falló, pasamos el fallo intacto
      (activities) {
        final now = DateTime.now();
        
        // Filtramos para mantener solo las que inician en el mismo año, mes y día
        final todayActivities = activities.where((activity) {
          final startTime = activity.schedule.startTime;
          return startTime.year == now.year && 
                 startTime.month == now.month && 
                 startTime.day == now.day;
        }).toList();

        todayActivities.sort((a, b) => 
            a.schedule.startTime.compareTo(b.schedule.startTime));

        return Result.success(todayActivities);
      },
    );
  }
}