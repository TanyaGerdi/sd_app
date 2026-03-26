import 'package:safeen_institute/services/supabase_service.dart';
import 'package:safeen_institute/services/cache_service.dart';

class FutureActivitiesService {
  // Fetch published future activities sorted by date (nearest first)
  static Future<List<Map<String, dynamic>>> getActivities() async {
    const cacheKey = 'future_activities_all';
    try {
      final data = await supabase
          .from('future_activities')
          .select()
          .eq('is_published', true)
          .order('activity_date', ascending: true)
          .timeout(const Duration(seconds: 4));

      final result = List<Map<String, dynamic>>.from(data);

      if (result.isNotEmpty) {
        await CacheService.saveList(cacheKey, result);
      }
      return result;
    } catch (_) {
      return CacheService.getList(cacheKey);
    }
  }
}
