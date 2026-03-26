import 'dart:convert';
import 'package:safeen_institute/services/supabase_service.dart';
import 'package:safeen_institute/services/cache_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostService {
  // ─── Shared helpers ──────────────────────────────────────────────────────

  /// Safely converts the Supabase `gallery_images text[]` value to a clean
  /// Dart list regardless of whether it arrives as a List, a Postgres literal
  /// string "{url1,url2}", or null.
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

  /// Maps a raw Supabase row into the canonical shape the UI consumes.
  /// Handles all four tables: news, student_news, activities, student_quotes.
  static Map<String, dynamic> _mapRow(
    Map<String, dynamic> d, {
    required String category,
  }) {
    // activities uses description_ku instead of content_ku
    final content = (d['content_ku'] ?? d['description_ku'] ?? '').toString();

    // activities has activity_date, others have created_at
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
      // activities-specific extras — safe no-ops for other tables
      'location': (d['location'] ?? '').toString(),
      'activity_date': (d['activity_date'] ?? '').toString(),
    };
  }

  // ─── getPosts ────────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getPosts({String? category}) async {
    final cacheKey = 'custom_posts_${category ?? 'all'}';

    try {
      List<Map<String, dynamic>> result = [];

      if (category == 'activities') {
        // activities table: no is_published filter, different columns
        final data = await supabase
            .from('activities')
            .select(
              'id, title_ku, description_ku, image_url, '
              'gallery_images, activity_date, location, created_at',
            )
            .order('created_at', ascending: false)
            .timeout(const Duration(seconds: 6));

        result = List<Map<String, dynamic>>.from(
          data.map((d) => _mapRow(d, category: 'activities')),
        );
      } else if (category == 'student_news') {
        final data = await supabase
            .from('student_news')
            .select(
              'id, title_ku, content_ku, image_url, '
              'gallery_images, created_at, is_published',
            )
            .eq('is_published', true)
            .order('created_at', ascending: false)
            .timeout(const Duration(seconds: 6));

        result = List<Map<String, dynamic>>.from(
          data.map((d) => _mapRow(d, category: 'student_news')),
        );
      } else if (category == 'quotes') {
        final data = await supabase
            .from('student_quotes')
            .select(
              'id, title_ku, content_ku, image_url, '
              'gallery_images, created_at, is_published',
            )
            .eq('is_published', true)
            .order('created_at', ascending: false)
            .timeout(const Duration(seconds: 6));

        result = List<Map<String, dynamic>>.from(
          data.map((d) => _mapRow(d, category: 'quotes')),
        );
      } else {
        // Default: news table
        final data = await supabase
            .from('news')
            .select(
              'id, title_ku, content_ku, image_url, '
              'gallery_images, created_at, is_published, category',
            )
            .eq('is_published', true)
            .order('created_at', ascending: false)
            .timeout(const Duration(seconds: 6));

        result = List<Map<String, dynamic>>.from(
          data.map((d) => _mapRow(d, category: category ?? 'news')),
        );
      }

      if (result.isNotEmpty) {
        await CacheService.saveList(cacheKey, result);
      }
      return result;
    } catch (e) {
      return CacheService.getList(cacheKey);
    }
  }

  // ─── getPostById ─────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>?> getPostById(String id, {String? table}) async {
    // Table → category label → select columns
    final tableConfigs = [
      {
        'table': 'news',
        'category': 'news',
        'columns':
            'id, title_ku, content_ku, image_url, gallery_images, created_at, category, content_en',
      },
      {
        'table': 'student_news',
        'category': 'student_news',
        'columns':
            'id, title_ku, content_ku, image_url, gallery_images, created_at, content_en',
      },
      {
        'table': 'activities',
        'category': 'activities',
        'columns':
            'id, title_ku, description_ku, image_url, gallery_images, activity_date, location, created_at',
      },
      {
        'table': 'student_quotes',
        'category': 'quotes',
        'columns':
            'id, title_ku, content_ku, image_url, gallery_images, created_at, content_en',
      },
    ];

    // If specific table provided, only check that one
    final configsToSearch = table != null 
      ? tableConfigs.where((c) => c['table'] == table).toList()
      : tableConfigs;

    for (final config in configsToSearch) {
      try {
        final data = await supabase
            .from(config['table']!)
            .select(config['columns']!)
            .eq('id', id)
            .maybeSingle();

        if (data != null) {
          return _mapRow(
            Map<String, dynamic>.from(data),
            category: config['category']!,
          );
        }
      } catch (_) {
        continue;
      }
    }
    return null;
  }

  // ─── getFeaturedPosts ────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getFeaturedPosts() async {
    const cacheKey = 'featured_posts_new';

    try {
      final data = await supabase
          .from('news')
          .select(
            'id, title_ku, content_ku, image_url, gallery_images, created_at',
          )
          .eq('is_published', true)
          .order('created_at', ascending: false)
          .limit(4)
          .timeout(const Duration(seconds: 6));

      final result = List<Map<String, dynamic>>.from(
        data.map((d) => _mapRow(d, category: 'news')),
      );

      if (result.isNotEmpty) {
        await CacheService.saveList(cacheKey, result);
      }
      return result;
    } catch (_) {
      return CacheService.getList(cacheKey);
    }
  }

  // ─── Saved posts ─────────────────────────────────────────────────────────

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

      final data = await supabase
          .from('saved_posts')
          .select(
            'id, created_at, '
            'news(id, title_ku, content_ku, description_ku, '
            '     image_url, gallery_images, category, created_at)',
          )
          .eq('device_id', deviceId)
          .order('created_at', ascending: false);

      final result = List<Map<String, dynamic>>.from(
        data
            .map((d) {
              final newsItem = d['news'];
              if (newsItem == null) return <String, dynamic>{};
              return _mapRow(
                Map<String, dynamic>.from(newsItem),
                category: (newsItem['category'] ?? 'news').toString(),
              );
            })
            .where((e) => e.isNotEmpty),
      );

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
        await supabase.from('saved_posts').insert({
          'device_id': deviceId,
          'post_id': postId,
        });
      } else {
        await supabase
            .from('saved_posts')
            .delete()
            .eq('device_id', deviceId)
            .eq('post_id', postId);
      }
    } catch (_) {}
  }

  // ─── getPostGallery ───────────────────────────────────────────────────────
  // Fetches gallery images for a specific post.
  // Primary source: `gallery_images text[]` column.
  // Legacy fallback: `content_en` JSON with `{"galleryUrls": [...]}`.

  static Future<List<String>> getPostGallery(
    String postId, {
    String table = 'news',
  }) async {
    try {
      final data = await supabase
          .from(table)
          .select('gallery_images, content_en')
          .eq('id', postId)
          .maybeSingle();

      if (data != null) {
        // ── Primary: native array column ──────────────────────────
        final fromArray = _parseGallery(data['gallery_images']);
        if (fromArray.isNotEmpty) return fromArray;

        // ── Fallback: legacy JSON stored in content_en ────────────
        final contentEn = (data['content_en'] ?? '').toString().trim();
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
