import '../../../shared/core/failures/failures.dart';
import '../../../shared/core/result/result.dart';
import '../entities/family_health_data.dart';
import '../entities/family_portal_data.dart';

abstract class IFamilyPortalRepository {
  Future<Result<Failure, FamilyPortalData>> getPortalData(int userId);
  Future<Result<Failure, List<FamilyMeasurement>>> getMeasurementsOnly(List<int> deviceIds);
}
