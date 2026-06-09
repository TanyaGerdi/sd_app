import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sd_institute/theme/app_colors.dart';
import 'package:sd_institute/screens/staff_detail_screen.dart';
import 'package:sd_institute/screens/staff_screen.dart';
import 'package:sd_institute/services/staff_service.dart';
import 'package:sd_institute/widgets/cached_image.dart';
import 'package:sd_institute/widgets/clay_container.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:sd_institute/utils/app_localizations.dart';

class DepartmentDetailScreen extends StatefulWidget {
  final Map<String, dynamic> department;
  const DepartmentDetailScreen({super.key, required this.department});

  @override
  State<DepartmentDetailScreen> createState() => _DepartmentDetailScreenState();
}

class _DepartmentDetailScreenState extends State<DepartmentDetailScreen>
    with TickerProviderStateMixin {
  List<Map<String, String>> _departmentStaff = [];
  bool _isLoading = true;
  YoutubePlayerController? _youtubeController;
  late AnimationController _shimmerCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _floatCtrl;
  late ScrollController _scrollCtrl;
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollCtrl = ScrollController()
      ..addListener(() {
        setState(() => _scrollOffset = _scrollCtrl.offset);
      });
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat(reverse: true);
    _loadStaff();
    _initVideo();
  }

  void _initVideo() {
    final rawVideoUrl = widget.department['video_url']?.toString().trim() ?? '';
    if (rawVideoUrl.isNotEmpty) {
      String extractedId = rawVideoUrl;
      if (rawVideoUrl.contains('youtube.com') ||
          rawVideoUrl.contains('youtu.be')) {
        extractedId = YoutubePlayer.convertUrlToId(rawVideoUrl) ?? rawVideoUrl;
      }
      _youtubeController = YoutubePlayerController(
        initialVideoId: extractedId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          enableCaption: false,
          disableDragSeek: true,
          showLiveFullscreenButton: false,
        ),
      );
    }
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    _shimmerCtrl.dispose();
    _pulseCtrl.dispose();
    _floatCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadStaff() async {
    final deptId = widget.department['id']?.toString();
    final deptName = widget.department['name'] as String?;
    if (deptId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    final data = await StaffService.getStaffByDepartment(deptId);
    if (!mounted) return;
    setState(() {
      _departmentStaff = data.map((s) {
        final imgUrl = (s['image_url'] ?? '').toString().trim();
        return {
          'name': s['name']?.toString() ?? 'Staff',
          'role': s['role']?.toString() ?? 'پۆست',
          'image': imgUrl,
          'department': s['department']?.toString() ?? deptName ?? 'بەش',
          'email': s['email']?.toString() ?? '',
          'phone': s['phone']?.toString() ?? '',
          'degree': s['degree']?.toString() ?? '',
          'specialty': s['specialty']?.toString() ?? '',
          'academic_title': s['academic_title']?.toString() ?? '',
        };
      }).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dept = widget.department;
    final isDark = AppColors.isDark(context);
    final Color accent = dept['color'] ?? AppColors.accent;
    final size = MediaQuery.of(context).size;
    final topPad = MediaQuery.of(context).padding.top;
    final heroH = size.height * 0.44;
    final hasGallery = (dept['gallery_images'] as List?)?.isNotEmpty ?? false;
    final galleryImages = hasGallery
        ? List<String>.from(dept['gallery_images'])
        : <String>[];
    final imgUrl = (dept['image'] ?? '').toString().trim();
    final hasImage = imgUrl.isNotEmpty && imgUrl.startsWith('http');

    // Parallax factor from scroll
    final parallax = (_scrollOffset * 0.4).clamp(0.0, heroH * 0.3);
    final heroOpacity = (1.0 - (_scrollOffset / (heroH * 0.7))).clamp(0.0, 1.0);
    final localeProvider = LocaleProviderInherited.of(context);

    return Directionality(
      textDirection: localeProvider.textDirection,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: isDark
              ? const Color(0xFF050507)
              : const Color(0xFFF7F7FA),
          body: Stack(
            children: [
              // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
              //  CINEMATIC HERO with Ken Burns
              // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
              Positioned(
                top: -parallax,
                left: 0,
                right: 0,
                height: heroH + 40,
                child: Opacity(
                  opacity: heroOpacity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Hero image or gradient
                      if (hasImage)
                        CachedImage(imageUrl: imgUrl, fit: BoxFit.cover)
                            .animate(onPlay: (c) => c.repeat(reverse: true))
                            .scaleXY(
                              begin: 1.0,
                              end: 1.08,
                              duration: 22.seconds,
                              curve: Curves.easeInOutSine,
                            )
                      else
                        _buildGradientHero(accent),

                      // Atmospheric color wash
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              accent.withValues(alpha: 0.15),
                              Colors.black.withValues(alpha: 0.2),
                              Colors.black.withValues(alpha: 0.55),
                              isDark
                                  ? const Color(0xFF050507)
                                  : const Color(0xFFF7F7FA),
                            ],
                            stops: const [0.0, 0.3, 0.7, 1.0],
                          ),
                        ),
                      ),

                      // Floating accent orbs
                      AnimatedBuilder(
                        animation: _floatCtrl,
                        builder: (context, _) {
                          final v = _floatCtrl.value;
                          return Stack(
                            children: [
                              Positioned(
                                top: 60 + (v * 20),
                                left: 30 + (v * 15),
                                child: _glowOrb(accent, 70, 0.12),
                              ),
                              Positioned(
                                top: 100 + ((1 - v) * 25),
                                right: 40 + (v * 10),
                                child: _glowOrb(accent, 50, 0.08),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
              //  CONTENT (scrollable)
              // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
              SingleChildScrollView(
                controller: _scrollCtrl,
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                child: Column(
                  children: [
                    // Hero spacer
                    SizedBox(height: heroH - 60),

                    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
                    //  FLOATING GLASSMORPHIC SHEET
                    // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
                    Container(
                      constraints: BoxConstraints(minHeight: size.height * 0.7),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF0A0A10).withValues(alpha: 0.94)
                            : const Color(0xFFF2F2F7).withValues(alpha: 0.98),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(42),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: accent.withValues(
                              alpha: isDark ? 0.15 : 0.06,
                            ),
                            blurRadius: 60,
                            offset: const Offset(0, -20),
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.5 : 0.08,
                            ),
                            blurRadius: 30,
                            offset: const Offset(0, -8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(42),
                        ),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 50),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Drag handle
                                Center(
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                      top: 14,
                                      bottom: 24,
                                    ),
                                    width: 42,
                                    height: 5,
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.15)
                                          : Colors.black.withValues(
                                              alpha: 0.08,
                                            ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ).animate().fadeIn(delay: 200.ms),

                                // â”€â”€â”€ Department Identity â”€â”€â”€
                                _buildIdentityHeader(dept, accent, isDark),

                                const SizedBox(height: 30),

                                // â”€â”€â”€ Video CTA â”€â”€â”€
                                if (_youtubeController != null)
                                  _buildCinematicVideoButton(accent, isDark),

                                // â”€â”€â”€ About Section â”€â”€â”€
                                const SizedBox(height: 34),
                                _buildAboutSection(dept, accent, isDark),

                                // â”€â”€â”€ Gallery â”€â”€â”€
                                if (hasGallery) ...[
                                  const SizedBox(height: 40),
                                  _buildPremiumGallery(
                                    galleryImages,
                                    accent,
                                    isDark,
                                  ),
                                ],

                                // â”€â”€â”€ Staff â”€â”€â”€
                                const SizedBox(height: 40),
                                _buildStaffShowcase(dept, accent, isDark),

                                const SizedBox(height: 80),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
              //  BACK BUTTON (frosted glass)
              // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
              Positioned(
                top: topPad + 10,
                right: 18,
                child:
                    GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.pop(context);
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                              child: Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black.withValues(alpha: 0.3),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.15),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.2,
                                      ),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 500.ms)
                        .scale(begin: const Offset(0.8, 0.8)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  //  GRADIENT HERO (when no image)
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  Widget _buildGradientHero(Color accent) {
    return AnimatedBuilder(
      animation: _floatCtrl,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1.0 + _floatCtrl.value * 0.3, -1),
              end: Alignment(1.0 - _floatCtrl.value * 0.3, 1),
              colors: [
                accent.withValues(alpha: 0.7),
                Color.lerp(accent, const Color(0xFF1a1a2e), 0.5)!,
                const Color(0xFF0D0D15),
              ],
            ),
          ),
          child: Center(
            child: Icon(
              Icons.school_rounded,
              size: 90,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
        );
      },
    );
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  //  GLOW ORB
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  Widget _glowOrb(Color color, double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: opacity),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  //  IDENTITY HEADER
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  Widget _buildIdentityHeader(
    Map<String, dynamic> dept,
    Color accent,
    bool isDark,
  ) {
    return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Animated icon container
            AnimatedBuilder(
              animation: _pulseCtrl,
              builder: (context, child) {
                return Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        accent.withValues(
                          alpha: 0.18 + _pulseCtrl.value * 0.06,
                        ),
                        accent.withValues(alpha: 0.06),
                      ],
                    ),
                    border: Border.all(
                      color: accent.withValues(alpha: 0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(
                          alpha: 0.12 + _pulseCtrl.value * 0.08,
                        ),
                        blurRadius: 20,
                        spreadRadius: -5,
                      ),
                    ],
                  ),
                  child: Icon(
                    dept['icon'] is IconData
                        ? dept['icon']
                        : Icons.school_rounded,
                    color: accent,
                    size: 28,
                  ),
                );
              },
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dept['name'] ?? AppLocalizations.of(context).get('department_fallback'),
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      height: 1.15,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: isDark ? 0.12 : 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      dept['subtitle'] ?? AppLocalizations.of(context).get('specialty'),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: accent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.1, curve: Curves.easeOutCubic);
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  //  CINEMATIC VIDEO BUTTON
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  Widget _buildCinematicVideoButton(Color accent, bool isDark) {
    return AnimatedBuilder(
          animation: _shimmerCtrl,
          builder: (context, _) {
            return GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                final videoId = _youtubeController!.initialVideoId;
                launchUrl(
                  Uri.parse('https://www.youtube.com/watch?v=$videoId'),
                  mode: LaunchMode.externalApplication,
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: LinearGradient(
                    begin: Alignment(-1 + _shimmerCtrl.value * 3, 0),
                    end: Alignment(1 + _shimmerCtrl.value * 3, 0),
                    colors: const [
                      Color(0xFFFF6B6B),
                      Color(0xFFFF8E53),
                      Color(0xFFFF6B6B),
                      Color(0xFFFF5252),
                    ],
                    stops: const [0.0, 0.3, 0.6, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF6B6B).withValues(alpha: 0.4),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                      spreadRadius: -5,
                    ),
                    BoxShadow(
                      color: const Color(0xFFFF8E53).withValues(alpha: 0.2),
                      blurRadius: 40,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Play icon with pulse
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      AppLocalizations.of(context).get('department_video'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white70,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        )
        .animate()
        .fadeIn(delay: 200.ms, duration: 600.ms)
        .slideY(begin: 0.12, curve: Curves.easeOutCubic);
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  //  ABOUT SECTION
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  Widget _buildAboutSection(
    Map<String, dynamic> dept,
    Color accent,
    bool isDark,
  ) {
    final loc = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(loc.get('about_department'), accent, isDark, 250),
        const SizedBox(height: 16),
        // Magazine-style description card
        ClayContainer(
          borderRadius: 24,
          depth: 12,
          color: isDark ? const Color(0xFF1E1E24) : const Color(0xFFE8EAF0),
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Decorative quote mark
              Icon(
                Icons.format_quote_rounded,
                color: accent.withValues(alpha: 0.3),
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                dept['description'] ?? (
                  loc.locale == 'en'
                    ? 'Rwandz Private Technical Institute offers two years of academic education in the ${dept['name'] ?? ''} department.'
                    : loc.locale == 'ar'
                      ? 'يقدم معهد رواندز التقني الخاص سنتين من التعليم الأكاديمي في قسم ${dept['name'] ?? ""}.'
                      : 'پەیمانگەی تەکنیکی تایبەتی ڕواندز، خوێندنی ئەکادیمیی دوو ساڵە لە بەشی ${dept['name'] ?? ""} پێشکەش بە کۆمەڵگە دەکات.'
                ),
                style: TextStyle(
                  fontSize: 15,
                  height: 2.0,
                  color: isDark ? Colors.white70 : const Color(0xFF374151),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 350.ms, duration: 600.ms).slideY(begin: 0.08),
      ],
    );
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  //  SECTION HEADER (with animated accent bar)
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  Widget _sectionHeader(String title, Color accent, bool isDark, int delayMs) {
    return Row(
          children: [
            // Animated vertical accent bar
            AnimatedBuilder(
              animation: _pulseCtrl,
              builder: (context, _) {
                return Container(
                  width: 4,
                  height: 24 + (_pulseCtrl.value * 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [accent, accent.withValues(alpha: 0.3)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                letterSpacing: -0.3,
              ),
            ),
          ],
        )
        .animate()
        .fadeIn(delay: Duration(milliseconds: delayMs))
        .slideX(begin: -0.05);
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  //  PREMIUM GALLERY
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  Widget _buildPremiumGallery(List<String> images, Color accent, bool isDark) {
    final loc = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _sectionHeader(loc.get('department_gallery'), accent, isDark, 400),
            // Image count badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: isDark ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                '${images.length} ${loc.get('photos')}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: accent,
                ),
              ),
            ).animate().fadeIn(delay: 450.ms),
          ],
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: images.length,
            itemBuilder: (context, i) {
              return Padding(
                padding: EdgeInsets.only(left: i < images.length - 1 ? 16 : 0),
                child: _GalleryCard(
                  imageUrl: images[i],
                  index: i,
                  total: images.length,
                  accent: accent,
                  isDark: isDark,
                  onTap: () => _openGalleryViewer(images, i),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _openGalleryViewer(List<String> images, int initial) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        transitionDuration: const Duration(milliseconds: 400),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, anim, _) {
          return FadeTransition(
            opacity: anim,
            child: _CinematicGalleryViewer(
              images: images,
              initialIndex: initial,
            ),
          );
        },
      ),
    );
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  //  STAFF SHOWCASE
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  Widget _buildStaffShowcase(
    Map<String, dynamic> dept,
    Color accent,
    bool isDark,
  ) {
    final loc = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StaffScreen(departmentFilter: dept['name']),
              ),
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sectionHeader(loc.get('dept_staff_title'), accent, isDark, 500),
              // See all button
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: isDark ? 0.12 : 0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: accent.withValues(alpha: 0.15)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      loc.get('all'),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: accent,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: accent,
                      size: 12,
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 550.ms),
            ],
          ),
        ),

        const SizedBox(height: 22),

        SizedBox(
          height: 175,
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: accent,
                    strokeWidth: 2.5,
                  ),
                )
              : _departmentStaff.isEmpty
              ? _buildEmptyStaffState(accent, isDark)
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  clipBehavior: Clip.none,
                  itemCount: _departmentStaff.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(
                        left: index < _departmentStaff.length - 1 ? 16 : 0,
                      ),
                      child: _PremiumStaffCard(
                        person: _departmentStaff[index],
                        accent: accent,
                        isDark: isDark,
                        delay: 550 + (index * 70),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyStaffState(Color accent, bool isDark) {
    final loc = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withValues(alpha: isDark ? 0.08 : 0.05),
            ),
            child: Icon(
              Icons.group_outlined,
              size: 30,
              color: accent.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            loc.get('no_staff_found'),
            style: TextStyle(
              color: isDark ? Colors.white38 : Colors.black38,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms);
  }
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//  GALLERY CARD (3D tilt + shadow on press)
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
class _GalleryCard extends StatefulWidget {
  final String imageUrl;
  final int index;
  final int total;
  final Color accent;
  final bool isDark;
  final VoidCallback onTap;

  const _GalleryCard({
    required this.imageUrl,
    required this.index,
    required this.total,
    required this.accent,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_GalleryCard> createState() => _GalleryCardState();
}

class _GalleryCardState extends State<_GalleryCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
          onTapDown: (_) {
            HapticFeedback.lightImpact();
            setState(() => _pressed = true);
          },
          onTapUp: (_) {
            setState(() => _pressed = false);
            widget.onTap();
          },
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            width: 260,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..scaleByDouble(
                _pressed ? 0.95 : 1.0,
                _pressed ? 0.95 : 1.0,
                1,
                1,
              ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: _pressed
                      ? widget.accent.withValues(alpha: 0.3)
                      : Colors.black.withValues(
                          alpha: widget.isDark ? 0.3 : 0.1,
                        ),
                  blurRadius: _pressed ? 30 : 20,
                  offset: Offset(0, _pressed ? 12 : 8),
                  spreadRadius: _pressed ? -2 : -5,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedImage(imageUrl: widget.imageUrl, fit: BoxFit.cover),
                  // Gradient overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 80,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.55),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Counter badge
                  Positioned(
                    bottom: 14,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Text(
                            '${widget.index + 1}/${widget.total}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Zoom hint
                  Positioned(
                    bottom: 14,
                    right: 16,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.zoom_in_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 400 + (widget.index * 100)),
          duration: 500.ms,
        )
        .slideX(begin: 0.2, curve: Curves.easeOutCubic);
  }
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//  PREMIUM STAFF CARD
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
class _PremiumStaffCard extends StatefulWidget {
  final Map<String, String> person;
  final Color accent;
  final bool isDark;
  final int delay;

  const _PremiumStaffCard({
    required this.person,
    required this.accent,
    required this.isDark,
    required this.delay,
  });

  @override
  State<_PremiumStaffCard> createState() => _PremiumStaffCardState();
}

class _PremiumStaffCardState extends State<_PremiumStaffCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final img = (widget.person['image'] ?? '').trim();
    final hasImg = img.isNotEmpty && img != 'null' && img.startsWith('http');

    return GestureDetector(
          onTapDown: (_) {
            HapticFeedback.lightImpact();
            setState(() => _pressed = true);
          },
          onTapUp: (_) {
            setState(() => _pressed = false);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StaffDetailScreen(staff: widget.person),
              ),
            );
          },
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedScale(
            scale: _pressed ? 0.9 : 1.0,
            duration: const Duration(milliseconds: 350),
            curve: Curves.elasticOut,
            child: SizedBox(
              width: 115,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Avatar with animated gradient ring
                  Container(
                    padding: const EdgeInsets.all(3.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(
                        colors: [
                          widget.accent,
                          widget.accent.withValues(alpha: 0.3),
                          widget.accent.withValues(alpha: 0.6),
                          widget.accent,
                        ],
                      ),
                      boxShadow: [
                        if (_pressed)
                          BoxShadow(
                            color: widget.accent.withValues(alpha: 0.4),
                            blurRadius: 20,
                            spreadRadius: -3,
                          )
                        else
                          BoxShadow(
                            color: widget.accent.withValues(alpha: 0.2),
                            blurRadius: 14,
                            spreadRadius: -5,
                          ),
                      ],
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.isDark
                            ? const Color(0xFF0E0E12)
                            : Colors.white,
                      ),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: widget.isDark
                            ? const Color(0xFF1A1A20)
                            : const Color(0xFFF0F0F5),
                        backgroundImage: hasImg ? cachedProvider(img) : null,
                        child: hasImg
                            ? null
                            : Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      widget.accent.withValues(alpha: 0.08),
                                      widget.accent.withValues(alpha: 0.03),
                                    ],
                                  ),
                                ),
                                child: Icon(
                                  Icons.person_rounded,
                                  size: 42,
                                  color: widget.accent.withValues(alpha: 0.5),
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Name
                  Text(
                    widget.person['name'] ?? '',
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: widget.isDark
                          ? Colors.white
                          : const Color(0xFF0F172A),
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  // Role
                  Text(
                    (widget.person['role'] == null || widget.person['role']!.isEmpty || widget.person['role'] == 'پۆست')
                        ? AppLocalizations.of(context).get('role_fallback')
                        : widget.person['role']!,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: widget.accent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: widget.delay),
          duration: 500.ms,
        )
        .slideX(begin: 0.2, curve: Curves.easeOutCubic);
  }
}

// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
//  CINEMATIC GALLERY VIEWER
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
class _CinematicGalleryViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _CinematicGalleryViewer({
    required this.images,
    required this.initialIndex,
  });

  @override
  State<_CinematicGalleryViewer> createState() =>
      _CinematicGalleryViewerState();
}

class _CinematicGalleryViewerState extends State<_CinematicGalleryViewer> {
  late PageController _pc;
  late int _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _pc = PageController(initialPage: _current);
  }

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Blurred background of current image
          Positioned.fill(
            child: CachedImage(
              imageUrl: widget.images[_current],
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(color: Colors.black.withValues(alpha: 0.7)),
            ),
          ),

          // Page view
          PageView.builder(
            controller: _pc,
            itemCount: widget.images.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (_, i) {
              return GestureDetector(
                onVerticalDragEnd: (d) {
                  if (d.primaryVelocity != null &&
                      d.primaryVelocity!.abs() > 300) {
                    Navigator.pop(context);
                  }
                },
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 5.0,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CachedImage(
                          imageUrl: widget.images[i],
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // Close button
          Positioned(
            top: MediaQuery.of(context).padding.top + 14,
            right: 18,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Page dots + counter
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 30,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(widget.images.length, (i) {
                    final active = i == _current;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      width: active ? 28 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: active
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 12),
                // Counter text
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_current + 1} / ${widget.images.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
