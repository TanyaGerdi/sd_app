import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sd_institute/services/api_service.dart';
import 'package:sd_institute/services/auth_service.dart';
import 'package:sd_institute/services/notification_service.dart';

/// Service that checks the teacher's schedule and schedules weekly local notifications
/// 5 minutes before each class starts.
///
/// Flow:
///   1. When a teacher logs in or the app starts, call [start()] to fetch their schedule and
///      schedule weekly local notifications using native OS alarms.
///   2. The OS will fire the notifications at the correct times, even if the app is closed or in the background.
///   3. Periodically re-syncs the schedule hourly to capture any dashboard changes.
///   4. Call [stop()] on logout to cancel all scheduled notifications.
class LectureReminderService {
  static Timer? _timer;
  static List<Map<String, dynamic>> _lectures = [];

  /// Start scheduling. Safe to call multiple times.
  static Future<void> start() async {
    await stop(); // cancel any old timer and reminders

    if (!AuthService.isTeacher()) return;

    await _fetchLectures();
    await scheduleReminders();

    // Re-sync and reschedule hourly to handle admin modifications
    _timer = Timer.periodic(const Duration(hours: 1), (_) async {
      await _fetchLectures();
      await scheduleReminders();
    });

    debugPrint('[LectureReminder] Started — ${_lectures.length} lectures loaded and scheduled');
  }

  /// Stop and cancel all scheduled reminders
  static Future<void> stop() async {
    _timer?.cancel();
    _timer = null;

    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> oldIdsStr = prefs.getStringList('scheduled_lecture_notification_ids') ?? [];
      for (final idStr in oldIdsStr) {
        final id = int.tryParse(idStr);
        if (id != null) {
          await NotificationService.cancelNotification(id);
        }
      }
      await prefs.remove('scheduled_lecture_notification_ids');
    } catch (e) {
      debugPrint('[LectureReminder] Failed to cancel reminders on stop: $e');
    }

    _lectures = [];
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

  /// Schedule OS-level repeating notifications for the lectures
  static Future<void> scheduleReminders() async {
    if (_lectures.isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. Cancel previously scheduled reminders
      final List<String> oldIdsStr = prefs.getStringList('scheduled_lecture_notification_ids') ?? [];
      for (final idStr in oldIdsStr) {
        final id = int.tryParse(idStr);
        if (id != null) {
          await NotificationService.cancelNotification(id);
        }
      }

      // 2. Schedule new reminders
      final List<String> newIdsStr = [];
      for (final lecture in _lectures) {
        final id = int.tryParse(lecture['id']?.toString() ?? '');
        if (id == null) continue;

        final lectureDay = lecture['day_of_week']?.toString();
        final startTimeStr = lecture['start_time']?.toString(); // "HH:mm:ss"
        if (lectureDay == null || startTimeStr == null) continue;

        // Parse start_time
        final parts = startTimeStr.split(':');
        if (parts.length < 2) continue;
        final lectureHour = int.tryParse(parts[0]) ?? -1;
        final lectureMinute = int.tryParse(parts[1]) ?? -1;
        if (lectureHour < 0 || lectureMinute < 0) continue;

        // Calculate time 5 minutes before class starts
        int reminderHour = lectureHour;
        int reminderMinute = lectureMinute - 5;
        if (reminderMinute < 0) {
          reminderMinute += 60;
          reminderHour -= 1;
          if (reminderHour < 0) {
            reminderHour += 24;
          }
        }

        final weekday = _dayToWeekday(lectureDay);
        // If we rolled back the hour past midnight, adjust the weekday
        int reminderWeekday = weekday;
        if (lectureHour == 0 && lectureMinute < 5) {
          reminderWeekday = weekday - 1;
          if (reminderWeekday < DateTime.monday) {
            reminderWeekday = DateTime.sunday;
          }
        }

        final subject = lecture['subject'] ?? '';
        final classroom = lecture['classroom'] ?? '';

        final title = 'کاتی وانەکەت نزیک بووەتەوە';
        final body = 'ئاگاداربە! وانەی ($subject) لە ($classroom) دەستپێدەکات لە ماوەی ٥ خولەکی داهاتوودا.';

        await NotificationService.scheduleWeeklyNotification(
          id: id,
          title: title,
          body: body,
          weekday: reminderWeekday,
          hour: reminderHour,
          minute: reminderMinute,
        );

        newIdsStr.add(id.toString());
      }

      // 3. Save new IDs to prefs
      await prefs.setStringList('scheduled_lecture_notification_ids', newIdsStr);
      debugPrint('[LectureReminder] Scheduled ${newIdsStr.length} notifications');
    } catch (e) {
      debugPrint('[LectureReminder] Failed to schedule reminders: $e');
    }
  }

  /// Convert day name to DateTime weekday integer
  static int _dayToWeekday(String dayName) {
    switch (dayName.toLowerCase()) {
      case 'monday': return DateTime.monday;
      case 'tuesday': return DateTime.tuesday;
      case 'wednesday': return DateTime.wednesday;
      case 'thursday': return DateTime.thursday;
      case 'friday': return DateTime.friday;
      case 'saturday': return DateTime.saturday;
      case 'sunday': return DateTime.sunday;
      default: return DateTime.monday;
    }
  }
}
