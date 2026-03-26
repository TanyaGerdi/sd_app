import 'package:safeen_institute/services/supabase_service.dart';
import 'package:safeen_institute/services/cache_service.dart';

class InstituteService {
  // Grab the global settings from our new app_settings table.
  static Future<Map<String, dynamic>> getAppSettings() async {
    const cacheKey = 'app_settings_global';
    try {
      final data = await supabase
          .from('app_settings')
          .select()
          .eq('id', 'global')
          .maybeSingle();

      if (data != null) {
        await CacheService.saveMap(cacheKey, data);
        return data;
      }
    } catch (e) {
      return CacheService.getMap(cacheKey);
    }
    return {};
  }

  static Future<Map<String, dynamic>> getInstitute() async {
    final settings = await getAppSettings();
    return {
      'name': settings['institute_name_ku'] ?? 'پەیمانگەی تەکنیکی سەفین',
      'tagline': settings['institute_name_en'] ?? 'Safeen Technical Institute',
      'description': settings['history_ku'] ?? 'هیچ زانیارییەک نەدۆزرایەوە.',
      'logo_url': settings['logo_url'] ?? '',
      'cover_url': '',
    };
  }

  static Future<Map<String, dynamic>> getStats() async {
    const cacheKey = 'institute_stats_v4';
    try {
      final settings = await getAppSettings();

      final socialLinks = settings['social_links'];
      String deptCount = '0';
      String staffCount = '0';
      String studentCount = '0';

      if (socialLinks is Map) {
        deptCount = (socialLinks['departments_count'] ?? '0').toString();
        staffCount = (socialLinks['teachers_count'] ?? '0').toString();
        studentCount = (socialLinks['students_count'] ?? '0').toString();
      }

      final data = {
        'departments_count': deptCount,
        'teachers_count': staffCount,
        'students_count': studentCount,
      };

      await CacheService.saveMap(cacheKey, data);
      return data;
    } catch (_) {
      return CacheService.getMap(cacheKey);
    }
  }

  static Future<Map<String, dynamic>> getContactInfo() async {
    final settings = await getAppSettings();

    List phones = settings['phone_numbers'] ?? [];
    String? mainPhone = phones.isNotEmpty ? phones.first.toString() : null;

    return {
      'location': settings['address_ku'] ?? '',
      'phone': mainPhone ?? '',
      'email': settings['email'] ?? '',
    };
  }

  static Future<Map<String, dynamic>> getWorkingHours() async {
    final settings = await getAppSettings();
    return {
      'weekdays': settings['working_hours_ku'] ?? '',
      'working_days': settings['working_days_ku'] ?? 'یەکشەممە — پێنجشەممە',
      'weekend': 'پشوو',
      'weekend_days': 'هەینی — شەممە',
    };
  }

  /// Fetch social media links from the database.
  ///
  /// Rules:
  /// • Skips any key whose value is empty or whose key contains `_count`
  ///   (those are the stats stored in the same JSON, not real links).
  /// • **Skips WhatsApp** — keys that contain `whatsapp`, `wa`, or
  ///   values that start with `https://wa.me` or `https://api.whatsapp`.
  /// • Returns a list of `{ 'platform': String, 'url': String }` maps,
  ///   ready to be rendered as social orbs in the Contact screen.
  static Future<List<Map<String, dynamic>>> getSocialMedia() async {
    const cacheKey = 'social_links_v2';
    try {
      final settings = await getAppSettings();
      final raw = settings['social_links'];

      if (raw == null) return [];

      // The DB stores social_links as a jsonb object like:
      // { "facebook": "https://...", "instagram": "https://...", … }
      final Map<String, dynamic> links = (raw is Map<String, dynamic>)
          ? raw
          : Map<String, dynamic>.from(raw);

      final List<Map<String, dynamic>> result = [];

      links.forEach((platform, url) {
        final p = platform.toLowerCase();
        final u = (url ?? '').toString().trim();

        // ── Skip empty values and stat fields ──────────────────────────
        if (u.isEmpty) return;
        if (p.contains('_count')) return;

        // ── Skip WhatsApp (removed from UI per requirement) ────────────
        if (p.contains('whatsapp') || p.contains('_wa') || p == 'wa') return;
        if (u.startsWith('https://wa.me') ||
            u.startsWith('https://api.whatsapp'))
          return;

        result.add({'platform': platform, 'url': u});
      });

      // Persist to cache so the orbs appear even when offline
      await CacheService.saveList(cacheKey, result);
      return result;
    } catch (_) {
      // Fall back to whatever was cached last
      return CacheService.getList(cacheKey);
    }
  }

  // Get guidelines from the JSONB column
  static Future<List<Map<String, dynamic>>> getGuidelines() async {
    const cacheKey = 'guidelines_v2';
    try {
      final settings = await getAppSettings();
      final guidelinesRaw = settings['guidelines'];

      if (guidelinesRaw is List && guidelinesRaw.isNotEmpty) {
        final result = guidelinesRaw.map<Map<String, dynamic>>((g) {
          return Map<String, dynamic>.from(g);
        }).toList();
        await CacheService.saveList(cacheKey, result);
        return result;
      }
    } catch (_) {}
    return CacheService.getList(cacheKey);
  }

  // Get registration form URL for PDF download
  static Future<String> getRegistrationFormUrl() async {
    final settings = await getAppSettings();
    return (settings['registration_form_url'] ?? '').toString();
  }

  // Admission header image for guidelines screen
  static Future<String> getAdmissionImage() async {
    final settings = await getAppSettings();
    return (settings['admission_image_url'] ?? '').toString();
  }

  // Academic year label like "2024-2025"
  static Future<String> getAcademicYear() async {
    final settings = await getAppSettings();
    return (settings['academic_year'] ?? '2024-2025').toString();
  }

  // Official Institute Portal URL (e.g., student/staff portal)
  static Future<String> getPortalUrl() async {
    final settings = await getAppSettings();
    return (settings['portal_url'] ?? 'https://safeen.portal.com').toString();
  }
}
