import 'package:safeen_institute/services/supabase_service.dart';
import 'package:safeen_institute/services/cache_service.dart';

class ScheduleService {
  /// Fetch all schedules, optionally filtered by department.
  /// Explicitly selects every column the UI needs so nothing is silently
  /// omitted by Supabase PostgREST.
  static Future<List<Map<String, dynamic>>> getSchedules({
    String? departmentId,
  }) async {
    // Per-department cache key so filtering actually works offline too
    final cacheKey = departmentId != null
        ? 'schedules_dept_$departmentId'
        : 'schedules_all';

    try {
      var query = supabase
          .from('schedules')
          .select(
            'id, department_id, semester, academic_year, '
            'file_url, created_at, '
            'departments(id, name_ku, name_en, image_url)',
          );

      if (departmentId != null) {
        query = query.eq('department_id', departmentId);
      }

      final data = await query
          .order('created_at', ascending: false)
          .timeout(const Duration(seconds: 6));

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
