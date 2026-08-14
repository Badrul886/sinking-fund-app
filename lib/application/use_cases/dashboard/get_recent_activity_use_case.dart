import '../../ports/recent_activity_repository.dart';
import '../../models/recent_activity_item.dart';

class GetRecentActivityUseCase {
  final RecentActivityRepository _repository;

  const GetRecentActivityUseCase(this._repository);

  Future<List<RecentActivityItem>> execute({int limit = 5}) async {
    return await _repository.getRecentActivity(limit: limit);
  }
}
