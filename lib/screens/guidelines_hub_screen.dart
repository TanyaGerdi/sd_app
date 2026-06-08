import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sd_institute/theme/app_colors.dart';
import 'package:sd_institute/screens/guidelines_screen.dart';
import 'package:sd_institute/screens/future_activities_screen.dart';
import 'package:sd_institute/services/institute_service.dart';
import 'package:sd_institute/widgets/cached_image.dart';
import 'package:sd_institute/widgets/clay_container.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class GuidelinesHubScreen extends StatefulWidget {
  const GuidelinesHubScreen({super.key});

  @override
  State<GuidelinesHubScreen> createState() => _GuidelinesHubScreenState();
}

class _GuidelinesHubScreenState extends State<GuidelinesHubScreen> {
  String _registrationFormUrl = '';
  String _admissionImageUrl = '';
  String _academicYear = '2024-2025';
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Load all three in parallel for speed
    final results = await Future.wait([
      InstituteService.getRegistrationFormUrl(),
      InstituteService.getAdmissionImage(),
      InstituteService.getAcademicYear(),
    ]);

    if (!mounted) return;
    setState(() {
      _registrationFormUrl = (results[0]).trim();
      _admissionImageUrl = (results[1]).trim();
      _academicYear = (results[2]).trim().isNotEmpty ? results[2] : '2024-2025';
    });
  }

  /// Downloads the PDF to a temp file and opens it in-app with [PDFViewScreen].
  /// Shows a loading overlay while downloading, and a clean error snackbar on failure.
  Future<void> _openFormInApp() async {
    if (_registrationFormUrl.isEmpty) {
      _showError('فۆرمی تۆمارکردن ئامادە نییە');
      return;
    }

    setState(() => _isDownloading = true);

    try {
      String url = _registrationFormUrl;
      if (!url.startsWith('http')) url = 'https://$url';

      // Download to temp directory
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/registration_form.pdf';

      await Dio().download(url, filePath);

      if (!mounted) return;
      setState(() => _isDownloading = false);

      // Open in-app PDF viewer
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              PDFViewScreen(filePath: filePath, title: 'فۆرمی خۆتۆمارکردن'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isDownloading = false);
      _showError('هەڵەیەک ڕوویدا لە کردنەوەی فایل');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textDirection: TextDirection.rtl),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final size = MediaQuery.of(context).size;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: isDark
                ? const Color(0xFF000000)
                : const Color(0xFFF2F2F7),
            body: Stack(
              children: [
                // Atmospheric Background Orbs
                Positioned(
                  top: -size.height * 0.1,
                  right: -size.width * 0.3,
                  child: _buildOrb(
                    color: AppColors.primary.withValues(
                      alpha: isDark ? 0.2 : 0.1,
                    ),
                    size: size.width,
                  ),
                ),
                Positioned(
                  bottom: size.height * 0.1,
                  left: -size.width * 0.2,
                  child: _buildOrb(
                    color: AppColors.secondary.withValues(
                      alpha: isDark ? 0.15 : 0.08,
                    ),
                    size: size.width * 1.2,
                  ),
                ),
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                    child: const SizedBox(),
                  ),
                ),

                CustomScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 180,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      pinned: true,
                      leading: Padding(
                        padding: const EdgeInsets.all(8),
                        child: ClayIconButton(
                          icon: Icons.arrow_back_ios_new,
                          size: 44,
                          iconSize: 18,
                          onTap: () => Navigator.pop(context),
                        ),
                      ).animate().fadeIn(duration: 400.ms),
                      flexibleSpace: FlexibleSpaceBar(
                        titlePadding: const EdgeInsets.only(
                          right: 20,
                          bottom: 16,
                        ),
                        title: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'ڕێنماییەکان',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF111827),
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // â”€â”€ Academic year badge from DB â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(
                                  alpha: 0.15,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                              child: Text(
                                _academicYear,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1),
                        // â”€â”€ Admission image from DB â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                        background: _admissionImageUrl.isNotEmpty
                            ? Stack(
                                fit: StackFit.expand,
                                children: [
                                  CachedImage(
                                    imageUrl: _admissionImageUrl,
                                    fit: BoxFit.cover,
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          (isDark
                                                  ? const Color(0xFF000000)
                                                  : const Color(0xFFF2F2F7))
                                              .withValues(alpha: 0.3),
                                          (isDark
                                                  ? const Color(0xFF000000)
                                                  : const Color(0xFFF2F2F7))
                                              .withValues(alpha: 0.9),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : null,
                      ),
                    ),

                    // â”€â”€ Cards â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _buildGuidelineCard(
                            context: context,
                            isDark: isDark,
                            index: 0,
                            title: 'ڕێنمایی وەرگرتنی قوتابییان',
                            subtitle:
                                'کلیک بکە بۆ بینینی ڕێنمایی بوون بە قوتابی',
                            icon: Icons.assignment_rounded,
                            color: const Color(0xFF007AFF),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const GuidelinesScreen(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildGuidelineCard(
                            context: context,
                            isDark: isDark,
                            index: 1,
                            title: 'چالاکی داهاتوو',
                            subtitle: 'بینینی ڕێکخراوەکانی داهاتوو',
                            icon: Icons.event_rounded,
                            color: const Color(0xFF34C759),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const FutureActivitiesScreen(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildRegistrationCard(
                            context: context,
                            isDark: isDark,
                            index: 2,
                          ),
                        ]),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // â”€â”€ Full-screen download overlay â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          if (_isDownloading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 32,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 20),
                            Text(
                              'چاوەڕێ بکە...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF111827),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
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

  Widget _buildGuidelineCard({
    required BuildContext context,
    required bool isDark,
    required int index,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return _InteractiveGlassWidget(
          isDark: isDark,
          onTap: onTap,
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
                  child: Icon(icon, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white60 : Colors.black54,
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
          delay: Duration(milliseconds: 300 + index * 100),
          duration: 400.ms,
          curve: Curves.easeOutCubic,
        )
        .slideY(
          begin: 0.05,
          delay: Duration(milliseconds: 300 + index * 100),
          duration: 400.ms,
          curve: Curves.easeOutCubic,
        );
  }

  Widget _buildRegistrationCard({
    required BuildContext context,
    required bool isDark,
    required int index,
  }) {
    return _InteractiveGlassWidget(
          isDark: isDark,
          onTap: _openFormInApp,
          child: Container(
            decoration: BoxDecoration(
              gradient: isDark
                  ? LinearGradient(
                      colors: [
                        AppColors.secondary.withValues(alpha: 0.25),
                        AppColors.secondary.withValues(alpha: 0.08),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : LinearGradient(
                      colors: [
                        AppColors.secondary.withValues(alpha: 0.1),
                        AppColors.secondary.withValues(alpha: 0.03),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
            ),
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: AppColors.warmGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.secondary.withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.edit_note_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'فۆرمی خۆتۆمارکردن',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'کلیک بکە بۆ بینین و داگرتنی فۆرمەکە',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white60 : Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      if (!isDark)
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                        ),
                    ],
                  ),
                  child: const Icon(
                    Icons.picture_as_pdf_rounded,
                    size: 20,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 300 + index * 100),
          duration: 400.ms,
          curve: Curves.easeOutCubic,
        )
        .slideY(
          begin: 0.05,
          delay: Duration(milliseconds: 300 + index * 100),
          duration: 400.ms,
          curve: Curves.easeOutCubic,
        );
  }
}

// â”€â”€â”€ In-App PDF Viewer Screen â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class PDFViewScreen extends StatefulWidget {
  final String filePath;
  final String title;

  const PDFViewScreen({super.key, required this.filePath, required this.title});

  @override
  State<PDFViewScreen> createState() => _PDFViewScreenState();
}

class _PDFViewScreenState extends State<PDFViewScreen> {
  int _totalPages = 0;
  int _currentPage = 0;
  bool _isReady = false;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark
            ? const Color(0xFF000000)
            : const Color(0xFFF4F6F9),
        appBar: AppBar(
          backgroundColor: isDark ? const Color(0xFF0F0F12) : Colors.white,
          elevation: 0,
          leading: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.04),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 16,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                ),
              ),
              if (_isReady)
                Text(
                  'پەڕە $_currentPage لە $_totalPages',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
            ],
          ),
        ),
        body: Stack(
          children: [
            PDFView(
              filePath: widget.filePath,
              enableSwipe: true,
              swipeHorizontal: false,
              autoSpacing: true,
              pageFling: true,
              fitEachPage: true,
              onRender: (pages) => setState(() {
                _totalPages = pages ?? 0;
                _isReady = true;
              }),
              onPageChanged: (page, total) => setState(() {
                _currentPage = (page ?? 0) + 1;
                _totalPages = total ?? 0;
              }),
              onError: (error) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'هەڵەیەک ڕوویدا لە کردنەوەی PDF',
                        textDirection: TextDirection.rtl,
                      ),
                      backgroundColor: Colors.red.shade400,
                    ),
                  );
                }
              },
            ),
            if (!_isReady) const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}

// â”€â”€â”€ Reusable Interactive Glass Widget â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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
      onTapCancel: () {
        if (widget.onTap != null) setState(() => _isPressed = false);
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: ClayContainer(
          borderRadius: 24,
          depth: _isPressed ? 4 : 12,
          spread: _isPressed ? 0 : 2,
          emboss: _isPressed,
          color: widget.isDark
              ? const Color(0xFF1E1E24)
              : const Color(0xFFE8EAF0),
          child: widget.child,
        ),
      ),
    );
  }
}
