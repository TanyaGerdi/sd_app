import 'package:sd_institute/services/api_service.dart';
import 'package:sd_institute/services/cache_service.dart';

class DepartmentService {
  // Grab all departments from the database via Laravel API
  static Future<List<Map<String, dynamic>>> getDepartments() async {
    const cacheKey = 'departments_all';
    try {
      final response = await ApiService.getRaw('/departments');
      final data = List<Map<String, dynamic>>.from(
        (response['data'] as List).map((d) => Map<String, dynamic>.from(d)),
      );

      // Map the Kurdish fields (_ku) so the UI doesn't break
      final mappedData = data.map((d) {
        List<String> gallery = [];
        if (d['gallery_images'] != null) {
          if (d['gallery_images'] is List) {
            gallery = List<String>.from(d['gallery_images']);
          }
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
      final response = await ApiService.getRaw(
        '/department_programs',
        queryParams: {'department_id': departmentId},
      );
      final data = List<Map<String, dynamic>>.from(
        (response['data'] as List).map((d) => Map<String, dynamic>.from(d)),
      );

      // Map the Kurdish fields again for the UI
      final mappedData = data.map((d) {
        return {
          'id': d['id'],
          'name': d['name_ku'] ?? 'پڕۆگرامی نوێ',
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
