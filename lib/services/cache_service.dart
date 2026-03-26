import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight offline cache backed by SharedPreferences.
/// Stores JSON data so the app works without internet after first load.
class CacheService {
  static SharedPreferences? _prefs;

  /// Call once at app startup to warm the cache.
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static Future<SharedPreferences> get _instance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ─── Save a list of maps ─────────────────────────
  static Future<void> saveList(
    String key,
    List<Map<String, dynamic>> data,
  ) async {
    final prefs = await _instance;
    final json = jsonEncode(data);
    await prefs.setString(key, json);
    await prefs.setInt('${key}_ts', DateTime.now().millisecondsSinceEpoch);
  }

  // ─── Load a cached list ──────────────────────────
  static Future<List<Map<String, dynamic>>> getList(String key) async {
    final prefs = await _instance;
    final raw = prefs.getString(key);
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw) as List;
      return List<Map<String, dynamic>>.from(decoded);
    } catch (_) {
      return [];
    }
  }

  // ─── Save a single map ───────────────────────────
  static Future<void> saveMap(
    String key,
    Map<String, dynamic> data,
  ) async {
    final prefs = await _instance;
    final json = jsonEncode(data);
    await prefs.setString(key, json);
    await prefs.setInt('${key}_ts', DateTime.now().millisecondsSinceEpoch);
  }

  // ─── Load a cached map ───────────────────────────
  static Future<Map<String, dynamic>> getMap(String key) async {
    final prefs = await _instance;
    final raw = prefs.getString(key);
    if (raw == null) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
      return {};
    } catch (_) {
      return {};
    }
  }

  // ─── Check if cache exists ───────────────────────
  static Future<bool> has(String key) async {
    final prefs = await _instance;
    return prefs.containsKey(key);
  }
}
