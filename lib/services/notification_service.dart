import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safeen_institute/services/supabase_service.dart';
import 'package:safeen_institute/services/post_service.dart';
import 'package:safeen_institute/screens/news_detail_screen.dart';

/// Central hub for all notification logic:
///  - Local popup display (foreground FCM)
///  - Unread badge tracking (real-time via ValueNotifier)
///  - In-app toast overlay
///  - FCM token management
///  - Supabase notifications fetch
class NotificationService {
  // Real-time badge flag that any widget can listen to
  static final ValueNotifier<bool> hasUnreadNotifier = ValueNotifier(false);

  // Global key so we can show in-app overlays from anywhere
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static final FlutterLocalNotificationsPlugin _localPlugin =
      FlutterLocalNotificationsPlugin();

  // High importance channel for heads-up display on Android
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'safeen_high_importance',
    'Safeen Notifications',
    description: 'Push notifications from Safeen Institute',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
    showBadge: true,
  );

  /// Call once at app startup before everything else
  static Future<void> init() async {
    // Load persisted unread state right away
    final prefs = await SharedPreferences.getInstance();
    hasUnreadNotifier.value = prefs.getBool('has_unread_notifications') ?? false;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        handleTap(details.payload);
      },
    );

    // Create the notification channel on Android
    if (Platform.isAndroid) {
      final androidImpl = _localPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidImpl?.createNotificationChannel(_channel);
      // Also request the exact alarm permission if needed
      await androidImpl?.requestNotificationsPermission();
    }
  }

  /// Show a system notification popup + in-app toast overlay
  static Future<void> showForegroundNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    // Show the system tray notification
    final androidDetails = AndroidNotificationDetails(
      _channel.id,
      _channel.name,
      channelDescription: _channel.description,
      importance: Importance.max,
      priority: Priority.max,
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation(body),
      ticker: title,
      visibility: NotificationVisibility.public,
      category: AndroidNotificationCategory.message,
      fullScreenIntent: false,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
    );
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );

    // Mark as unread
    await _setHasUnread(true);

    // Show the in-app overlay toast on top of the current screen
    _showInAppToast(title, body, payload);
  }

  /// Beautiful in-app notification banner that slides down from the top
  static void _showInAppToast(String title, String body, String? payload) {
    final ctx = navigatorKey.currentContext;
    if (ctx == null) return;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _InAppNotificationBanner(
        title: title,
        body: body,
        onDismiss: () {
          entry.remove();
        },
        onTap: () {
          entry.remove();
          handleTap(payload);
        },
      ),
    );

    Overlay.of(ctx, rootOverlay: true).insert(entry);
  }

  /// Handle deep linking tap
  static Future<void> handleTap(String? payload) async {
    if (payload == null || payload.isEmpty) {
      navigatorKey.currentState?.pushNamed('/notifications');
      return;
    }

    String? targetId;
    String? targetType;

    // Try parsing as JSON first (for dynamic FCM payloads)
    try {
      if (payload.startsWith('{')) {
        final Map<String, dynamic> data = json.decode(payload);
        targetId = data['target_id']?.toString();
        targetType = data['target_type']?.toString();
      } else {
        // Fallback: treat as raw ID (legacy or simple)
        targetId = payload;
      }
    } catch (_) {
      targetId = payload;
    }

    if (targetId != null && targetId.isNotEmpty) {
      // Determine table based on target_type
      String table = 'news';
      if (targetType == 'student_news') {
        table = 'student_news';
      } else if (targetType == 'future_activities' || targetType == 'activities') {
        table = 'activities';
      }

      final post = await PostService.getPostById(targetId, table: table);
      if (post != null) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => NewsDetailScreen(newsItem: post),
          ),
        );
        return;
      }
    }

    // Default to notifications list if post not found or invalid
    navigatorKey.currentState?.pushNamed('/notifications');
  }

  // Persist the unread flag and update the live notifier
  static Future<void> _setHasUnread(bool value) async {
    hasUnreadNotifier.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_unread_notifications', value);
  }

  /// Convenience getters
  static Future<bool> hasUnread() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('has_unread_notifications') ?? false;
  }

  /// Clear the unread badge when user opens the notifications screen
  static Future<void> markAllRead() async {
    await _setHasUnread(false);
  }

  /// Save the device token to Supabase (called after Supabase init)
  static Future<void> registerToken(String token, String platform) async {
    try {
      await supabase.from('device_tokens').upsert({
        'token': token,
        'platform': platform,
      }, onConflict: 'token');
    } catch (_) {}
  }

  /// Fetch the latest notifications from the notifications table
  static Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      final data = await supabase
          .from('notifications')
          .select()
          .order('created_at', ascending: false)
          .limit(50)
          .timeout(const Duration(seconds: 4));
      return List<Map<String, dynamic>>.from(data);
    } catch (_) {
      return [];
    }
  }
}

/// A beautiful iOS-style in-app notification banner that slides down from the top
class _InAppNotificationBanner extends StatefulWidget {
  final String title;
  final String body;
  final VoidCallback onDismiss;
  final VoidCallback onTap;

  const _InAppNotificationBanner({
    required this.title,
    required this.body,
    required this.onDismiss,
    required this.onTap,
  });

  @override
  State<_InAppNotificationBanner> createState() => _InAppNotificationBannerState();
}

class _InAppNotificationBannerState extends State<_InAppNotificationBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  Timer? _autoDismiss;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();

    // Auto-dismiss after 4 seconds
    _autoDismiss = Timer(const Duration(seconds: 4), () {
      _dismiss();
    });
  }

  void _dismiss() {
    _autoDismiss?.cancel();
    _controller.reverse().then((_) {
      if (mounted) widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _autoDismiss?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: 0, left: 0, right: 0,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: GestureDetector(
            onTap: widget.onTap,
            onVerticalDragUpdate: (details) {
              if (details.primaryDelta != null && details.primaryDelta! < -5) {
                _dismiss();
              }
            },
            child: Container(
              margin: EdgeInsets.fromLTRB(16, topPadding + 12, 16, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F0F15).withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6C5CE7).withValues(alpha: 0.25),
                          blurRadius: 40,
                          spreadRadius: -5,
                          offset: const Offset(0, 10),
                        ),
                        BoxShadow(
                          color: const Color(0xFF00CEFF).withValues(alpha: 0.15),
                          blurRadius: 30,
                          spreadRadius: -10,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Row(
                        children: [
                          // App Icon / Logo Glowing Orb
                          Container(
                            width: 50, height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6C5CE7), Color(0xFF00CEFF)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF00CEFF).withValues(alpha: 0.6),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.school_rounded, color: Colors.white, size: 26),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Safeen Institute Branding
                                Row(
                                  children: [
                                    Text(
                                      'پەیمانگەی سەفین',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.6),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      width: 4, height: 4,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF00CEFF),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'ئێستا',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.4),
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.3,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.body,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Premium dismiss button / chevron
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: _dismiss,
                                child: Container(
                                  width: 32, height: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.close_rounded,
                                      color: Colors.white.withValues(alpha: 0.7), size: 16),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
