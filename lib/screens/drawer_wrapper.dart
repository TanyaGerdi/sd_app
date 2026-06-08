import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sd_institute/screens/about_screen.dart';
import 'package:sd_institute/screens/departments_screen.dart';
import 'package:sd_institute/screens/home_screen.dart';
import 'package:sd_institute/screens/staff_screen.dart';
import 'package:sd_institute/screens/news_screen.dart' as sd_news;
import 'package:sd_institute/screens/saved_news_screen.dart';
import 'package:sd_institute/screens/contact_screen.dart';
import 'package:sd_institute/screens/login_screen.dart';
import 'package:sd_institute/screens/fees_screen.dart';
import 'package:sd_institute/screens/attendance_screen.dart';
import 'package:sd_institute/screens/teacher_attendance_screen.dart';
import 'package:sd_institute/screens/teacher_homework_screen.dart';
import 'package:sd_institute/theme/app_colors.dart';
import 'package:sd_institute/theme/theme_provider.dart';
import 'package:sd_institute/widgets/bottom_nav_bar.dart';
import 'package:sd_institute/services/institute_service.dart';
import 'package:sd_institute/services/auth_service.dart';
import 'package:sd_institute/utils/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class DrawerWrapper extends StatefulWidget {
  const DrawerWrapper({super.key});

  @override
  State<DrawerWrapper> createState() => DrawerWrapperState();

  static DrawerWrapperState? of(BuildContext context) {
    return context.findAncestorStateOfType<DrawerWrapperState>();
  }
}

class DrawerWrapperState extends State<DrawerWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late CurvedAnimation _curvedAnimation;
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const DepartmentsScreen(),
    const StaffScreen(),
    const AboutScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutExpo,
      reverseCurve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _curvedAnimation.dispose();
    _controller.dispose();
    super.dispose();
  }

  void toggleDrawer() {
    if (_controller.isCompleted) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final localeProvider = LocaleProviderInherited.of(context);
    final isRtl = localeProvider.isRtl;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0A0A14)
          : const Color(0xFF4338CA), // Deeper indigo drawer bg
      body: Stack(
        children: [
          // VisionOS Ambient Mesh Background
          if (isDark) ...[
            Positioned(
              top: -180,
              right: isRtl ? -120 : null,
              left: isRtl ? null : -120,
              child: Container(
                width: 550,
                height: 550,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.2),
                      AppColors.accent.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -100,
              left: isRtl ? -80 : null,
              right: isRtl ? null : -80,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.secondary.withValues(alpha: 0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ] else ...[
            Positioned(
              top: -100,
              right: isRtl ? -80 : null,
              left: isRtl ? null : -80,
              child: Container(
                width: 450,
                height: 450,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -150,
              left: isRtl ? -50 : null,
              right: isRtl ? null : -50,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
          // Global blur to blend orbs
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
              child: const SizedBox(),
            ),
          ),
          _buildDrawerMenu(),
          _buildAestheticLayer(
            scale: 0.58,
            slideOffset: isRtl ? -0.30 : 0.30,
            rotation: isRtl ? -0.02 : 0.02,
            opacity: 0.15,
          ),
          _buildAestheticLayer(
            scale: 0.68,
            slideOffset: isRtl ? -0.45 : 0.45,
            rotation: isRtl ? -0.04 : 0.04,
            opacity: 0.4,
          ),
          AnimatedBuilder(
            animation: _curvedAnimation,
            builder: (context, child) {
              double val = _curvedAnimation.value;
              double screenWidth = MediaQuery.of(context).size.width;
              double slide = (isRtl ? -screenWidth * 0.60 : screenWidth * 0.60) * val;
              double scale = 1 - (0.15 * val);
              double rotation = (isRtl ? -0.05 : 0.05) * val;

              return Transform(
                transform:
                    (Matrix4.identity()..setEntry(3, 2, 0.001)) *
                    Matrix4.translationValues(slide, 0.0, 0.0) *
                    Matrix4.diagonal3Values(scale, scale, 1.0) *
                    Matrix4.rotationY(rotation),
                alignment: isRtl ? Alignment.centerLeft : Alignment.centerRight,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (_controller.value > 0.0) toggleDrawer();
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(val * 32),
                    child: AbsorbPointer(
                      absorbing: val > 0.5,
                      child: _buildMainScreenContent(),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMainScreenContent() {
    return Scaffold(
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.04),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: SafeArea(
        child: SizedBox(
          height: 100,
          child:
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                child: CustomBottomNavBar(
                  currentIndex: _currentIndex,
                  onTap: (index) {
                    setState(() => _currentIndex = index);
                  },
                ),
              ).animate().slideY(
                begin: 1.2,
                end: 0.0,
                duration: 700.ms,
                curve: Curves.easeOutQuint,
              ),
        ),
      ),
    );
  }

  Widget _buildAestheticLayer({
    required double scale,
    required double slideOffset,
    required double rotation,
    required double opacity,
  }) {
    final localeProvider = LocaleProviderInherited.of(context);
    final isRtl = localeProvider.isRtl;

    return AnimatedBuilder(
      animation: _curvedAnimation,
      builder: (context, child) {
        double val = _curvedAnimation.value;
        double screenWidth = MediaQuery.of(context).size.width;
        double slide = (screenWidth * slideOffset) * val;
        double currentScale = 1 - ((1 - scale) * val);
        final dark = AppColors.isDark(context);

        return Transform(
          transform:
              (Matrix4.identity()..setEntry(3, 2, 0.001)) *
              Matrix4.translationValues(slide, 0.0, 0.0) *
              Matrix4.diagonal3Values(currentScale, currentScale, 1.0) *
              Matrix4.rotationY(rotation * val),
          alignment: isRtl ? Alignment.centerLeft : Alignment.centerRight,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(val * 32),
            child: Container(
              color:
                  (dark
                          ? Colors.white.withValues(alpha: 0.03)
                          : Colors.white.withValues(alpha: 0.08))
                      .withValues(alpha: ((opacity) * val).clamp(0.0, 1.0)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDrawerMenu() {
    final loc = AppLocalizations.of(context);
    final localeProvider = LocaleProviderInherited.of(context);
    final isRtl = localeProvider.isRtl;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 30.0),
        child: Align(
          alignment: isRtl ? Alignment.topRight : Alignment.topLeft,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.65,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                // Redesigned Drawer Header
                Row(
                  children: [
                    Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 15,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/img/sd_logo.png',
                              width: 60,
                              height: 60,
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
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.get('institute_name'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            loc.get('institute_slogan'),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _menuDivider(),
                const SizedBox(height: 12),

                // Language Switcher Row
                _buildLanguageSwitcher(loc, localeProvider),
                const SizedBox(height: 12),
                _menuDivider(),
                const SizedBox(height: 12),

                // Menu items
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.zero,
                    children: [
                      // Home - switches tab
                      _buildTabItem(
                        icon: Icons.home_rounded,
                        title: loc.get('home'),
                        tabIndex: 0,
                      ),
                      _buildTabItem(
                        icon: Icons.school_rounded,
                        title: loc.get('departments'),
                        tabIndex: 1,
                      ),
                      _buildTabItem(
                        icon: Icons.people_rounded,
                        title: loc.get('staff'),
                        tabIndex: 2,
                      ),
                      _buildTabItem(
                        icon: Icons.info_rounded,
                        title: loc.get('about'),
                        tabIndex: 3,
                      ),
                      const SizedBox(height: 8),
                      // Divider
                      _menuDivider(),
                      const SizedBox(height: 8),
                      // Push navigation pages
                      _buildPushItem(
                        icon: Icons.article_rounded,
                        title: loc.get('news'),
                        page: const sd_news.NewsScreen(),
                      ),
                      _buildPushItem(
                        icon: Icons.bookmark_rounded,
                        title: loc.get('saved'),
                        page: SavedNewsScreen(
                          savedItems: sd_news.NewsScreen.savedNews,
                        ),
                      ),
                      _buildPushItem(
                        icon: Icons.phone_rounded,
                        title: loc.get('contact'),
                        page: const ContactScreen(),
                      ),
                      const SizedBox(height: 8),
                      _menuDivider(),
                      const SizedBox(height: 8),

                      // Student Section
                      _buildStudentSection(loc),

                      const SizedBox(height: 8),
                      // Divider
                      _menuDivider(),
                      const SizedBox(height: 12),
                      // Theme toggle
                      _buildModernThemeToggle(loc),
                    ],
                  ),
                ),

                const SizedBox(height: 8),
                // Portal button
                const _PortalButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _menuDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        height: 0.5,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.0),
              Colors.white.withValues(alpha: 0.08),
              Colors.white.withValues(alpha: 0.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSwitcher(AppLocalizations loc, LocaleProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.get('language'),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildLangChip(AppLanguage.ku, 'KU', provider),
              const SizedBox(width: 8),
              _buildLangChip(AppLanguage.ar, 'AR', provider),
              const SizedBox(width: 8),
              _buildLangChip(AppLanguage.en, 'EN', provider),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLangChip(AppLanguage lang, String label, LocaleProvider provider) {
    final isSelected = provider.language == lang;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        provider.setLanguage(lang);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? Colors.white.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildStudentSection(AppLocalizations loc) {
    return ValueListenableBuilder<Map<String, dynamic>?>(
      valueListenable: AuthService.studentNotifier,
      builder: (context, student, _) {
        if (student == null) {
          // Not logged in: show login action card
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.white.withValues(alpha: 0.04),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                      child: const Icon(
                        Icons.account_circle_rounded,
                        color: Colors.white70,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        loc.get('student_account'),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    toggleDrawer();
                    Future.delayed(const Duration(milliseconds: 350), () {
                      if (!mounted) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginScreen(
                            onLoginSuccess: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      );
                    });
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: AppColors.primaryGradient,
                    ),
                    child: Center(
                      child: Text(
                        loc.get('login'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Logged in: show student/teacher info card and links
        final name = AuthService.getStudentName();
        final dept = AuthService.getDepartmentName();
        final isTeacher = AuthService.isTeacher();

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Colors.white.withValues(alpha: 0.06),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(alpha: 0.2),
                    ),
                    child: Icon(
                      isTeacher ? Icons.school_rounded : Icons.person_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isTeacher ? '${loc.get('teacher')} - $dept' : dept,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (isTeacher) ...[
                _buildStudentLink(
                  icon: Icons.checklist_rtl_rounded,
                  title: loc.get('take_attendance'),
                  color: const Color(0xFF34C759),
                  onTap: () {
                    toggleDrawer();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TeacherAttendanceScreen()),
                    );
                  },
                ),
                const SizedBox(height: 6),
                _buildStudentLink(
                  icon: Icons.assignment_rounded,
                  title: loc.get('submit_homeworks'),
                  color: const Color(0xFF5B8DEF),
                  onTap: () {
                    toggleDrawer();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TeacherHomeworkScreen()),
                    );
                  },
                ),
              ] else ...[
                _buildStudentLink(
                  icon: Icons.account_balance_wallet_rounded,
                  title: loc.get('my_fees'),
                  color: const Color(0xFF34C759),
                  onTap: () {
                    toggleDrawer();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const FeesScreen()),
                    );
                  },
                ),
                const SizedBox(height: 6),
                _buildStudentLink(
                  icon: Icons.calendar_month_rounded,
                  title: loc.get('my_attendance'),
                  color: const Color(0xFF5B8DEF),
                  onTap: () {
                    toggleDrawer();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AttendanceScreen()),
                    );
                  },
                ),
              ],
              const SizedBox(height: 6),
              _buildStudentLink(
                icon: Icons.logout_rounded,
                title: loc.get('logout'),
                color: const Color(0xFFFF3B30),
                onTap: () => _confirmLogout(loc),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStudentLink({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.chevron_left_rounded,
              color: Colors.white.withValues(alpha: 0.25),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(AppLocalizations loc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.isDark(context) ? const Color(0xFF1C1C1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(loc.get('logout')),
        content: Text(loc.get('logout_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.get('no')),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await AuthService.logout();
              setState(() {});
            },
            child: Text(loc.get('yes'), style: const TextStyle(color: Color(0xFFFF3B30))),
          ),
        ],
      ),
    );
  }

  // Tab items switch the bottom nav tab
  Widget _buildTabItem({
    required IconData icon,
    required String title,
    required int tabIndex,
  }) {
    final isActive = _currentIndex == tabIndex;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() => _currentIndex = tabIndex);
            toggleDrawer();
          },
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.white.withValues(alpha: 0.08),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isActive
                    ? Colors.white.withValues(alpha: 0.15)
                    : Colors.transparent,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                if (isActive)
                  Container(
                    width: 4,
                    height: 22,
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary.withValues(alpha: 0.8),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  )
                else
                  const SizedBox(width: 12),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.white.withValues(alpha: 0.18)
                        : Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(
                        alpha: isActive ? 0.2 : 0.05,
                      ),
                      width: 0.5,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white.withValues(
                      alpha: isActive ? 1.0 : 0.65,
                    ),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.white.withValues(
                        alpha: isActive ? 1.0 : 0.7,
                      ),
                      fontSize: 14,
                      fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Push items navigate to a new screen
  Widget _buildPushItem({
    required IconData icon,
    required String title,
    Widget? page,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            toggleDrawer();
            if (page != null) {
              Future.delayed(const Duration(milliseconds: 350), () {
                if (!mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => page),
                );
              });
            }
          },
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.white.withValues(alpha: 0.08),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Row(
              children: [
                const SizedBox(width: 12),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.05),
                      width: 0.5,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white.withValues(alpha: 0.65),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white.withValues(alpha: 0.2),
                  size: 13,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernThemeToggle(AppLocalizations loc) {
    final themeProvider = ThemeProvider.of(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;
    final activeColor = isDark ? AppColors.primary : const Color(0xFFF59E0B);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 6, bottom: 12),
            child: Text(
              loc.get('appearance'),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.58),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                height: 76,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: Colors.white.withValues(alpha: 0.08),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.18),
                      blurRadius: 22,
                      spreadRadius: -8,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    AnimatedAlign(
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeOutBack,
                      alignment: isDark
                          ? AlignmentDirectional.centerEnd
                          : AlignmentDirectional.centerStart,
                      child: FractionallySizedBox(
                        widthFactor: 0.5,
                        heightFactor: 1,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(19),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                activeColor.withValues(alpha: 0.95),
                                activeColor.withValues(alpha: 0.55),
                              ],
                            ),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.26),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: activeColor.withValues(alpha: 0.32),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildThemeSegment(
                            title: loc.get('light'),
                            icon: Icons.wb_sunny_rounded,
                            isSelected: !isDark,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              themeProvider.setThemeMode(ThemeMode.light);
                            },
                          ),
                        ),
                        Expanded(
                          child: _buildThemeSegment(
                            title: loc.get('dark'),
                            icon: Icons.nightlight_round,
                            isSelected: isDark,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              themeProvider.setThemeMode(ThemeMode.dark);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSegment({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 220),
        style: TextStyle(
          color: isSelected
              ? Colors.white
              : Colors.white.withValues(alpha: 0.52),
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.08 : 1.0,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutBack,
              child: Icon(
                icon,
                color: isSelected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.45),
                size: 23,
              ),
            ),
            const SizedBox(height: 7),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: isSelected ? 6 : 0,
                  height: 6,
                  margin: EdgeInsets.only(left: isSelected ? 6 : 0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.5),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
                Text(title),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PortalButton extends StatefulWidget {
  const _PortalButton();

  @override
  State<_PortalButton> createState() => _PortalButtonState();
}

class _PortalButtonState extends State<_PortalButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () async {
        HapticFeedback.mediumImpact();
        final url = await InstituteService.getPortalUrl();
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF4F46E5), Color(0xFF6366F1), Color(0xFF4338CA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withValues(alpha: 0.4),
                blurRadius: 16,
                spreadRadius: -2,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                AnimatedBuilder(
                  animation: _shimmerController,
                  builder: (context, child) {
                    return Positioned.fill(
                      child: FractionalTranslation(
                        translation: Offset(
                          _shimmerController.value * 2.0 - 1.0,
                          0.0,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0.0),
                                Colors.white.withValues(alpha: 0.15),
                                Colors.white.withValues(alpha: 0.0),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        transform: Matrix4.translationValues(
                          _isPressed ? -2 : 0,
                          _isPressed ? -2 : 0,
                          0,
                        ),
                        child: const Icon(
                          Icons.open_in_new_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        loc.get('portal'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
