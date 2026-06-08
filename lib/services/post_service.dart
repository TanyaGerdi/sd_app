import 'dart:convert';
import 'package:sd_institute/services/api_service.dart';
import 'package:sd_institute/services/cache_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostService {
  // â”€â”€â”€ Shared helpers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Safely converts the gallery_images value to a clean Dart list.
  static List<String> _parseGallery(dynamic raw) {
    if (raw == null) return [];

    if (raw is List) {
      return raw
          .where((e) => e != null && e.toString().trim().isNotEmpty)
          .map((e) => e.toString().trim())
          .toList();
    }

    if (raw is String) {
      final s = raw.trim();
      if (s.isEmpty) return [];
      // If it's a JSON array string
      if (s.startsWith('[') && s.endsWith(']')) {
        try {
          final decoded = jsonDecode(s);
          if (decoded is List) {
            return decoded.map((e) => e.toString()).toList();
          }
        } catch (_) {}
      }
      // Postgres array literal: {url1,url2,url3}
      if (s.startsWith('{') && s.endsWith('}')) {
        final inner = s.substring(1, s.length - 1);
        if (inner.trim().isEmpty) return [];
        return inner
            .split(',')
            .map((e) => e.trim().replaceAll('"', ''))
            .where((e) => e.isNotEmpty)
            .toList();
      }
      // Plain single URL
      if (s.startsWith('http')) return [s];
    }

    return [];
  }

  /// Maps a raw Laravel API row into the canonical shape the UI consumes.
  static Map<String, dynamic> _mapRow(
    Map<String, dynamic> d, {
    required String category,
  }) {
    final content = (d['content_ku'] ?? d['description_ku'] ?? '').toString();
    final dateRaw = (d['activity_date'] ?? d['created_at'] ?? '').toString();

    return {
      'id': d['id']?.toString() ?? '',
      'title': (d['title_ku'] ?? 'بێ ناونیشان').toString(),
      'content': content,
      'image': (d['image_url'] ?? '').toString(),
      'image_url': (d['image_url'] ?? '').toString(),
      'gallery_images': _parseGallery(d['gallery_images']),
      'category': category,
      'created_at': dateRaw,
      'time': dateRaw,
      'location': (d['location'] ?? '').toString(),
      'activity_date': (d['activity_date'] ?? '').toString(),
    };
  }

  // â”€â”€â”€ getPosts â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  static Future<List<Map<String, dynamic>>> getPosts({String? category}) async {
    final cacheKey = 'custom_posts_${category ?? 'all'}';

    try {
      List<Map<String, dynamic>> result = [];
      String endpoint = '/news';
      Map<String, dynamic> queryParams = {};

      if (category == 'activities') {
        endpoint = '/activities';
      } else if (category == 'student_news') {
        endpoint = '/student_news';
        queryParams['is_published'] = '1';
      } else if (category == 'quotes') {
        endpoint = '/student_quotes';
        queryParams['is_published'] = '1';
      } else {
        endpoint = '/news';
        queryParams['is_published'] = '1';
      }

      final response = await ApiService.getRaw(endpoint, queryParams: queryParams);
      final List dataList = response['data'] ?? [];

      result = List<Map<String, dynamic>>.from(
        dataList.map((d) => _mapRow(Map<String, dynamic>.from(d), category: category ?? 'news')),
      );

      if (result.isNotEmpty) {
        await CacheService.saveList(cacheKey, result);
      }
      return result;
    } catch (e) {
      return CacheService.getList(cacheKey);
    }
  }

  // â”€â”€â”€ getPostById â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  static Future<Map<String, dynamic>?> getPostById(String id, {String? table}) async {
    final tablesToSearch = table != null ? [table] : ['news', 'student_news', 'activities', 'student_quotes'];

    for (final tbl in tablesToSearch) {
      try {
        final data = await ApiService.get('/$tbl/$id');
        if (data != null) {
          String category = tbl == 'student_quotes' ? 'quotes' : tbl;
          return _mapRow(
            Map<String, dynamic>.from(data),
            category: category,
          );
        }
      } catch (_) {
        continue;
      }
    }
    return null;
  }

  // â”€â”€â”€ getFeaturedPosts â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  static Future<List<Map<String, dynamic>>> getFeaturedPosts() async {
    const cacheKey = 'featured_posts_new';

    try {
      final response = await ApiService.getRaw('/news', queryParams: {'is_published': '1'});
      final List dataList = response['data'] ?? [];

      // Limit to 4 elements client-side
      final limitedList = dataList.take(4).toList();

      final result = List<Map<String, dynamic>>.from(
        limitedList.map((d) => _mapRow(Map<String, dynamic>.from(d), category: 'news')),
      );

      if (result.isNotEmpty) {
        await CacheService.saveList(cacheKey, result);
      }
      return result;
    } catch (_) {
      return CacheService.getList(cacheKey);
    }
  }

  // â”€â”€â”€ Saved posts â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  static Future<String> _getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString('device_id');
    if (deviceId == null) {
      deviceId = 'device_${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString('device_id', deviceId);
    }
    return deviceId;
  }

  static Future<List<Map<String, dynamic>>> getSavedPosts() async {
    const cacheKey = 'saved_posts_v2';

    try {
      final deviceId = await _getDeviceId();
      final response = await ApiService.getRaw('/saved_posts', queryParams: {'device_id': deviceId});
      final List savedList = response['data'] ?? [];

      final List<Map<String, dynamic>> result = [];
      for (final item in savedList) {
        final postId = item['post_id']?.toString();
        if (postId != null) {
          final post = await getPostById(postId);
          if (post != null) {
            result.add(post);
          }
        }
      }

      if (result.isNotEmpty) {
        await CacheService.saveList(cacheKey, result);
      }
      return result;
    } catch (_) {
      return CacheService.getList(cacheKey);
    }
  }

  static Future<void> toggleSavedPost(String postId, bool isSaving) async {
    try {
      final deviceId = await _getDeviceId();
      if (isSaving) {
        await ApiService.post('/saved_posts', data: {
          'device_id': deviceId,
          'post_id': postId,
        });
      } else {
        // Find the record ID first using filters
        final response = await ApiService.getRaw('/saved_posts', queryParams: {
          'device_id': deviceId,
          'post_id': postId,
          'single': '1',
        });
        final record = response['data'];
        if (record != null && record['id'] != null) {
          final recordId = record['id'];
          await ApiService.delete('/saved_posts/$recordId');
        }
      }
    } catch (_) {}
  }

  // â”€â”€â”€ getPostGallery â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  static Future<List<String>> getPostGallery(
    String postId, {
    String table = 'news',
  }) async {
    try {
      final data = await ApiService.get('/$table/$postId');
      if (data != null) {
        final rawData = Map<String, dynamic>.from(data);
        final fromArray = _parseGallery(rawData['gallery_images']);
        if (fromArray.isNotEmpty) return fromArray;

        // Fallback: legacy JSON stored in content_en
        final contentEn = (rawData['content_en'] ?? '').toString().trim();
        if (contentEn.startsWith('{') && contentEn.contains('galleryUrls')) {
          try {
            final parsed = Map<String, dynamic>.from(
              jsonDecode(contentEn) as Map,
            );
            if (parsed['galleryUrls'] is List) {
              return List<String>.from(
                parsed['galleryUrls'],
              ).where((u) => u.isNotEmpty).toList();
            }
          } catch (_) {}
        }
      }
    } catch (_) {}
    return [];
  }
}
