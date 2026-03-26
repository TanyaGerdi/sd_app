import 'dart:io';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:safeen_institute/screens/drawer_wrapper.dart';
import 'package:safeen_institute/screens/news_screen.dart';
import 'package:safeen_institute/screens/notifications_screen.dart';
import 'package:safeen_institute/theme/app_theme.dart';
import 'package:safeen_institute/theme/theme_provider.dart';
import 'package:safeen_institute/services/notification_service.dart';
import 'package:safeen_institute/services/cache_service.dart';

// Handle background FCM messages (runs in its own isolate)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  GoogleFonts.config.allowRuntimeFetching = true;

  // Pre-warm the SharedPreferences cache for instant offline reads
  await CacheService.init();

  await NewsScreen.loadSavedNews();

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

  // 4. Make sure foreground messages on iOS are displayed
  await messaging.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  // 5. Setup Supabase
  await Supabase.initialize(
    url: 'https://ikbiagrswdbbzxwxcmkn.supabase.co',
    anonKey: 'sb_publishable_0z4SwUSLgZTSVBsjh9mOeg_3f32RHEj',
  );

  // 6. NOW register the FCM token (Supabase is ready)
  final fcmToken = await messaging.getToken();
  if (fcmToken != null) {
    final platform = Platform.isIOS ? 'ios' : 'android';
    NotificationService.registerToken(fcmToken, platform);
  }

  // 7. Listen for token refreshes
  messaging.onTokenRefresh.listen((newToken) {
    final platform = Platform.isIOS ? 'ios' : 'android';
    NotificationService.registerToken(newToken, platform);
  });

  // 8. Foreground push handler — shows both system notification + in-app overlay
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final notification = message.notification;
    if (notification != null) {
      final payload = jsonEncode({
        'target_id': message.data['target_id'] ?? message.data['post_id'] ?? message.data['id'],
        'target_type': message.data['target_type'],
      });
      NotificationService.showForegroundNotification(
        title: notification.title ?? 'Safeen Institute',
        body: notification.body ?? '',
        payload: payload,
      );
    }
  });

  // 9. Handle notification tap when app was in background
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
    final payload = jsonEncode({
      'target_id': message.data['target_id'] ?? message.data['post_id'] ?? message.data['id'],
      'target_type': message.data['target_type'],
    });
    NotificationService.handleTap(payload);
  });

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  runApp(const SafeenInstituteApp());
}

class SafeenInstituteApp extends StatefulWidget {
  const SafeenInstituteApp({super.key});

  @override
  State<SafeenInstituteApp> createState() => _SafeenInstituteAppState();
}

class _SafeenInstituteAppState extends State<SafeenInstituteApp> {
  final _themeProvider = ThemeProvider();

  @override
  void dispose() {
    _themeProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeProviderInherited(
      provider: _themeProvider,
      child: AnimatedBuilder(
        animation: _themeProvider,
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
            title: 'Safeen Institute',
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
                      textDirection: TextDirection.rtl,
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
