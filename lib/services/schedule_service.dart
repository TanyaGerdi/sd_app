import 'package:sd_institute/services/api_service.dart';
import 'package:sd_institute/services/cache_service.dart';

class ScheduleService {
  /// Fetches schedules and manually joins department info to match UI expectations.
  static Future<List<Map<String, dynamic>>> getSchedules({
    String? departmentId,
  }) async {
    final cacheKey = departmentId != null
        ? 'schedules_dept_$departmentId'
        : 'schedules_all';

    try {
      // 1. Fetch schedules from Laravel API
      final Map<String, dynamic> queryParams = {};
      if (departmentId != null) {
        queryParams['department_id'] = departmentId;
      }
      final response = await ApiService.getRaw('/schedules', queryParams: queryParams);
      final List dataList = response['data'] ?? [];

      // 2. Fetch departments to resolve relation
      final deptResponse = await ApiService.getRaw('/departments');
      final List deptList = deptResponse['data'] ?? [];
      final Map<String, Map<String, dynamic>> deptMap = {
        for (var d in deptList) d['id'].toString(): Map<String, dynamic>.from(d)
      };

      // 3. Map rows and resolve department relation
      final result = List<Map<String, dynamic>>.from(
        dataList.map((s) {
          final sMap = Map<String, dynamic>.from(s);
          final dId = sMap['department_id']?.toString();
          final dept = deptMap[dId];

          return {
            'id': sMap['id']?.toString() ?? '',
            'department_id': dId ?? '',
            'semester': sMap['semester']?.toString() ?? '',
            'academic_year': sMap['academic_year']?.toString() ?? '',
            'file_url': sMap['file_url']?.toString() ?? '',
            'created_at': sMap['created_at']?.toString() ?? '',
            'departments': dept != null
                ? {
                    'id': dept['id']?.toString() ?? '',
                    'name_ku': dept['name_ku'] ?? '',
                    'name_en': dept['name_en'] ?? '',
                    'image_url': dept['image_url'] ?? '',
                  }
                : null,
          };
        }),
      );

      if (result.isNotEmpty) {
        await CacheService.saveList(cacheKey, result);
      }
      return result;
    } catch (_) {
      return CacheService.getList(cacheKey);
    }
  }
}
