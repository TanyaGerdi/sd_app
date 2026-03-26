import 'package:safeen_institute/services/supabase_service.dart';
import 'package:safeen_institute/services/cache_service.dart';

class DepartmentService {
  // Grab all departments from the database and sort them by the admin's chosen order
  static Future<List<Map<String, dynamic>>> getDepartments() async {
    const cacheKey = 'departments_all';
    try {
      final data = await supabase
          .from('departments')
          .select()
          .order('order_index', ascending: true)
          .timeout(const Duration(seconds: 4));

      // We need to map the Kurdish fields (_ku) so the UI doesn't break
      final mappedData = data.map((d) {
        List<String> gallery = [];
        if (d['gallery_images'] != null) {
          gallery = List<String>.from(d['gallery_images']);
        }
        return {
          'id': d['id'],
          'name': d['name_ku'] ?? 'بەشێکی نوێ',
          'description': d['description_ku'] ?? 'هیچ زانیارییەک نەدۆزرایەوە',
          'image_url': d['image_url'] ?? '',
          'video_url': d['video_url'] ?? '',
          'gallery_images': gallery,
        };
      }).toList();

      final result = List<Map<String, dynamic>>.from(mappedData);
      
      // Save for offline use
      if (result.isNotEmpty) {
        await CacheService.saveList(cacheKey, result);
      }
      return result;
    } catch (_) {
      // Fallback to cache if internet fails
      return CacheService.getList(cacheKey);
    }
  }

  // Get the sub-programs inside a specific department
  static Future<List<Map<String, dynamic>>> getDepartmentPrograms(
    String departmentId,
  ) async {
    final cacheKey = 'dept_programs_$departmentId';
    try {
      final data = await supabase
          .from('department_programs')
          .select()
          .eq('department_id', departmentId)
          .order('created_at', ascending: true)
          .timeout(const Duration(seconds: 4));

      // Map the Kurdish fields again for the UI
      final mappedData = data.map((d) {
        return {
          'id': d['id'],
          'name': d['name_ku'] ?? 'پرۆگرامی نوێ',
          // We can append the duration as the description if the UI expects it
          'description': '${d['duration_years'] ?? 2} ساڵ', 
        };
      }).toList();

      final result = List<Map<String, dynamic>>.from(mappedData);
      
      if (result.isNotEmpty) {
        await CacheService.saveList(cacheKey, result);
      }
      return result;
    } catch (_) {
      return CacheService.getList(cacheKey);
    }
  }
}
