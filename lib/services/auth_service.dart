import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sd_institute/services/api_service.dart';

/// Handles student login/logout and session persistence.
class AuthService {
  static const String _studentKey = 'logged_in_student';

  /// Currently logged-in student data (cached in memory after first read)
  static Map<String, dynamic>? _currentStudent;

  /// Notifier for authentication state changes
  static final ValueNotifier<Map<String, dynamic>?> studentNotifier =
      ValueNotifier<Map<String, dynamic>?>(null);

  /// Login via the Laravel `/api/auth/student-login` endpoint.
  /// Returns the student data map on success, throws on failure.
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await ApiService.post(
      '/auth/student-login',
      data: {'email': email, 'password': password},
    );
    final studentData = Map<String, dynamic>.from(response['data']);
    await _saveSession(studentData);
    studentNotifier.value = studentData;
    return studentData;
  }

  /// Login via the Laravel `/api/auth/teacher-login` endpoint.
  /// Returns the teacher data map on success, throws on failure.
  static Future<Map<String, dynamic>> loginTeacher(
    String email,
    String password,
  ) async {
    final response = await ApiService.post(
      '/auth/teacher-login',
      data: {'email': email, 'password': password},
    );
    final teacherData = Map<String, dynamic>.from(response['data']);
    teacherData['is_teacher'] = true;
    await _saveSession(teacherData);
    studentNotifier.value = teacherData;
    return teacherData;
  }

  /// Logout — clear session
  static Future<void> logout() async {
    _currentStudent = null;
    studentNotifier.value = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_studentKey);
  }

  /// Check if a student or teacher is logged in
  static Future<bool> isLoggedIn() async {
    final user = await getStudent();
    return user != null;
  }

  /// Check if the logged in user is a teacher
  static bool isTeacher() {
    return _currentStudent?['is_teacher'] == true;
  }

  /// Get the cached student data (from memory or SharedPreferences)
  static Future<Map<String, dynamic>?> getStudent() async {
    if (_currentStudent != null) {
      if (studentNotifier.value != _currentStudent) {
        studentNotifier.value = _currentStudent;
      }
      return _currentStudent;
    }
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_studentKey);
    if (raw == null) {
      if (studentNotifier.value != null) {
        studentNotifier.value = null;
      }
      return null;
    }
    try {
      _currentStudent = Map<String, dynamic>.from(jsonDecode(raw));
      studentNotifier.value = _currentStudent;
      return _currentStudent;
    } catch (_) {
      if (studentNotifier.value != null) {
        studentNotifier.value = null;
      }
      return null;
    }
  }

  /// Synchronous getter for use in already-loaded contexts
  static Map<String, dynamic>? get currentStudent => _currentStudent;

  /// Get the user's display name
  static String getStudentName() {
    return _currentStudent?['name'] ?? _currentStudent?['full_name_ku'] ?? _currentStudent?['full_name_en'] ?? '';
  }

  /// Get the student's department name
  static String getDepartmentName() {
    final dept = _currentStudent?['department'];
    if (dept is Map) {
      return dept['name_ku'] ?? dept['name_en'] ?? '';
    }
    return '';
  }

  /// Get the student's numeric ID (for API calls)
  static int? getStudentId() {
    final id = _currentStudent?['id'];
    if (id is int) return id;
    if (id is String) return int.tryParse(id);
    return null;
  }

  /// Fetch the full student profile (fees + attendance) from the API
  static Future<Map<String, dynamic>> getStudentProfile() async {
    final id = getStudentId();
    if (id == null) throw Exception('Not logged in');
    final data = await ApiService.get('/student-profile/$id');
    return Map<String, dynamic>.from(data);
  }

  /// Refresh student data from the API and update the local session
  static Future<void> refreshStudent() async {
    final id = getStudentId();
    if (id == null) return;
    try {
      final data = await ApiService.get('/students/$id');
      if (data != null) {
        final studentData = Map<String, dynamic>.from(data);
        // Remove password from stored data
        studentData.remove('password');
        await _saveSession(studentData);
      }
    } catch (e) {
      debugPrint('Failed to refresh student: $e');
    }
  }

  /// Persist student data to SharedPreferences
  static Future<void> _saveSession(Map<String, dynamic> student) async {
    _currentStudent = student;
    studentNotifier.value = student;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_studentKey, jsonEncode(student));
  }
}
