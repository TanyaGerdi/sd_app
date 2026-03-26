import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:safeen_institute/screens/about_screen.dart';
import 'package:safeen_institute/screens/departments_screen.dart';
import 'package:safeen_institute/screens/home_screen.dart';
import 'package:safeen_institute/screens/staff_screen.dart';
import 'package:safeen_institute/screens/news_screen.dart' as safeen_news;
import 'package:safeen_institute/screens/saved_news_screen.dart';
import 'package:safeen_institute/screens/contact_screen.dart';
import 'package:safeen_institute/theme/app_colors.dart';
import 'package:safeen_institute/theme/theme_provider.dart';
import 'package:safeen_institute/widgets/bottom_nav_bar.dart';
import 'package:safeen_institute/services/institute_service.dart';
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
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF080C18) : AppColors.primary,
      body: Stack(
        children: [
          // Ambient Glowing Mesh Background for Drawer
          if (isDark)
            Positioned(
              top: -150,
              right: -100,
              child: Container(
                width: 500, // larger orb
                height: 500,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(
                        0xFF8B5CF6,
                      ).withValues(alpha: 0.25), // Stronger aura
                      AppColors.primary.withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          if (!isDark)
            Positioned(
              bottom: -150,
              left: -50,
              child: Container(
                width: 400, // larger orb
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          // Blur Filter to disperse gradients naturally
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: const SizedBox(),
            ),
          ),
          _buildDrawerMenu(),
          _buildAestheticLayer(
            scale: 0.58,
            slideOffset: -0.30,
            rotation: -0.02,
            opacity: 0.15,
          ),
          _buildAestheticLayer(
            scale: 0.68,
            slideOffset: -0.45,
            rotation: -0.04,
            opacity: 0.4,
          ),
          AnimatedBuilder(
            animation: _curvedAnimation,
            builder: (context, child) {
              double val = _curvedAnimation.value;
              double slide = -(MediaQuery.of(context).size.width * 0.60) * val;
              double scale = 1 - (0.15 * val);
              double rotation = -0.05 * val;

              return Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..translate(slide, 0.0)
                  ..scale(scale)
                  ..rotateY(rotation),
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (_controller.value > 0.0) toggleDrawer();
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(val * 28),
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
        child:
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
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
    );
  }

  Widget _buildAestheticLayer({
    required double scale,
    required double slideOffset,
    required double rotation,
    required double opacity,
  }) {
    return AnimatedBuilder(
      animation: _curvedAnimation,
      builder: (context, child) {
        double val = _curvedAnimation.value;
        double screenWidth = MediaQuery.of(context).size.width;
        double slide = (screenWidth * slideOffset) * val;
        double currentScale = 1 - ((1 - scale) * val);
        final dark = AppColors.isDark(context);

        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..translate(slide, 0.0)
            ..scale(currentScale)
            ..rotateY(rotation * val),
          alignment: Alignment.centerLeft,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(val * 28),
            child: Container(
              color: (dark ? Colors.white.withValues(alpha: 0.04) : Colors.white.withValues(alpha: 0.12)).withValues(
                alpha: ((opacity) * val).clamp(0.0, 1.0),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDrawerMenu() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 40.0),
        child: Align(
          alignment: Alignment.topRight,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.60,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                // Logo + Title
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 2,
                        ),
                      ),
                      child: const CircleAvatar(
                        radius: 26,
                        backgroundColor: Color(0xFF1B4370),
                        child: Icon(
                          Icons.school_rounded,
                          size: 28,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'پەیمانگەی سەفین',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                           'Safeen Technical Institute',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 12,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.0),
                        Colors.white.withValues(alpha: 0.12),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Menu items
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.zero,
                    children: [
                      // Home - switches tab
                      _buildTabItem(
                        icon: Icons.home_rounded,
                        title: 'پەڕەی سەرەکی',
                        tabIndex: 0,
                      ),
                      _buildTabItem(
                        icon: Icons.school_rounded,
                        title: 'بەشەکان',
                        tabIndex: 1,
                      ),
                      _buildTabItem(
                        icon: Icons.people_rounded,
                        title: 'مامۆستایان',
                        tabIndex: 2,
                      ),
                      _buildTabItem(
                        icon: Icons.info_rounded,
                        title: 'دەربارەی ئێمە',
                        tabIndex: 3,
                      ),
                      const SizedBox(height: 8),
                      // Divider
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Container(
                          height: 1,
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
                      ),
                      const SizedBox(height: 8),
                      // Push navigation pages
                      _buildPushItem(
                        icon: Icons.article_rounded,
                        title: 'هەواڵەکان',
                        page: const safeen_news.NewsScreen(),
                      ),
                      _buildPushItem(
                        icon: Icons.bookmark_rounded,
                        title: 'پاشەکەوتکراوەکان',
                        page: SavedNewsScreen(
                          savedItems: safeen_news.NewsScreen.savedNews,
                        ),
                      ),
                      _buildPushItem(
                        icon: Icons.phone_rounded,
                        title: 'پەیوەندی',
                        page: const ContactScreen(),
                      ),
                      const SizedBox(height: 8),
                      // Divider
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Container(
                          height: 1,
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
                      ),
                      const SizedBox(height: 12),
                      // Theme toggle
                      _buildThemeToggle(),
                    ],
                  ),
                ),

                const SizedBox(height: 8),
                // Portal button
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      onTap: () async {
                        HapticFeedback.lightImpact();
                        final url = await InstituteService.getPortalUrl();
                        final uri = Uri.parse(url);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                      },
                      borderRadius: BorderRadius.circular(14),
                      splashColor: Colors.white.withValues(alpha: 0.1),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.open_in_new_rounded,
                              color: Colors.white.withValues(alpha: 0.7),
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'پۆرتاڵی پەیمانگە',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
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

  // Tab items switch the bottom nav tab
  Widget _buildTabItem({
    required IconData icon,
    required String title,
    required int tabIndex,
  }) {
    final isActive = _currentIndex == tabIndex;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() => _currentIndex = tabIndex);
            toggleDrawer();
          },
          borderRadius: BorderRadius.circular(14),
          splashColor: Colors.white.withValues(alpha: 0.08),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 14,
            ), // boosted hit area
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 42, // boosted size
                  height: 42,
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.white.withValues(alpha: 0.18)
                        : Colors.white.withValues(
                            alpha: 0.05,
                          ), // cleaner contrast
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white.withValues(alpha: isActive ? 1.0 : 0.8),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16), // nicer spacing
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.white.withValues(
                        alpha: isActive ? 1.0 : 0.85,
                      ),
                      fontSize: 15, // boosted font
                      letterSpacing: 0.3, // structural feel
                      fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                ),
                if (isActive)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary,
                          blurRadius: 4,
                        ), // add glow
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

  // Push items navigate to a new screen
  Widget _buildPushItem({
    required IconData icon,
    required String title,
    Widget? page,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
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
          borderRadius: BorderRadius.circular(14),
          splashColor: Colors.white.withValues(alpha: 0.08),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 14,
            ), // increased padding
            child: Row(
              children: [
                Container(
                  width: 42, // slightly larger
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white.withValues(alpha: 0.8),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 15, // boosted font
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white.withValues(alpha: 0.2),
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeToggle() {
    final themeProvider = ThemeProvider.of(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 6, bottom: 12),
            child: Text(
              'ڕووکاری ئەپ',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _buildAuraCard(
                  title: 'ڕووناکی',
                  icon: Icons.light_mode_rounded,
                  isSelected: !isDark,
                  auraColor: const Color(0xFFF59E0B),
                  onTap: () {
                    HapticFeedback.lightImpact(); // Less aggressive haptic
                    themeProvider.setThemeMode(ThemeMode.light);
                  },
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildAuraCard(
                  title: 'تاریکی',
                  icon: Icons.dark_mode_rounded,
                  isSelected: isDark,
                  auraColor: const Color(0xFF8B5CF6),
                  onTap: () {
                    HapticFeedback.lightImpact(); // Less aggressive haptic
                    themeProvider.setThemeMode(ThemeMode.dark);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAuraCard({
    required String title,
    required IconData icon,
    required bool isSelected,
    required Color auraColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.fastEaseInToSlowEaseOut,
        height: 72,
        decoration: BoxDecoration(
          color: isSelected
              ? auraColor.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? auraColor.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.05),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: auraColor.withValues(alpha: 0.4),
                    blurRadius: 15,
                    spreadRadius: 1,
                    offset: const Offset(0, 5),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 400),
              curve: Curves.fastEaseInToSlowEaseOut,
              child: Icon(
                icon,
                color: isSelected
                    ? auraColor
                    : Colors.white.withValues(alpha: 0.4),
                size: 24,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.4),
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
