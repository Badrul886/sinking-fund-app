import '../models/recent_activity_item.dart';

abstract interface class RecentActivityRepository {
  Future<List<RecentActivityItem>> getRecentActivity({int limit = 5});
}
