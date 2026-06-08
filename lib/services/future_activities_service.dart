import 'package:sd_institute/services/api_service.dart';
import 'package:sd_institute/services/cache_service.dart';

class FutureActivitiesService {
  // Fetch published future activities sorted by date (nearest first)
  static Future<List<Map<String, dynamic>>> getActivities() async {
    const cacheKey = 'future_activities_all';
    try {
      final response = await ApiService.getRaw('/future_activities', queryParams: {
        'is_published': '1',
      });
      final List data = response['data'] ?? [];
      final result = List<Map<String, dynamic>>.from(data);

      // Sort client-side by activity_date ascending
      result.sort((a, b) {
        final aDate = a['activity_date']?.toString() ?? '';
        final bDate = b['activity_date']?.toString() ?? '';
        return aDate.compareTo(bDate);
      });

      if (result.isNotEmpty) {
        await CacheService.saveList(cacheKey, result);
      }
      return result;
    } catch (_) {
      return CacheService.getList(cacheKey);
    }
  }
}
