import 'dart:ui';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:sd_institute/theme/app_colors.dart';
import 'package:sd_institute/services/schedule_service.dart';
import 'package:sd_institute/widgets/cached_image.dart';
import 'package:sd_institute/widgets/clay_container.dart';

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// âš ï¸  Add this to pubspec.yaml before running:
//       flutter_pdfview: ^1.3.2
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> _schedules = [];
  bool _isLoading = true;
  late AnimationController _pulseController;
  late AnimationController _rotateController;

  static const List<List<Color>> _cardGradients = [
    [Color(0xFF6C5CE7), Color(0xFFAF52DE)],
    [Color(0xFF0EA5E9), Color(0xFF6C5CE7)],
    [Color(0xFF10B981), Color(0xFF0EA5E9)],
    [Color(0xFFF59E0B), Color(0xFFEF4444)],
    [Color(0xFFEC4899), Color(0xFFAF52DE)],
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    _loadSchedules();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  Future<void> _loadSchedules() async {
    final data = await ScheduleService.getSchedules();
    if (!mounted) return;
    setState(() {
      _schedules = data;
      _isLoading = false;
    });
  }

  List<Color> _gradientForIndex(int i) =>
      _cardGradients[i % _cardGradients.length];

  /// Opens the file entirely within the app â€” no external browser or launchUrl.
  void _openInApp(BuildContext context, String url, String title, int index) {
    if (url.isEmpty) return;
    HapticFeedback.mediumImpact();

    final lower = url.toLowerCase().split('?').first;
    final isImage =
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.webp');

    if (isImage) {
      Navigator.push(
        context,
        PageRouteBuilder(
          opaque: false,
          transitionDuration: const Duration(milliseconds: 500),
          reverseTransitionDuration: const Duration(milliseconds: 350),
          pageBuilder: (ctx, anim, _) => FadeTransition(
            opacity: anim,
            child: _InAppImageViewer(
              imageUrl: url,
              heroTag: 'schedule_img_$index',
              title: title,
            ),
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _InAppPdfViewer(url: url, title: title),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final size = MediaQuery.of(context).size;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark
            ? const Color(0xFF06060A)
            : const Color(0xFFF0F4FF),
        body: Stack(
          children: [
            _CosmicBackground(
              isDark: isDark,
              pulseController: _pulseController,
              rotateController: _rotateController,
              size: size,
            ),
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(isDark: isDark),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _isLoading
                        ? _LoadingShimmer(isDark: isDark)
                        : _schedules.isEmpty
                        ? _EmptyState(isDark: isDark)
                        : _ScheduleList(
                            schedules: _schedules,
                            isDark: isDark,
                            gradientForIndex: _gradientForIndex,
                            onOpen: (url, title, idx) =>
                                _openInApp(context, url, title, idx),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Cosmic animated background
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _CosmicBackground extends StatelessWidget {
  final bool isDark;
  final AnimationController pulseController;
  final AnimationController rotateController;
  final Size size;

  const _CosmicBackground({
    required this.isDark,
    required this.pulseController,
    required this.rotateController,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          // Large pulsing orb â€“ top right
          Positioned(
            top: -size.width * 0.3,
            right: -size.width * 0.2,
            child: AnimatedBuilder(
              animation: pulseController,
              builder: (_, _) => Container(
                width: size.width * 0.9,
                height: size.width * 0.9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF6C5CE7).withValues(
                        alpha: isDark
                            ? 0.18 + pulseController.value * 0.07
                            : 0.1 + pulseController.value * 0.04,
                      ),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Medium pulsing orb â€“ bottom left
          Positioned(
            bottom: -size.width * 0.2,
            left: -size.width * 0.2,
            child: AnimatedBuilder(
              animation: pulseController,
              builder: (_, _) => Container(
                width: size.width * 0.75,
                height: size.width * 0.75,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF0EA5E9).withValues(
                        alpha: isDark
                            ? 0.14 + pulseController.value * 0.06
                            : 0.07 + pulseController.value * 0.03,
                      ),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Rotating ring 1
          Positioned(
            top: size.height * 0.12,
            right: -size.width * 0.15,
            child: AnimatedBuilder(
              animation: rotateController,
              builder: (_, _) => Transform.rotate(
                angle: rotateController.value * 2 * math.pi,
                child: Container(
                  width: size.width * 0.5,
                  height: size.width * 0.5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(
                        0xFFAF52DE,
                      ).withValues(alpha: isDark ? 0.08 : 0.05),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Counter-rotating ring 2
          Positioned(
            bottom: size.height * 0.25,
            left: -size.width * 0.1,
            child: AnimatedBuilder(
              animation: rotateController,
              builder: (_, _) => Transform.rotate(
                angle: -rotateController.value * 2 * math.pi,
                child: Container(
                  width: size.width * 0.35,
                  height: size.width * 0.35,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(
                        0xFF0EA5E9,
                      ).withValues(alpha: isDark ? 0.07 : 0.04),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Global blur wash
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
              child: const SizedBox(),
            ),
          ),
        ],
      ),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Header
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _Header extends StatelessWidget {
  final bool isDark;
  const _Header({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child:
          Row(
                children: [
                  ClayIconButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    size: 46,
                    iconSize: 18,
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'خشتەی وانەکان',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0F0F23),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Class Schedule',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.5,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.35)
                                : Colors.black.withValues(alpha: 0.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
              .animate()
              .fadeIn(duration: 500.ms)
              .slideY(
                begin: -0.04,
                duration: 500.ms,
                curve: Curves.easeOutCubic,
              ),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Schedule list
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _ScheduleList extends StatelessWidget {
  final List<Map<String, dynamic>> schedules;
  final bool isDark;
  final List<Color> Function(int) gradientForIndex;
  final void Function(String url, String title, int idx) onOpen;

  const _ScheduleList({
    required this.schedules,
    required this.isDark,
    required this.gradientForIndex,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
      physics: const BouncingScrollPhysics(),
      itemCount: schedules.length,
      itemBuilder: (context, index) {
        final s = schedules[index];
        final deptName = s['departments'] != null
            ? (s['departments']['name_ku'] ?? 'بەش').toString()
            : 'بەش';
        final semester = (s['semester'] ?? '').toString();
        final year = (s['academic_year'] ?? '').toString();
        final fileUrl = (s['file_url'] ?? '').toString();

        return _ScheduleCard(
          index: index,
          deptName: deptName,
          semester: semester,
          year: year,
          fileUrl: fileUrl,
          gradColors: gradientForIndex(index),
          isDark: isDark,
          onTap: () => onOpen(fileUrl, deptName, index),
        );
      },
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Premium glassmorphic schedule card
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _ScheduleCard extends StatefulWidget {
  final int index;
  final String deptName;
  final String semester;
  final String year;
  final String fileUrl;
  final List<Color> gradColors;
  final bool isDark;
  final VoidCallback onTap;

  const _ScheduleCard({
    required this.index,
    required this.deptName,
    required this.semester,
    required this.year,
    required this.fileUrl,
    required this.gradColors,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_ScheduleCard> createState() => _ScheduleCardState();
}

class _ScheduleCardState extends State<_ScheduleCard> {
  bool _pressed = false;

  bool get _isImageUrl {
    final lower = widget.fileUrl.toLowerCase().split('?').first;
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.webp');
  }

  @override
  Widget build(BuildContext context) {
    final c1 = widget.gradColors[0];
    final c2 = widget.gradColors[1];

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
      child:
          AnimatedScale(
                scale: _pressed ? 0.97 : 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutBack,
                child: ClayContainer(
                  margin: const EdgeInsets.only(bottom: 20),
                  borderRadius: 28,
                  depth: _pressed ? 5 : 14,
                  spread: _pressed ? 0 : 2,
                  emboss: _pressed,
                  color: widget.isDark
                      ? const Color(0xFF1E1E24)
                      : const Color(0xFFE8EAF0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Card header
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                              colors: [
                                c1.withValues(alpha: 0.12),
                                c2.withValues(alpha: 0.04),
                              ],
                            ),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(28),
                            ),
                          ),
                          child: Row(
                            children: [
                              // Glowing gradient icon
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [c1, c2],
                                  ),
                                  borderRadius: BorderRadius.circular(17),
                                  boxShadow: [
                                    BoxShadow(
                                      color: c1.withValues(alpha: 0.55),
                                      blurRadius: 18,
                                      offset: const Offset(0, 7),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.table_chart_rounded,
                                  color: Colors.white,
                                  size: 27,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.deptName,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.3,
                                        height: 1.3,
                                        color: widget.isDark
                                            ? Colors.white
                                            : const Color(0xFF0F0F23),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 6,
                                      children: [
                                        if (widget.semester.isNotEmpty)
                                          _Pill(
                                            text: widget.semester,
                                            color: c1,
                                            isDark: widget.isDark,
                                          ),
                                        if (widget.year.isNotEmpty)
                                          _Pill(
                                            text: widget.year,
                                            color: c2,
                                            isDark: widget.isDark,
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // File type indicator
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      c1.withValues(alpha: 0.18),
                                      c2.withValues(alpha: 0.08),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(11),
                                  border: Border.all(
                                    color: c1.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Icon(
                                  _isImageUrl
                                      ? Icons.image_search_rounded
                                      : Icons.picture_as_pdf_rounded,
                                  color: c1,
                                  size: 19,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Preview area
                        if (widget.fileUrl.isNotEmpty) ...[
                          if (_isImageUrl)
                            Hero(
                              tag: 'schedule_img_${widget.index}',
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  bottom: Radius.circular(28),
                                ),
                                child: CachedImage(
                                  imageUrl: widget.fileUrl,
                                  height: 230,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          else
                            Container(
                              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    c1.withValues(alpha: 0.1),
                                    c2.withValues(alpha: 0.04),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: c1.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.picture_as_pdf_rounded,
                                    color: c1,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'تێبکە بۆ بینینی تەواوەکەی',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: widget.isDark
                                            ? Colors.white70
                                            : const Color(0xFF374151),
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_left_rounded,
                                    color: c1.withValues(alpha: 0.7),
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                ),
              )
              .animate()
              .fadeIn(
                delay: Duration(milliseconds: widget.index * 100),
                duration: 500.ms,
                curve: Curves.easeOutQuart,
              )
              .slideY(
                begin: 0.06,
                delay: Duration(milliseconds: widget.index * 100),
                duration: 500.ms,
                curve: Curves.easeOutCubic,
              ),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Colored pill badge
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _Pill extends StatelessWidget {
  final String text;
  final Color color;
  final bool isDark;
  const _Pill({required this.text, required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.11),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: isDark ? color.withValues(alpha: 0.9) : color,
        ),
      ),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Shimmer loading
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _LoadingShimmer extends StatefulWidget {
  final bool isDark;
  const _LoadingShimmer({required this.isDark});

  @override
  State<_LoadingShimmer> createState() => _LoadingShimmerState();
}

class _LoadingShimmerState extends State<_LoadingShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      itemCount: 4,
      itemBuilder: (_, i) => AnimatedBuilder(
        animation: _c,
        builder: (_, _) => Container(
          margin: const EdgeInsets.only(bottom: 20),
          height: 260,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment(-1.0 + _c.value * 2, 0),
              end: Alignment(0.0 + _c.value * 2, 0),
              colors: widget.isDark
                  ? [
                      Colors.white.withValues(alpha: 0.04),
                      Colors.white.withValues(alpha: 0.09),
                      Colors.white.withValues(alpha: 0.04),
                    ]
                  : [
                      Colors.black.withValues(alpha: 0.04),
                      Colors.black.withValues(alpha: 0.08),
                      Colors.black.withValues(alpha: 0.04),
                    ],
            ),
          ),
        ),
      ),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Empty state
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _EmptyState extends StatelessWidget {
  final bool isDark;
  const _EmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF6C5CE7).withValues(alpha: 0.2),
                  const Color(0xFFAF52DE).withValues(alpha: 0.1),
                ],
              ),
            ),
            child: Icon(
              Icons.calendar_today_outlined,
              size: 40,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.4)
                  : Colors.black.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'هیچ خشتەیەک بەردەست نییە',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.5)
                  : Colors.black.withValues(alpha: 0.4),
            ),
          ),
        ],
      ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.9, 0.9)),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// In-app image viewer (cinematic, swipe-to-dismiss, pinch-to-zoom)
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _InAppImageViewer extends StatefulWidget {
  final String imageUrl;
  final String heroTag;
  final String title;

  const _InAppImageViewer({
    required this.imageUrl,
    required this.heroTag,
    required this.title,
  });

  @override
  State<_InAppImageViewer> createState() => _InAppImageViewerState();
}

class _InAppImageViewerState extends State<_InAppImageViewer> {
  double _dragY = 0;

  @override
  Widget build(BuildContext context) {
    final scale = 1.0 - (_dragY.abs() / 1200).clamp(0.0, 0.5);
    final opacity = 1.0 - (_dragY.abs() / 600).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: opacity),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onVerticalDragUpdate: (d) => setState(() => _dragY += d.delta.dy),
        onVerticalDragEnd: (d) {
          if (_dragY.abs() > 120 || (d.primaryVelocity?.abs() ?? 0) > 400) {
            Navigator.pop(context);
          } else {
            setState(() => _dragY = 0);
          }
        },
        child: Center(
          child: Transform.scale(
            scale: scale,
            child: Transform.translate(
              offset: Offset(0, _dragY),
              child: Hero(
                tag: widget.heroTag,
                child: InteractiveViewer(
                  clipBehavior: Clip.none,
                  minScale: 0.8,
                  maxScale: 5.0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      _dragY.abs() > 10 ? 24 : 0,
                    ),
                    child: CachedImage(
                      imageUrl: widget.imageUrl,
                      fit: BoxFit.contain,
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

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// In-app PDF viewer
// Requires:  flutter_pdfview: ^1.3.2  in pubspec.yaml
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _InAppPdfViewer extends StatefulWidget {
  final String url;
  final String title;
  const _InAppPdfViewer({required this.url, required this.title});

  @override
  State<_InAppPdfViewer> createState() => _InAppPdfViewerState();
}

class _InAppPdfViewerState extends State<_InAppPdfViewer> {
  bool _isLoading = true;
  String? _localPath;
  String? _error;
  int _totalPages = 0;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _downloadPdf();
  }

  Future<void> _downloadPdf() async {
    try {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(widget.url));
      final response = await request.close();
      final bytes = <int>[];
      await for (final chunk in response) {
        bytes.addAll(chunk);
      }
      client.close();

      final filePath =
          '${Directory.systemTemp.path}/sch_${widget.url.hashCode.abs()}.pdf';
      await File(filePath).writeAsBytes(bytes, flush: true);

      if (!mounted) return;
      setState(() {
        _localPath = filePath;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark
            ? const Color(0xFF06060A)
            : const Color(0xFFF0F4FF),
        appBar: AppBar(
          backgroundColor: isDark ? const Color(0xFF0E0E18) : Colors.white,
          elevation: 0,
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF0F0F23),
                ),
              ),
              if (_totalPages > 0)
                Text(
                  'پەڕە ${_currentPage + 1} / $_totalPages',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                ),
            ],
          ),
          actions: [
            Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C5CE7), Color(0xFFAF52DE)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'PDF',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        body: _isLoading
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      color: Color(0xFF6C5CE7),
                      strokeWidth: 2.5,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'فایلەکە دادەبەزێندرێت...',
                      style: TextStyle(
                        color: isDark ? Colors.white60 : Colors.black45,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
            : _error != null
            ? _ErrorView(isDark: isDark, error: _error!)
            : _localPath != null
            ? PDFView(
                filePath: _localPath!,
                enableSwipe: true,
                swipeHorizontal: false,
                autoSpacing: true,
                pageFling: true,
                nightMode: isDark,
                backgroundColor: isDark
                    ? const Color(0xFF06060A)
                    : const Color(0xFFF0F4FF),
                onPageChanged: (page, total) {
                  if (page != null && total != null) {
                    setState(() {
                      _currentPage = page;
                      _totalPages = total;
                    });
                  }
                },
              )
            : _ErrorView(isDark: isDark, error: 'فایل نەدۆزرایەوە'),
      ),
    );
  }
}

// ——————————————————————————————————————————————————————————————————————————
// Error view
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _ErrorView extends StatelessWidget {
  final bool isDark;
  final String error;
  const _ErrorView({required this.isDark, required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 56,
            color: isDark ? Colors.white38 : Colors.black26,
          ),
          const SizedBox(height: 16),
          Text(
            'هەڵەیەک ڕوویدا',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white30 : Colors.black26,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
