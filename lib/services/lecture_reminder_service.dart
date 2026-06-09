import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sd_institute/services/api_service.dart';
import 'package:sd_institute/services/auth_service.dart';
import 'package:sd_institute/services/notification_service.dart';

/// Service that checks the teacher's schedule and triggers a local notification
/// 5 minutes before a class starts.
///
/// Flow:
///   1. When a teacher logs in, call [start()] to fetch their schedule and
///      begin a periodic timer (runs every 60 seconds).
///   2. Each tick, the timer compares the current day/time against the
///      stored lecture list.  If a lecture starts in exactly 5 minutes,
///      it fires a local push notification.
///   3. Call [stop()] on logout to cancel the timer.
class LectureReminderService {
  static Timer? _timer;
  static List<Map<String, dynamic>> _lectures = [];
  static final Set<String> _notifiedKeys = {}; // prevent duplicate alerts

  /// Start polling.  Safe to call multiple times — it cancels the old timer.
  static Future<void> start() async {
    stop(); // cancel any old timer

    if (!AuthService.isTeacher()) return;

    await _fetchLectures();

    // Tick once immediately, then every 60 seconds
    _checkAndNotify();
    _timer = Timer.periodic(const Duration(seconds: 60), (_) {
      _checkAndNotify();
    });

    debugPrint('[LectureReminder] Started — ${_lectures.length} lectures loaded');
  }

  /// Stop polling
  static void stop() {
    _timer?.cancel();
    _timer = null;
    _lectures = [];
    _notifiedKeys.clear();
    debugPrint('[LectureReminder] Stopped');
  }

  // ────────────────────────────────────────────────────────────────
  //  Internal
  // ────────────────────────────────────────────────────────────────

  /// Fetch the teacher's weekly schedule from the API
  static Future<void> _fetchLectures() async {
    try {
      final teacherId = AuthService.getStudentId(); // works for teachers too
      if (teacherId == null) return;

      final data = await ApiService.get(
        '/teacher_lectures',
        queryParams: {'teacher_id': teacherId.toString()},
      );

      if (data is List) {
        _lectures = data.map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        _lectures = [];
      }
    } catch (e) {
      debugPrint('[LectureReminder] Failed to fetch lectures: $e');
      _lectures = [];
    }
  }

  /// Compare current time against the lecture list
  static void _checkAndNotify() {
    if (_lectures.isEmpty) return;

    final now = DateTime.now();
    final currentDay = _dayName(now.weekday); // e.g. "Sunday"

    for (final lecture in _lectures) {
      final lectureDay = lecture['day_of_week']?.toString();
      final startTimeStr = lecture['start_time']?.toString(); // "HH:mm:ss"
      if (lectureDay == null || startTimeStr == null) continue;

      if (lectureDay != currentDay) continue;

      // Parse start_time
      final parts = startTimeStr.split(':');
      if (parts.length < 2) continue;
      final lectureHour = int.tryParse(parts[0]) ?? -1;
      final lectureMinute = int.tryParse(parts[1]) ?? -1;
      if (lectureHour < 0 || lectureMinute < 0) continue;

      final lectureTime = DateTime(
        now.year, now.month, now.day, lectureHour, lectureMinute,
      );
      final diff = lectureTime.difference(now).inMinutes;

      // Fire when between 4-5 minutes away (the 60-second window)
      if (diff >= 4 && diff <= 5) {
        final key = '${lecture['id']}_${now.year}${now.month}${now.day}';
        if (_notifiedKeys.contains(key)) continue; // already notified today
        _notifiedKeys.add(key);

        final subject = lecture['subject'] ?? '';
        final classroom = lecture['classroom'] ?? '';

        final title = 'کاتی وانەکەت نزیک بووەتەوە';
        final body =
            'ئاگاداربە! وانەی ($subject) لە ($classroom) دەستپێدەکات لە ماوەی ٥ خولەکی داهاتوودا.';

        NotificationService.showForegroundNotification(
          title: title,
          body: body,
        );
        NotificationService.showSystemNotification(title: title, body: body);

        debugPrint('[LectureReminder] Notified: $subject @ $classroom');
      }
    }
  }

  /// Convert Dart weekday (1=Monday … 7=Sunday) to the English day name
  /// stored in the DB.
  static String _dayName(int weekday) {
    const days = [
      '', // 0 unused
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[weekday];
  }
}
