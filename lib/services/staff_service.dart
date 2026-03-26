import 'package:safeen_institute/services/supabase_service.dart';
import 'package:safeen_institute/services/cache_service.dart';

class StaffService {
  // ─── Column list ─────────────────────────────────────────────────────────
  // Explicit select so PostgREST never silently omits the new columns
  // (sub_category, degree, specialty, academic_title) added in the migration.
  static const _columns =
      'id, full_name_ku, full_name_en, job_title_ku, job_title_en, '
      'email, phone, phone_number, bio_ku, image_url, order_index, '
      'sub_category, degree, specialty, academic_title, '
      'departments(id, name_ku, name_en)';

  // ─── Shared mapper ───────────────────────────────────────────────────────

  static Map<String, dynamic> _mapStaff(Map<String, dynamic> s) {
    // Department join — may be null if staff has no department set
    String deptName = '';
    String deptId = '';
    final dept = s['departments'];
    if (dept is Map) {
      deptName = (dept['name_ku'] ?? '').toString();
      deptId = (dept['id'] ?? '').toString();
    }

    return {
      'id': (s['id'] ?? '').toString(),
      'name': (s['full_name_ku'] ?? 'ناوی مامۆستا').toString(),
      'name_en': (s['full_name_en'] ?? '').toString(),
      'role': (s['job_title_ku'] ?? 'پۆست').toString(),
      'job_title_en': (s['job_title_en'] ?? '').toString(),
      'department': deptName,
      'department_id': deptId,
      'email': (s['email'] ?? '').toString(),
      // phone_number takes priority; fall back to the older phone column
      'phone': (s['phone_number'] ?? s['phone'] ?? '').toString(),
      'bio': (s['bio_ku'] ?? '').toString(),
      'image_url': (s['image_url'] ?? '').toString(),
      // ── New columns added in migration ──────────────────────────────
      'sub_category': (s['sub_category'] ?? '').toString(),
      'degree': (s['degree'] ?? '').toString(),
      'specialty': (s['specialty'] ?? '').toString(),
      'academic_title': (s['academic_title'] ?? '').toString(),
    };
  }

  // ─── getStaff ────────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getStaff() async {
    const cacheKey = 'staff_new_all_v2';
    try {
      final data = await supabase
          .from('staff')
          .select(_columns)
          .order('order_index', ascending: true)
          .timeout(const Duration(seconds: 6));

      final result = List<Map<String, dynamic>>.from(
        data.map((s) => _mapStaff(Map<String, dynamic>.from(s))),
      );

      if (result.isNotEmpty) {
        await CacheService.saveList(cacheKey, result);
      }
      return result;
    } catch (_) {
      return CacheService.getList(cacheKey);
    }
  }

  // ─── getStaffByDepartment ─────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getStaffByDepartment(
    String departmentId,
  ) async {
    final cacheKey = 'staff_dept_v2_$departmentId';
    try {
      final data = await supabase
          .from('staff')
          .select(_columns)
          .eq('department_id', departmentId)
          .order('order_index', ascending: true)
          .timeout(const Duration(seconds: 6));

      final result = List<Map<String, dynamic>>.from(
        data.map((s) => _mapStaff(Map<String, dynamic>.from(s))),
      );

      if (result.isNotEmpty) {
        await CacheService.saveList(cacheKey, result);
      }
      return result;
    } catch (_) {
      return CacheService.getList(cacheKey);
    }
  }

  // ─── getStaffById ─────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>?> getStaffById(String staffId) async {
    try {
      final data = await supabase
          .from('staff')
          .select(_columns)
          .eq('id', staffId)
          .maybeSingle();

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
