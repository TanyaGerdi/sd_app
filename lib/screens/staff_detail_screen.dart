import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:safeen_institute/theme/app_colors.dart';
import 'package:safeen_institute/services/staff_service.dart';
import 'package:safeen_institute/widgets/cached_image.dart';
import 'package:url_launcher/url_launcher.dart';

class StaffDetailScreen extends StatefulWidget {
  final Map<String, String> staff;
  const StaffDetailScreen({super.key, required this.staff});

  @override
  State<StaffDetailScreen> createState() => _StaffDetailScreenState();
}

class _StaffDetailScreenState extends State<StaffDetailScreen> {
  List<Map<String, dynamic>> _staffPrograms = [];

  @override
  void initState() {
    super.initState();
    _loadPrograms();
  }

  Future<void> _loadPrograms() async {
    final staffId = widget.staff['id'];
    if (staffId == null) return;
    
    final programs = await StaffService.getStaffPrograms(staffId);
    if (!mounted || programs.isEmpty) return;
    
    setState(() {
      _staffPrograms = programs;
    });
  }

  @override
  Widget build(BuildContext context) {
    final staff = widget.staff;
    final isDark = AppColors.isDark(context);
    final size = MediaQuery.of(context).size;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
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

            CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      // Cinematic Hero Header
                      _buildCinematicHeader(context, isDark, staff),
                      const SizedBox(height: 24),

                      // Content
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            _buildActionsBoard(context, isDark, staff),
                            const SizedBox(height: 16),
                            _buildInteractiveInfoCard(context, isDark, staff),
                            const SizedBox(height: 16),
                            _buildInteractiveAboutCard(context, isDark, staff),
                            if (_staffPrograms.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              _buildInteractiveProgramsCard(context, isDark),
                            ],
                            const SizedBox(height: 60),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
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

  Widget _buildCinematicHeader(BuildContext context, bool isDark, Map<String, String> staff) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Darkened Image Header Area
        Container(
          height: 240,
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF141416) : Colors.black87,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(40),
            ),
            image: (staff['image'] ?? '').isNotEmpty
                ? DecorationImage(
                    image: cachedProvider(staff['image']!),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withValues(alpha: 0.6),
                      BlendMode.darken,
                    ),
                  )
                : null,
          ),
          child: Stack(
            children: [
              // Shimmer overlay
              Positioned.fill(
                child:
                    Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                AppColors.accent.withValues(alpha: 0.2),
                                Colors.transparent,
                              ],
                              begin: const Alignment(-1.0, -1.0),
                              end: const Alignment(2.0, 2.0),
                            ),
                          ),
                        )
                        .animate(onPlay: (controller) => controller.repeat())
                        .shimmer(
                          duration: 3.seconds,
                          curve: Curves.easeInOutSine,
                        ),
              ),
              // Top Navigation Bar
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(context);
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
                                ),
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Floating Profile Card
        Positioned(
          top: 180,
          left: 20,
          right: 20,
          child: Column(
            children: [
              // Avatar sticking out
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.accentGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark ? const Color(0xFF141416) : Colors.white,
                  ),
                  child: CircleAvatar(
                    radius: 46,
                    backgroundColor: isDark ? Colors.black : Colors.white,
                    backgroundImage: (staff['image'] ?? '').isNotEmpty
                        ? cachedProvider(staff['image']!)
                        : null,
                    child: (staff['image'] ?? '').isEmpty
                        ? Icon(Icons.person_rounded, size: 46, color: isDark ? Colors.white54 : Colors.black26)
                        : null,
                  ),
                ),
              ).animate().scale(
                delay: 200.ms,
                duration: 600.ms,
                curve: Curves.easeOutBack,
              ),

              const SizedBox(height: 16),

              // Name and Role Plate
              ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 24,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1C1C1E).withValues(alpha: 0.6)
                              : Colors.white.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.black.withValues(alpha: 0.04),
                            width: 1.5,
                          ),
                          boxShadow: [
                            if (!isDark)
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              staff['name'] ?? '',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF111827),
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                staff['role'] ?? '',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.school_rounded,
                                  size: 16,
                                  color: isDark
                                      ? Colors.white54
                                      : Colors.black54,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  staff['department'] ?? 'بەشی IT',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .animate()
                  .fadeIn(
                    delay: 300.ms,
                    duration: 500.ms,
                    curve: Curves.easeOutCirc,
                  )
                  .slideY(
                    begin: 0.05,
                    duration: 500.ms,
                    curve: Curves.easeOutCirc,
                  ),
            ],
          ),
        ),

        // Spacer to push content down properly below the overlapping card
        const SizedBox(height: 250),
      ],
    );
  }

  Widget _buildActionsBoard(BuildContext context, bool isDark, Map<String, String> staff) {
    return Padding(
      padding: const EdgeInsets.only(top: 240), // Push down below header stack
      child:
          Row(
                children: [
                  _actionBtn(
                    context,
                    isDark,
                    Icons.phone_rounded,
                    'پەیوەندی',
                    const Color(0xFF48C78E),
                    staff['phone'] ?? '07504191546',
                  ),
                  const SizedBox(width: 12),
                  _actionBtn(
                    context,
                    isDark,
                    Icons.email_rounded,
                    'ئیمەیڵ',
                    const Color(0xFF5B8DEF),
                    staff['email'] ?? 'ihsan@safeen.edu.krd',
                  ),
                ],
              )
              .animate()
              .fadeIn(
                delay: 400.ms,
                duration: 500.ms,
                curve: Curves.easeOutCirc,
              )
              .slideY(begin: 0.1, duration: 500.ms, curve: Curves.easeOutCirc),
    );
  }

  Widget _actionBtn(
    BuildContext context,
    bool isDark,
    IconData icon,
    String label,
    Color color,
    String value,
  ) {
    return Expanded(
      child: _InteractiveGlassWidget(
        isDark: isDark,
        onTap: () async {
          HapticFeedback.lightImpact();
          if (value.isNotEmpty) {
            bool launched = false;
            try {
              if (label == 'پەیوەندی') {
                final cleaned = value.replaceAll(RegExp(r'[^0-9+]'), '');
                await launchUrl(Uri.parse('tel:$cleaned'));
                launched = true;
              } else if (label == 'ئیمەیڵ') {
                await launchUrl(Uri.parse('mailto:$value'));
                launched = true;
              }
            } catch (_) {}

            if (!launched && context.mounted) {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'کۆپی کرا: $value',
                    textDirection: TextDirection.rtl,
                  ),
                  backgroundColor: color,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              );
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInteractiveInfoCard(BuildContext context, bool isDark, Map<String, String> staff) {
    final items = [
      {
        'icon': Icons.school_rounded,
        'label': 'دوا بڕوانامە',
        'value': staff['degree'] ?? 'ماستەر لە زانستی کۆمپیوتەر',
        'color': const Color(0xFF7C4DFF),
        'copyable': false,
      },
      {
        'icon': Icons.work_rounded,
        'label': 'پسپۆڕی',
        'value': staff['specialty'] ?? 'زانستی کۆمپیوتەر',
        'color': const Color(0xFFE8985E),
        'copyable': false,
      },
      {
        'icon': Icons.phone_rounded,
        'label': 'ژمارەی مۆبایل',
        'value': staff['phone'] ?? '07504191546',
        'color': const Color(0xFF48C78E),
        'copyable': true,
      },
      {
        'icon': Icons.email_rounded,
        'label': 'ئیمەیڵ',
        'value': staff['email'] ?? 'ihsan@safeen.edu.krd',
        'color': const Color(0xFFFF6B6B),
        'copyable': true,
      },
    ];

    return _InteractiveGlassWidget(
          isDark: isDark,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle(
                  context,
                  isDark,
                  'زانیاری کەسی',
                  AppColors.accent,
                ),
                const SizedBox(height: 20),
                ...List.generate(items.length, (i) {
                  final item = items[i];
                  final color = item['color'] as Color;
                  final copyable = item['copyable'] as bool;

                  return Column(
                    children: [
                      GestureDetector(
                        onTap: copyable
                            ? () {
                                HapticFeedback.lightImpact();
                                Clipboard.setData(
                                  ClipboardData(text: item['value'] as String),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'کۆپی کرا: ${item['value']}',
                                      textDirection: TextDirection.rtl,
                                    ),
                                    backgroundColor: color,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                );
                              }
                            : null,
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                item['icon'] as IconData,
                                color: color,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['label'] as String,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? Colors.white54
                                          : Colors.black54,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item['value'] as String,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (copyable)
                              Icon(
                                Icons.copy_rounded,
                                color: isDark ? Colors.white30 : Colors.black26,
                                size: 18,
                              ),
                          ],
                        ),
                      ),
                      if (i < items.length - 1)
                        Divider(
                          height: 32,
                          color: isDark
                              ? Colors.white10
                              : Colors.black.withValues(alpha: 0.05),
                        ),
                    ],
                  );
                }),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(delay: 480.ms, duration: 500.ms, curve: Curves.easeOutCirc)
        .slideY(begin: 0.05, duration: 500.ms, curve: Curves.easeOutCirc);
  }

  Widget _buildInteractiveAboutCard(BuildContext context, bool isDark, Map<String, String> staff) {
    return _InteractiveGlassWidget(
          isDark: isDark,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle(context, isDark, 'دەربارەی', AppColors.secondary),
                const SizedBox(height: 16),
                Text(
                  (staff['bio'] ?? '').isNotEmpty 
                    ? staff['bio']! 
                    : '${staff['name'] ?? ''} مامۆستایەکی شارەزاو بەتەجربەیە لە بەشی ${staff['department'] ?? 'زانستی کۆمپیوتەر'} لە پەیمانگەی سەفین. بەرپرسیارە لە فێرکردنی قوتابییان و پەرەپێدانی بابەتەکانی ${staff['specialty'] ?? 'زانستی کۆمپیوتەر'}.',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white70 : Colors.black87,
                    height: 2.2, // Ultra legibility editorial height
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(delay: 640.ms, duration: 500.ms, curve: Curves.easeOutCirc)
        .slideY(begin: 0.05, duration: 500.ms, curve: Curves.easeOutCirc);
  }

  Widget _buildInteractiveProgramsCard(BuildContext context, bool isDark) {
    return _InteractiveGlassWidget(
      isDark: isDark,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(context, isDark, 'پڕۆگرامەکان', AppColors.primary),
            const SizedBox(height: 20),
            ..._staffPrograms.asMap().entries.map((entry) {
              final i = entry.key;
              final prog = entry.value;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.cast_for_education_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              prog['program_type'] ?? 'خوێندن',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white54 : Colors.black54,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              prog['program_name'] ?? '',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (i < _staffPrograms.length - 1)
                    Divider(
                      height: 32,
                      color: isDark
                          ? Colors.white10
                          : Colors.black.withValues(alpha: 0.05),
                    ),
                ],
              );
            }),
          ],
        ),
      ),
    )
    .animate()
    .fadeIn(delay: 700.ms, duration: 500.ms, curve: Curves.easeOutCirc)
    .slideY(begin: 0.05, duration: 500.ms, curve: Curves.easeOutCirc);
  }

  Widget _sectionTitle(
    BuildContext context,
    bool isDark,
    String title,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          width: 5,
          height: 22,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 8),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : Colors.black87,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

// Reusable Interactive Glass Container
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
    final scale = _isPressed ? 0.96 : 1.0;

    return GestureDetector(
      onTapDown: (_) {
        if (widget.onTap != null) {
          HapticFeedback.selectionClick();
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
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: widget.isDark
                    ? const Color(0xFF141416).withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(28),
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
