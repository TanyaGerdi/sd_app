import 'dart:io';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sd_institute/screens/drawer_wrapper.dart';
import 'package:sd_institute/screens/news_screen.dart';
import 'package:sd_institute/screens/notifications_screen.dart';
import 'package:sd_institute/theme/app_theme.dart';
import 'package:sd_institute/theme/theme_provider.dart';
import 'package:sd_institute/services/notification_service.dart';
import 'package:sd_institute/services/cache_service.dart';
import 'package:sd_institute/services/auth_service.dart';
import 'package:sd_institute/utils/app_localizations.dart';

// Handle background FCM messages (runs in its own isolate)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  // Extract title/body from data fields (data-only notifications)
  final title = message.data['title']?.toString() ?? 'پەیمانگەی SD';
  final body = message.data['body']?.toString() ?? '';

  if (title.isNotEmpty || body.isNotEmpty) {
    await NotificationService.init();
    await NotificationService.showSystemNotification(title: title, body: body);
  }
}

Future<void> _initFirebaseAndMessaging() async {
  if (kIsWeb) return;
  try {
    // 1. Initialize Firebase
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 2. Initialize local notifications (channel + permissions)
    await NotificationService.init();

    // 3. Request notification permission
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      criticalAlert: true,
    );

    // 4. Since we send data-only FCM messages, disable iOS auto-display
    //    to prevent any double popup. Our onMessage handler shows the
    //    custom in-app toast instead.
    await messaging.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: true,
      sound: false,
    );

    // 5. Register FCM token
    try {
      final fcmToken = await messaging.getToken();
      if (fcmToken != null) {
        final platform = Platform.isIOS ? 'ios' : 'android';
        NotificationService.registerToken(fcmToken, platform);
      }
    } catch (error) {
      debugPrint('Unable to get FCM token: $error');
    }

    // 6. Listen for token refreshes
    messaging.onTokenRefresh.listen((newToken) {
      final platform = Platform.isIOS ? 'ios' : 'android';
      NotificationService.registerToken(newToken, platform);
    });

    // 7. Foreground push handler — shows both system notification + in-app overlay
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('FCM Foreground message received: data=${message.data}, notificationTitle=${message.notification?.title}');
      final title = message.data['title']?.toString() ??
          message.notification?.title ??
          'پەیمانگەی SD';
      final body = message.data['body']?.toString() ??
          message.notification?.body ??
          '';

      debugPrint('Processing foreground notification: title="$title", body="$body"');

      if (title.isNotEmpty || body.isNotEmpty) {
        final payload = jsonEncode({
          'target_id': message.data['target_id'] ??
              message.data['post_id'] ??
              message.data['id'],
          'target_type': message.data['target_type'],
        });
        NotificationService.showForegroundNotification(
          title: title,
          body: body,
          payload: payload,
        );
      }
    });

    // 8. Handle notification tap when app was in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      final payload = jsonEncode({
        'target_id': message.data['target_id'] ?? message.data['post_id'] ?? message.data['id'],
        'target_type': message.data['target_type'],
      });
      NotificationService.handleTap(payload);
    });
  } catch (e) {
    debugPrint('Firebase/FCM initialization failed: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  GoogleFonts.config.allowRuntimeFetching = false;

  // Pre-warm the SharedPreferences cache for instant offline reads
  await CacheService.init();

  await NewsScreen.loadSavedNews();

  // Initialize Language Localization Provider
  final localeProvider = LocaleProvider();
  await localeProvider.init();

  // Load logged-in student session
  await AuthService.getStudent();

  // Initialize Firebase and Messaging in the background without blocking the UI
  _initFirebaseAndMessaging();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  runApp(
    LocaleProviderInherited(
      provider: localeProvider,
      child: const SDInstituteApp(),
    ),
  );
}

class SDInstituteApp extends StatefulWidget {
  const SDInstituteApp({super.key});

  @override
  State<SDInstituteApp> createState() => _SDInstituteAppState();
}

class _SDInstituteAppState extends State<SDInstituteApp> {
  final _themeProvider = ThemeProvider();

  @override
  void dispose() {
    _themeProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = LocaleProviderInherited.of(context);

    return ThemeProviderInherited(
      provider: _themeProvider,
      child: AnimatedBuilder(
        animation: Listenable.merge([_themeProvider, localeProvider]),
        builder: (context, child) {
          final isDark = _themeProvider.themeMode == ThemeMode.dark;
          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
              systemNavigationBarColor: Colors.transparent,
            ),
          );

          return MaterialApp(
            // Use the navigator key so NotificationService can show overlays globally
            navigatorKey: NotificationService.navigatorKey,
            title: 'SD Institute',
            locale: localeProvider.locale,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: _themeProvider.themeMode,
            themeAnimationDuration: const Duration(milliseconds: 800),
            themeAnimationCurve: Curves.fastEaseInToSlowEaseOut,
            // Named routes so notification taps can navigate
            routes: {
              '/notifications': (context) => const NotificationsScreen(),
            },
            builder: (context, child) {
              final isDarkTarget = _themeProvider.themeMode == ThemeMode.dark;
              return TweenAnimationBuilder<double>(
                tween: Tween<double>(
                  begin: isDarkTarget ? 1.0 : 0.0,
                  end: isDarkTarget ? 1.0 : 0.0,
                ),
                duration: const Duration(milliseconds: 800),
                curve: Curves.fastEaseInToSlowEaseOut,
                builder: (context, val, animatedChild) {
                  final scale = 1.0 - (0.03 * math.sin(val * math.pi));
                  return Transform.scale(
                    scale: scale,
                    child: Directionality(
                      textDirection: localeProvider.textDirection,
                      child: animatedChild ?? const SizedBox(),
                    ),
                  );
                },
                child: child,
              );
            },
            home: const DrawerWrapper(),
          );
        },
      ),
    );
  }
}
