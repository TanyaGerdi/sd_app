import 'package:sd_institute/services/api_service.dart';
import 'package:sd_institute/services/cache_service.dart';

class StaffService {
  // â”€â”€â”€ Shared mapper â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  static Map<String, dynamic> _mapStaff(Map<String, dynamic> s) {
    // Department â€” may come as a nested object or may be null
    String deptName = '';
    String deptId = '';
    final dept = s['department'];
    if (dept is Map) {
      deptName = (dept['name_ku'] ?? '').toString();
      deptId = (dept['id'] ?? '').toString();
    }
    // Also try the 'departments' key from joined data
    final depts = s['departments'];
    if (depts is Map) {
      deptName = (depts['name_ku'] ?? deptName).toString();
      deptId = (depts['id'] ?? deptId).toString();
    }

    return {
      'id': (s['id'] ?? '').toString(),
      'name': (s['full_name_ku'] ?? 'ناوی مامۆستا').toString(),
      'name_en': (s['full_name_en'] ?? '').toString(),
      'role': (s['job_title_ku'] ?? 'پۆست').toString(),
      'job_title_en': (s['job_title_en'] ?? '').toString(),
      'department': deptName,
      'department_id': (s['department_id'] ?? deptId).toString(),
      'email': (s['email'] ?? '').toString(),
      'phone': (s['phone_number'] ?? s['phone'] ?? '').toString(),
      'bio': (s['bio_ku'] ?? '').toString(),
      'image_url': (s['image_url'] ?? '').toString(),
      // â”€â”€ New columns added in migration â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
      'sub_category': (s['sub_category'] ?? '').toString(),
      'degree': (s['degree'] ?? '').toString(),
      'specialty': (s['specialty'] ?? '').toString(),
      'academic_title': (s['academic_title'] ?? '').toString(),
    };
  }

  // â”€â”€â”€ getStaff â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  static Future<List<Map<String, dynamic>>> getStaff() async {
    const cacheKey = 'staff_new_all_v2';
    try {
      final response = await ApiService.getRaw('/staff');
      final data = List<Map<String, dynamic>>.from(
        (response['data'] as List).map((d) => Map<String, dynamic>.from(d)),
      );

      final result = data.map((s) => _mapStaff(s)).toList();

      if (result.isNotEmpty) {
        await CacheService.saveList(cacheKey, result);
      }
      return result;
    } catch (_) {
      return CacheService.getList(cacheKey);
    }
  }

  // â”€â”€â”€ getStaffByDepartment â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  static Future<List<Map<String, dynamic>>> getStaffByDepartment(
    String departmentId,
  ) async {
    final cacheKey = 'staff_dept_v2_$departmentId';
    try {
      final response = await ApiService.getRaw(
        '/staff',
        queryParams: {'department_id': departmentId},
      );
      final data = List<Map<String, dynamic>>.from(
        (response['data'] as List).map((d) => Map<String, dynamic>.from(d)),
      );

      final result = data.map((s) => _mapStaff(s)).toList();

      if (result.isNotEmpty) {
        await CacheService.saveList(cacheKey, result);
      }
      return result;
    } catch (_) {
      return CacheService.getList(cacheKey);
    }
  }

  // â”€â”€â”€ getStaffById â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  static Future<Map<String, dynamic>?> getStaffById(String staffId) async {
    try {
      final data = await ApiService.get('/staff/$staffId');
      if (data != null) {
        return _mapStaff(Map<String, dynamic>.from(data));
      }
    } catch (_) {}
    return null;
  }

  // We don't have a staff_programs link table in the new DB.
  // Returns empty list to avoid breaking old UI parts that use it.
  static Future<List<Map<String, dynamic>>> getStaffPrograms(
    String staffId,
  ) async {
    return [];
  }
}
