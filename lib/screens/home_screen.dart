import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:safeen_institute/screens/future_activities_screen.dart';
import 'package:safeen_institute/theme/app_colors.dart';
import 'package:safeen_institute/screens/drawer_wrapper.dart';
import 'package:safeen_institute/widgets/advanced_carousel.dart';
import 'package:safeen_institute/screens/news_screen.dart';
import 'package:safeen_institute/screens/departments_screen.dart';
import 'package:safeen_institute/screens/staff_screen.dart';
import 'package:safeen_institute/screens/students_screen.dart';
import 'package:safeen_institute/screens/schedule_screen.dart';
import 'package:safeen_institute/screens/contact_screen.dart';
import 'package:safeen_institute/screens/guidelines_screen.dart';
import 'package:safeen_institute/screens/guidelines_hub_screen.dart';
import 'package:safeen_institute/screens/notifications_screen.dart';
import 'package:safeen_institute/services/institute_service.dart';
import 'package:safeen_institute/services/post_service.dart';
import 'package:safeen_institute/services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _instituteName = 'پەیمانگەی سەفین';
  String _instituteTagline = 'Safeen Technical Institute';
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
          ? const Color(0xFF040405)
          : const Color(0xFFF9FAFB),
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
              padding: const EdgeInsets.only(top: 16, bottom: 120),
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

  // ─── Top Bar ──────────────────────────────────────
  Widget _buildTopBar(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                DrawerWrapper.of(context)?.toggleDrawer();
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF141416).withValues(alpha: 0.6)
                          : Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.black.withValues(alpha: 0.04),
                      ),
                      boxShadow: [
                        if (!isDark)
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                      ],
                    ),
                    child: Icon(
                      Icons.menu_rounded,
                      color: isDark ? Colors.white : AppColors.primary,
                      size: 24,
                    ),
                  ),
                ),
              ),
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
              return GestureDetector(
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
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF141416).withValues(alpha: 0.6)
                                : Colors.white.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : Colors.black.withValues(alpha: 0.04),
                            ),
                            boxShadow: [
                              if (!isDark)
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                            ],
                          ),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Center(
                                child: Icon(
                                  Icons.notifications_none_rounded,
                                  color: isDark
                                      ? AppColors.hint(context)
                                      : const Color(0xFF111827),
                                  size: 24,
                                ),
                              ),
                              if (hasUnread)
                                Positioned(
                                  top: 8,
                                  right: 10,
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF3B30),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isDark ? const Color(0xFF141416) : Colors.white,
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFFF3B30).withValues(alpha: 0.6),
                                          blurRadius: 6,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                  ).animate(onPlay: (c) => c.repeat(reverse: true))
                                   .scaleXY(begin: 0.85, end: 1.15, duration: 1000.ms),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 50.ms, duration: 400.ms, curve: Curves.easeOutCubic)
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

  // ─── Institute Banner ─────────────────────────────
  Widget _buildWelcomeCard(BuildContext context, bool isDark) {
    return GestureDetector(
      onTapDown: (_) => HapticFeedback.lightImpact(),
      child: AnimatedScale(
        scale: 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child:
            Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF141822)
                        : const Color(0xFF1E3A5F),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? AppColors.primary.withValues(alpha: 0.2)
                            : const Color(0xFF1E3A5F).withValues(alpha: 0.3),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    border: isDark
                        ? Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                            width: 1,
                          )
                        : null,
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Dynamic Mesh Gradient Background overlay
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              center: Alignment.topRight,
                              radius: 1.5,
                              colors: [
                                AppColors.secondary.withValues(alpha: 0.15),
                                Colors.transparent,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                      ),
                      // Content
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _instituteName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _instituteTagline,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    fontSize: 13,
                                    letterSpacing: 1.2,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.1,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                            Icons.auto_awesome,
                                            size: 16,
                                            color: AppColors.secondary,
                                          )
                                          .animate(
                                            onPlay: (controller) =>
                                                controller.repeat(),
                                          )
                                          .shimmer(
                                            duration: 2000.ms,
                                            color: Colors.white,
                                          ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _instituteSlogan,
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: 0.95,
                                          ),
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Floating Logo Block
                          Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withValues(alpha: 0.15),
                                      Colors.white.withValues(alpha: 0.05),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.secondary.withValues(
                                        alpha: 0.2,
                                      ),
                                      blurRadius: 15,
                                      spreadRadius: -5,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.school_rounded,
                                  color: Colors.white,
                                  size: 36,
                                ),
                              )
                              .animate(
                                onPlay: (controller) =>
                                    controller.repeat(reverse: true),
                              )
                              .moveY(
                                begin: -3,
                                end: 3,
                                duration: 2000.ms,
                                curve: Curves.easeInOutSine,
                              ),
                        ],
                      ),
                    ],
                  ),
                )
                .animate()
                .shimmer(
                  duration: 3000.ms,
                  color: Colors.white.withValues(alpha: 0.1),
                  angle: 1,
                )
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

  // ─── News Carousel ───────────────────────────────
  Widget _buildNewsCarousel(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _buildSectionHeader(
            context,
            'نوێترین هەواڵەکان',
            'هەموو',
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

  // ─── Section Header helper ───────────────────────
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
              height: 22,
              decoration: BoxDecoration(
                color: actionColor,
                borderRadius: BorderRadius.circular(3),
                boxShadow: [
                  BoxShadow(
                    color: actionColor.withValues(alpha: 0.4),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
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

  // ─── Quick Access Grid ───────────────────────────
  Widget _buildQuickAccess(BuildContext context, bool isDark) {
    final items = [
      {
        'title': 'بەشەکان',
        'icon': Icons.school_rounded,
        'color': const Color(0xFF007AFF), // iOS Blue
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DepartmentsScreen()),
        ),
      },
      {
        'title': 'هەواڵەکان',
        'icon': Icons.article_rounded,
        'color': const Color(0xFF34C759), // iOS Green
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NewsScreen()),
        ),
      },
      {
        'title': 'مامۆستایان',
        'icon': Icons.people_rounded,
        'color': const Color(0xFFFF9500), // iOS Orange
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const StaffScreen()),
        ),
      },
      {
        'title': 'خشتەی وانەکان',
        'icon': Icons.schedule_rounded,
        'color': const Color(0xFFAF52DE), // iOS Purple
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ScheduleScreen()),
        ),
      },
      {
        'title': 'قوتابیان',
        'icon': Icons.person_rounded,
        'color': const Color(0xFF5AC8FA), // iOS Light Blue
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const StudentsScreen()),
        ),
      },
      {
        'title': 'پەیوەندی',
        'icon': Icons.headset_mic_rounded,
        'color': const Color(0xFFFF3B30), // iOS Red
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
          'بەستەرە خێراکان',
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
              width:
                  (MediaQuery.of(context).size.width - 40 - 24) /
                  3, // 3 columns with 12px gap
              child:
                  _InteractiveGlassWidget(
                        isDark: isDark,
                        onTap: item.containsKey('onTap')
                            ? item['onTap'] as VoidCallback
                            : null,
                        child: Padding(
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
                                  color: color,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: color.withValues(alpha: 0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  item['icon'] as IconData,
                                  color: Colors.white,
                                  size: 26,
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
  }

  // ─── Guidelines Section ──────────────────────────
  Widget _buildGuidelines(BuildContext context, bool isDark) {
    final guidelines = [
      {
        'title': 'ڕێنماییەکانی وەرگرتنی قوتابیان',
        'subtitle': 'زانیاری تەواو دەربارەی وەرگرتن دراستە',
        'icon': Icons.assignment_rounded,
        'color': const Color(0xFF007AFF), // iOS Blue
      },
      {
        'title': 'چالاکییەکانی داهاتوو',
        'subtitle': 'خشتەی بۆنە و چالاکییەکانی پەیمانگە',
        'icon': Icons.event_rounded,
        'color': const Color(0xFF34C759), // iOS Green
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          'نوێترین ڕێنماییەکان',
          'هەموو',
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
                _InteractiveGlassWidget(
                      isDark: isDark,
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
                              builder: (context) => const FutureActivitiesScreen(),
                            ),
                          );
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                item['icon'] as IconData,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 16),
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
                                  const SizedBox(height: 4),
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
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.1)
                                    : Colors.black.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 14,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
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

// ─── Reusable Interactive Glass ───────────────────
class _InteractiveGlassWidget extends StatefulWidget {
  final Widget child;
  final bool isDark;
  final VoidCallback? onTap;

  const _InteractiveGlassWidget({
    required this.child,
    required this.isDark,
    this.onTap,
  });

  @override
  State<_InteractiveGlassWidget> createState() =>
      _InteractiveGlassWidgetState();
}

class _InteractiveGlassWidgetState extends State<_InteractiveGlassWidget> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final scale = _isPressed ? 0.94 : 1.0;

    return GestureDetector(
      onTapDown: (_) {
        if (widget.onTap != null) {
          HapticFeedback.lightImpact();
          setState(() => _isPressed = true);
        }
      },
      onTapUp: (_) {
        if (widget.onTap != null) {
          setState(() => _isPressed = false);
          widget.onTap!();
        }
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuart, // Heavy apple spring
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: widget.isDark
                    ? const Color(0xFF141416).withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: widget.isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.04),
                  width: 1.5,
                ),
                boxShadow: [
                  if (!widget.isDark)
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.03),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                ],
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
