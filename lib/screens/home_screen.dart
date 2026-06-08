import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sd_institute/screens/future_activities_screen.dart';
import 'package:sd_institute/theme/app_colors.dart';
import 'package:sd_institute/screens/drawer_wrapper.dart';
import 'package:sd_institute/widgets/advanced_carousel.dart';
import 'package:sd_institute/widgets/clay_container.dart';
import 'package:sd_institute/screens/news_screen.dart';
import 'package:sd_institute/screens/departments_screen.dart';
import 'package:sd_institute/screens/staff_screen.dart';
import 'package:sd_institute/screens/students_screen.dart';
import 'package:sd_institute/screens/schedule_screen.dart';
import 'package:sd_institute/screens/contact_screen.dart';
import 'package:sd_institute/screens/guidelines_screen.dart';
import 'package:sd_institute/screens/guidelines_hub_screen.dart';
import 'package:sd_institute/screens/notifications_screen.dart';
import 'package:sd_institute/services/auth_service.dart';
import 'package:sd_institute/screens/fees_screen.dart';
import 'package:sd_institute/screens/attendance_screen.dart';
import 'package:sd_institute/screens/login_screen.dart';
import 'package:sd_institute/screens/teacher_attendance_screen.dart';
import 'package:sd_institute/screens/teacher_homework_screen.dart';
import 'package:sd_institute/screens/student_homework_screen.dart';
import 'package:sd_institute/services/institute_service.dart';
import 'package:sd_institute/services/post_service.dart';
import 'package:sd_institute/services/notification_service.dart';
import 'package:sd_institute/utils/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _instituteName = 'پەیمانگەی SD';
  String _instituteTagline = 'SD Technical Institute';
  final String _instituteSlogan = 'داهاتووتان بنیاد دەنێین';
  List<Map<String, dynamic>> _featuredNews = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final institute = await InstituteService.getInstitute();
    final news = await PostService.getFeaturedPosts();
    if (!mounted) return;
    setState(() {
      if (institute.isNotEmpty) {
        final nm = (institute['name'] ?? '').toString().trim();
        final tag = (institute['tagline'] ?? '').toString().trim();
        _instituteName = nm.isNotEmpty ? nm : _instituteName;
        _instituteTagline = tag.isNotEmpty ? tag : _instituteTagline;
      }
      _featuredNews = news;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF000000)
          : const Color(0xFFF2F2F7),
      body: Stack(
        children: [
          // Ambient Orbs
          Positioned(
            top: -150,
            right: -100,
            child: _buildOrb(
              color: AppColors.primary.withValues(alpha: isDark ? 0.3 : 0.08),
              size: size.width,
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: _buildOrb(
              color: AppColors.accent.withValues(alpha: isDark ? 0.2 : 0.05),
              size: size.width * 0.9,
            ),
          ),
          // Global Blur Filter for deep cosmic feel
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: const SizedBox(),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(top: 16, bottom: 170),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildTopBar(context, isDark),
                  ),
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildWelcomeCard(context, isDark),
                  ),
                  const SizedBox(height: 24),
                  if (_featuredNews.isNotEmpty) ...[
                    _buildNewsCarousel(context),
                    const SizedBox(height: 24),
                  ],
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildQuickAccess(context, isDark),
                  ),
                  const SizedBox(height: 28),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildGuidelines(context, isDark),
                  ),
                  const SizedBox(height: 22),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrb({required Color color, required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: size * 0.4,
            spreadRadius: size * 0.1,
          ),
        ],
      ),
    );
  }

  // Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬ Top Bar Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
  Widget _buildTopBar(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ClayIconButton(
              icon: Icons.menu_rounded,
              onTap: () {
                HapticFeedback.lightImpact();
                DrawerWrapper.of(context)?.toggleDrawer();
              },
            )
            .animate()
            .fadeIn(duration: 400.ms, curve: Curves.easeOutCubic)
            .scale(
              begin: const Offset(0.85, 0.85),
              duration: 400.ms,
              curve: Curves.easeOutCubic,
            ),
        ValueListenableBuilder<bool>(
          valueListenable: NotificationService.hasUnreadNotifier,
          builder: (context, hasUnread, _) {
            Widget bellButton = ClayIconButton(
              icon: hasUnread
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_none_rounded,
              iconColor: hasUnread
                  ? AppColors.secondary
                  : (isDark
                        ? AppColors.hint(context)
                        : const Color(0xFF111827)),
              onTap: () async {
                HapticFeedback.selectionClick();
                await NotificationService.markAllRead();
                if (!context.mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationsScreen(),
                  ),
                );
              },
              badge: hasUnread
                  ? Positioned(
                      top: 2,
                      right: 4,
                      child:
                          Container(
                                width: 9,
                                height: 9,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF3B30),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isDark
                                        ? const Color(0xFF1C1C1E)
                                        : Colors.white,
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFFFF3B30,
                                      ).withValues(alpha: 0.6),
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              )
                              .animate(onPlay: (c) => c.repeat(reverse: true))
                              .scaleXY(
                                begin: 0.85,
                                end: 1.15,
                                duration: 1000.ms,
                              ),
                    )
                  : null,
            );

            if (hasUnread) {
              bellButton = bellButton
                  .animate(onPlay: (c) => c.repeat())
                  .shake(hz: 1.2, curve: Curves.easeInOut, duration: 2.seconds);
            }

            return bellButton
                .animate()
                .fadeIn(
                  delay: 50.ms,
                  duration: 400.ms,
                  curve: Curves.easeOutCubic,
                )
                .scale(
                  begin: const Offset(0.85, 0.85),
                  delay: 50.ms,
                  duration: 400.ms,
                  curve: Curves.easeOutCubic,
                );
          },
        ),
      ],
    );
  }

  // Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬ Institute Banner Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
  Widget _buildWelcomeCard(BuildContext context, bool isDark) {
    return _WelcomeCardWidget(
      instituteName: _instituteName,
      instituteTagline: _instituteTagline,
      instituteSlogan: _instituteSlogan,
      isDark: isDark,
    );
  }

  // Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬ News Carousel Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
  Widget _buildNewsCarousel(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _buildSectionHeader(
            context,
            localizations.get('latest_news'),
            localizations.get('see_all'),
            AppColors.accent,
            () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NewsScreen()),
              );
            },
          ),
        ).animate().fadeIn(
          delay: 200.ms,
          duration: 500.ms,
          curve: Curves.easeOutCubic,
        ),
        const SizedBox(height: 16),
        AdvancedCarousel(newsItems: _featuredNews),
      ],
    );
  }

  // Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬ Section Header helper Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    String action,
    Color actionColor,
    VoidCallback onAction,
  ) {
    final isDark = AppColors.isDark(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
                  width: 5,
                  height: 24,
                  decoration: BoxDecoration(
                    color: actionColor,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: actionColor.withValues(alpha: 0.5),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .shimmer(duration: 2.seconds, color: Colors.white),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : const Color(0xFF111827),
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        if (action.isNotEmpty)
          GestureDetector(
            onTap: onAction,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: actionColor.withValues(alpha: isDark ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: actionColor.withValues(alpha: isDark ? 0.25 : 0.15),
                  width: 0.5,
                ),
              ),
              child: Text(
                action,
                style: TextStyle(
                  color: actionColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ─── Quick Access Grid ───────────────────────────────────────────
  Widget _buildQuickAccess(BuildContext context, bool isDark) {
    final localizations = AppLocalizations.of(context);
    return ValueListenableBuilder<Map<String, dynamic>?>(
      valueListenable: AuthService.studentNotifier,
      builder: (context, student, _) {
        final isLoggedIn = student != null;
        final items = [
          {
            'title': localizations.get('departments'),
            'icon': Icons.school_rounded,
            'color': const Color(0xFF5B8DEF),
            'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DepartmentsScreen()),
            ),
          },
          {
            'title': localizations.get('news'),
            'icon': Icons.article_rounded,
            'color': const Color(0xFF48C78E),
            'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NewsScreen()),
            ),
          },
          {
            'title': localizations.get('staff'),
            'icon': Icons.people_rounded,
            'color': const Color(0xFFE8985E),
            'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const StaffScreen()),
            ),
          },
          {
            'title': localizations.get('schedule'),
            'icon': Icons.schedule_rounded,
            'color': const Color(0xFF9F7AEA),
            'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ScheduleScreen()),
            ),
          },
          if (isLoggedIn) ...[
            if (student['is_teacher'] == true) ...[
              {
                'title': localizations.get('take_attendance'),
                'icon': Icons.assignment_turned_in_rounded,
                'color': const Color(0xFF4FD1C5),
                'onTap': () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TeacherAttendanceScreen()),
                ),
              },
              {
                'title': localizations.get('submit_homeworks'),
                'icon': Icons.menu_book_rounded,
                'color': const Color(0xFF9F7AEA),
                'onTap': () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TeacherHomeworkScreen()),
                ),
              },
            ] else ...[
              {
                'title': localizations.get('my_fees'),
                'icon': Icons.account_balance_wallet_rounded,
                'color': const Color(0xFF34C759),
                'onTap': () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FeesScreen()),
                ),
              },
              {
                'title': localizations.get('my_attendance'),
                'icon': Icons.calendar_month_rounded,
                'color': const Color(0xFF4FD1C5),
                'onTap': () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AttendanceScreen()),
                ),
              },
              {
                'title': localizations.get('my_homeworks'),
                'icon': Icons.menu_book_rounded,
                'color': const Color(0xFF9F7AEA),
                'onTap': () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StudentHomeworkScreen()),
                ),
              },
            ],
            {
              'title': localizations.get('logout'),
              'icon': Icons.logout_rounded,
              'color': const Color(0xFFFF3B30),
              'onTap': () => _confirmLogout(context, localizations),
            },
          ] else ...[
            {
              'title': localizations.get('login'),
              'icon': Icons.login_rounded,
              'color': const Color(0xFF4FD1C5),
              'onTap': () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginScreen(
                    onLoginSuccess: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
            },
          ],
          {
            'title': localizations.get('contact'),
            'icon': Icons.headset_mic_rounded,
            'color': const Color(0xFFED64A6),
            'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ContactScreen()),
            ),
          },
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              context,
              localizations.get('quick_access'),
              '',
              AppColors.secondary,
              () {},
            ).animate().fadeIn(
              delay: 280.ms,
              duration: 500.ms,
              curve: Curves.easeOutCubic,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: List.generate(items.length, (index) {
                final item = items[index];
                final color = item['color'] as Color;
                return SizedBox(
                  width: (MediaQuery.of(context).size.width - 40 - 24) / 3,
                  child: ClayButton(
                    borderRadius: 28,
                    depth: 10,
                    onTap: item.containsKey('onTap')
                        ? item['onTap'] as VoidCallback
                        : null,
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 8,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [color, color.withValues(alpha: 0.7)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(
                              color: Colors.white.withValues(
                                alpha: isDark ? 0.15 : 0.35,
                              ),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: color.withValues(alpha: 0.35),
                                blurRadius: 14,
                                spreadRadius: 1,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Icon(
                            item['icon'] as IconData,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          item['title'] as String,
                          style: TextStyle(
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF111827),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(
                    delay: Duration(milliseconds: 320 + index * 50),
                    duration: 400.ms,
                    curve: Curves.easeOutCubic,
                  )
                  .slideY(
                    begin: 0.05,
                    delay: Duration(milliseconds: 320 + index * 50),
                    duration: 400.ms,
                    curve: Curves.easeOutCubic,
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }

  void _confirmLogout(BuildContext context, AppLocalizations loc) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.isDark(context) ? const Color(0xFF1C1C1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(loc.get('logout')),
        content: Text(loc.get('logout_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(loc.get('no')),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await AuthService.logout();
            },
            child: Text(loc.get('yes'), style: const TextStyle(color: Color(0xFFFF3B30))),
          ),
        ],
      ),
    );
  }

  // Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬ Guidelines Section Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
  Widget _buildGuidelines(BuildContext context, bool isDark) {
    final localizations = AppLocalizations.of(context);
    final guidelines = [
      {
        'title': localizations.get('admission_guidelines'),
        'subtitle': localizations.get('admission_subtitle'),
        'icon': Icons.assignment_rounded,
        'color': const Color(0xFF007AFF), // iOS Blue
      },
      {
        'title': localizations.get('future_activities'),
        'subtitle': localizations.get('future_activities_subtitle'),
        'icon': Icons.event_rounded,
        'color': const Color(0xFF34C759), // iOS Green
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          localizations.get('latest_guidelines'),
          localizations.get('see_all'),
          AppColors.secondary,
          () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const GuidelinesHubScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      final curved = CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      );
                      return FadeTransition(
                        opacity: curved,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.05),
                            end: Offset.zero,
                          ).animate(curved),
                          child: child,
                        ),
                      );
                    },
                transitionDuration: const Duration(milliseconds: 500),
              ),
            );
          },
        ).animate().fadeIn(
          delay: 600.ms,
          duration: 500.ms,
          curve: Curves.easeOutCubic,
        ),
        const SizedBox(height: 16),
        ...List.generate(guidelines.length, (index) {
          final item = guidelines[index];
          final color = item['color'] as Color;
          return Padding(
            padding: EdgeInsets.only(
              bottom: index < guidelines.length - 1 ? 12 : 0,
            ),
            child:
                ClayButton(
                      borderRadius: 28,
                      depth: 10,
                      onTap: () {
                        if (index == 0) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const GuidelinesScreen(),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const FutureActivitiesScreen(),
                            ),
                          );
                        }
                      },
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 18,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [color, color.withValues(alpha: 0.7)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(
                                color: Colors.white.withValues(
                                  alpha: isDark ? 0.2 : 0.35,
                                ),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.35),
                                  blurRadius: 12,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              item['icon'] as IconData,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 52),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['title'] as String,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF111827),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  item['subtitle'] as String,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? Colors.white60
                                        : Colors.black54,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          _ChevronButton(isDark: isDark),
                        ],
                      ),
                    )
                    .animate()
                    .fadeIn(
                      delay: Duration(milliseconds: 680 + index * 60),
                      duration: 400.ms,
                      curve: Curves.easeOutCubic,
                    )
                    .slideY(
                      begin: 0.03,
                      delay: Duration(milliseconds: 680 + index * 60),
                      duration: 400.ms,
                      curve: Curves.easeOutCubic,
                    ),
          );
        }),
      ],
    );
  }
}

// Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬ Welcome Card Widget Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
class _WelcomeCardWidget extends StatefulWidget {
  final String instituteName;
  final String instituteTagline;
  final String instituteSlogan;
  final bool isDark;

  const _WelcomeCardWidget({
    required this.instituteName,
    required this.instituteTagline,
    required this.instituteSlogan,
    required this.isDark,
  });

  @override
  State<_WelcomeCardWidget> createState() => _WelcomeCardWidgetState();
}

class _WelcomeCardWidgetState extends State<_WelcomeCardWidget> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        setState(() => _isPressed = true);
      },
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child:
            Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(18, 26, 18, 26),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: widget.isDark
                          ? [
                              const Color(0xFF1E1B4B), // Very dark Indigo
                              const Color(
                                0xFF311042,
                              ), // Very dark Violet/Purple
                              const Color(0xFF0F172A), // Dark Slate
                            ]
                          : [
                              const Color(0xFF6366F1), // Indigo 500
                              const Color(0xFF8B5CF6), // Purple 500
                              const Color(0xFFD946EF), // Fuchsia 500
                            ],
                    ),
                    boxShadow: [
                      // Clay-style deep shadow
                      BoxShadow(
                        color: widget.isDark
                            ? Colors.black.withValues(alpha: 0.6)
                            : AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 24,
                        offset: const Offset(4, 12),
                        spreadRadius: 2,
                      ),
                      // Clay highlight
                      BoxShadow(
                        color: widget.isDark
                            ? Colors.white.withValues(alpha: 0.03)
                            : Colors.white.withValues(alpha: 0.15),
                        blurRadius: 16,
                        offset: const Offset(-3, -3),
                        spreadRadius: 0,
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withValues(
                        alpha: widget.isDark ? 0.12 : 0.25,
                      ),
                      width: 1.5,
                    ),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Dynamic Radial Gradient Overlay
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              center: Alignment.topRight,
                              radius: 1.5,
                              colors: [
                                Colors.white.withValues(alpha: 0.12),
                                Colors.transparent,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                      // Content
                      Row(
                        textDirection: TextDirection.ltr,
                        children: [
                          Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.1,
                                      ),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/img/sd_logo.png',
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                              .animate(onPlay: (c) => c.repeat(reverse: true))
                              .scaleXY(
                                begin: 0.95,
                                end: 1.05,
                                duration: 4.seconds,
                                curve: Curves.easeInOut,
                              ),
                          const SizedBox(width: 44),
                          Expanded(
                            child: Directionality(
                              textDirection: TextDirection.rtl,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    widget.instituteName,
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    widget.instituteTagline,
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.65,
                                      ),
                                      fontSize: 13,
                                      letterSpacing: 1.2,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.12,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppColors.secondary.withValues(
                                            alpha: 0.4,
                                          ),
                                          width: 1,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.secondary
                                                .withValues(alpha: 0.1),
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                                Icons.auto_awesome,
                                                size: 14,
                                                color: AppColors.secondary,
                                              )
                                              .animate(
                                                onPlay: (controller) =>
                                                    controller.repeat(),
                                              )
                                              .shimmer(
                                                duration: 1800.ms,
                                                color: Colors.white,
                                              ),
                                          const SizedBox(width: 8),
                                          Text(
                                            widget.instituteSlogan,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
                .animate(onPlay: (controller) => controller.repeat())
                .shimmer(
                  delay: 3.seconds,
                  duration: 1800.ms,
                  color: Colors.white.withValues(alpha: 0.2),
                  angle: 0.8,
                )
                .animate()
                .fadeIn(
                  delay: 80.ms,
                  duration: 600.ms,
                  curve: Curves.easeOutQuart,
                )
                .slideY(
                  begin: 0.04,
                  delay: 80.ms,
                  duration: 600.ms,
                  curve: Curves.easeOutQuart,
                ),
      ),
    );
  }
}

// Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬ Custom Chevron Button Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
class _ChevronButton extends StatefulWidget {
  final bool isDark;
  const _ChevronButton({required this.isDark});

  @override
  State<_ChevronButton> createState() => _ChevronButtonState();
}

class _ChevronButtonState extends State<_ChevronButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final surfaceColor = isDark
        ? const Color(0xFF1E1E24)
        : const Color(0xFFE8EAF0);
    final darkShadow = isDark
        ? Colors.black.withValues(alpha: 0.5)
        : const Color(0xFFBCC3CE).withValues(alpha: 0.5);
    final lightShadow = isDark
        ? Colors.white.withValues(alpha: 0.04)
        : Colors.white.withValues(alpha: 0.7);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: surfaceColor,
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: _isPressed ? 0.1 : 0.05)
                : Colors.white.withValues(alpha: _isPressed ? 0.5 : 0.7),
            width: 1.2,
          ),
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: darkShadow,
                    blurRadius: 6,
                    offset: const Offset(2, 2),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: lightShadow,
                    blurRadius: 6,
                    offset: const Offset(-2, -2),
                    spreadRadius: 0,
                  ),
                ],
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.translationValues(
            _isPressed ? -3.0 : 0.0,
            0.0,
            0.0,
          ),
          child: Icon(
            Icons.arrow_forward_ios_rounded,
            size: 13,
            color: widget.isDark ? Colors.white70 : Colors.black54,
          ),
        ),
      ),
    );
  }
}
