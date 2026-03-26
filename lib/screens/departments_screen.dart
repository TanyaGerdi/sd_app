import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:safeen_institute/theme/app_colors.dart';
import 'package:safeen_institute/screens/department_detail_screen.dart';
import 'package:safeen_institute/services/department_service.dart';
import 'package:safeen_institute/widgets/cached_image.dart';

class DepartmentsScreen extends StatefulWidget {
  const DepartmentsScreen({super.key});

  @override
  State<DepartmentsScreen> createState() => _DepartmentsScreenState();
}

class _DepartmentsScreenState extends State<DepartmentsScreen> {
  // Fallback defaults
  List<Map<String, dynamic>> departments = [
    {
      'name': 'پەرستاری',
      'subtitle': 'تایبەتمەندی پزیشکی',
      'students': '٨٥',
      'teachers': '٧',
      'icon': Icons.medical_services_rounded,
      'color': Color(0xFFFF6B6B),
      'image':
          '',
    },
    {
      'name': 'دەرمانسازی',
      'subtitle': 'ئەندازیاری دەرمان',
      'students': '٧٢',
      'teachers': '٦',
      'icon': Icons.local_pharmacy_rounded,
      'color': Color(0xFF26DE81),
      'image': '',
    },
    {
      'name': 'ئینگلیزی',
      'subtitle': 'زمان و وێنەکاری',
      'students': '٩٠',
      'teachers': '٥',
      'icon': Icons.language_rounded,
      'color': Color(0xFFFD9644),
      'image': '',
    },
    {
      'name': 'تەکنەلۆجیای زانیاری',
      'subtitle': 'پرۆگرامسازی و تۆڕ',
      'students': '١١٠',
      'teachers': '٨',
      'icon': Icons.computer_rounded,
      'color': Color(0xFF5B8DEF),
      'image': '',
    },
    {
      'name': 'ژمێریاری',
      'subtitle': 'داراییی و ئابوور',
      'students': '٧٨',
      'teachers': '٥',
      'icon': Icons.calculate_rounded,
      'color': Color(0xFF45AAF2),
      'image': '',
    },
    {
      'name': 'کارگێڕی کار',
      'subtitle': 'بەڕێوەبردن و پلاندانان',
      'students': '٦٥',
      'teachers': '٤',
      'icon': Icons.business_center_rounded,
      'color': Color(0xFFA55EEA),
      'image': '',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadDepartments();
  }

  Future<void> _loadDepartments() async {
    final data = await DepartmentService.getDepartments();
    if (!mounted || data.isEmpty) return;
    
    // Always call setState to update UI (either list is filled, or empty state is shown)
    setState(() {
      departments = data.map((d) {
        // Map icon strings to IconData if possible, or use default
        IconData iconData = Icons.school_rounded; // Default fallback
        if (d['icon'] == 'medical_services_rounded') {
          iconData = Icons.medical_services_rounded;
        } else if (d['icon'] == 'local_pharmacy_rounded')
          iconData = Icons.local_pharmacy_rounded;
        else if (d['icon'] == 'language_rounded')
          iconData = Icons.language_rounded;
        else if (d['icon'] == 'computer_rounded')
          iconData = Icons.computer_rounded;
        else if (d['icon'] == 'calculate_rounded')
          iconData = Icons.calculate_rounded;
        else if (d['icon'] == 'business_center_rounded')
          iconData = Icons.business_center_rounded;

        // Parse color
        Color parsedColor = const Color(0xFF5B8DEF); // Default
        if (d['color'] != null) {
          try {
            parsedColor = Color(
              int.parse((d['color'] as String).replaceFirst('#', '0xFF')),
            );
          } catch (_) {}
        }

        final imgUrl = (d['image_url'] ?? '').toString().trim();
        return {
          'id': d['id'],
          'name': d['name']?.toString().isNotEmpty == true
              ? d['name']
              : 'بەشی زانستی',
          'subtitle': d['subtitle']?.toString().isNotEmpty == true
              ? d['subtitle']
              : 'تایبەتمەندی',
          'description': d['description']?.toString().isNotEmpty == true
              ? d['description']
              : '',
          'students': d['students_count']?.toString() ?? '٠',
          'teachers': d['teachers_count']?.toString() ?? '٠',
          'icon': iconData,
          'color': parsedColor,
          'video_url': d['video_url'] ?? '',
          'gallery_images': d['gallery_images'] ?? [],
          'image': imgUrl.isNotEmpty
              ? imgUrl
              : '',
        };
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final canGoBack = Navigator.canPop(context);
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
              top: -100,
              right: -50,
              child: _buildOrb(
                color: AppColors.primary.withValues(
                  alpha: isDark ? 0.25 : 0.08,
                ),
                size: size.width * 0.9,
              ),
            ),
            Positioned(
              bottom: 150,
              left: -100,
              child: _buildOrb(
                color: AppColors.accent.withValues(alpha: isDark ? 0.15 : 0.05),
                size: size.width,
              ),
            ),
            // Global Blur Filter for deep cosmic feel
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: const SizedBox(),
              ),
            ),

            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                bottom: 120,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child:
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (canGoBack) ...[
                              GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  Navigator.pop(context);
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 10,
                                      sigmaY: 10,
                                    ),
                                    child: Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? const Color(
                                                0xFF141416,
                                              ).withValues(alpha: 0.6)
                                            : Colors.white.withValues(
                                                alpha: 0.7,
                                              ),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: isDark
                                              ? Colors.white.withValues(
                                                  alpha: 0.08,
                                                )
                                              : Colors.black.withValues(
                                                  alpha: 0.04,
                                                ),
                                        ),
                                        boxShadow: [
                                          if (!isDark)
                                            BoxShadow(
                                              color: AppColors.primary
                                                  .withValues(alpha: 0.03),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                        ],
                                      ),
                                      child: Icon(
                                        Icons.arrow_back_ios_new,
                                        size: 18,
                                        color: isDark
                                            ? Colors.white
                                            : AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                            ],
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'بەشەکانی پەیمانگە',
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w900,
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF111827),
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${departments.length} بەشی تایبەت',
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black54,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ).animate().fadeIn(
                          duration: 400.ms,
                          curve: Curves.easeOutCubic,
                        ),
                  ),

                  const SizedBox(height: 24),

                  // All departments
                  ...List.generate(departments.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      child: _InteractiveDepartmentCard(
                        dept: departments[index],
                        index: index,
                        isDark: isDark,
                      ),
                    );
                  }),
                ],
              ),
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
}

class _InteractiveDepartmentCard extends StatefulWidget {
  final Map<String, dynamic> dept;
  final int index;
  final bool isDark;

  const _InteractiveDepartmentCard({
    required this.dept,
    required this.index,
    required this.isDark,
  });

  @override
  State<_InteractiveDepartmentCard> createState() =>
      _InteractiveDepartmentCardState();
}

class _InteractiveDepartmentCardState
    extends State<_InteractiveDepartmentCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final Color color = widget.dept['color'];

    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.selectionClick();
        setState(() => _isPressed = true);
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                DepartmentDetailScreen(department: widget.dept),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  final curved = CurvedAnimation(
                    parent: animation,
                    curve: Curves.fastEaseInToSlowEaseOut,
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
      onTapCancel: () {
        setState(() => _isPressed = false);
      },
      child:
          AnimatedScale(
                scale: _isPressed ? 0.94 : 1.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutQuart, // Heavy apple spring
                child: Container(
                  height: 190,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    image: DecorationImage(
                      image: cachedProvider(widget.dept['image']),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(
                          alpha: widget.isDark ? 0.15 : 0.25,
                        ),
                        blurRadius: _isPressed ? 10 : 25,
                        spreadRadius: _isPressed ? 0 : 2,
                        offset: Offset(0, _isPressed ? 4 : 12),
                      ),
                    ],
                    // A subtle glow ring border
                    border: Border.all(
                      color: color.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          color.withValues(alpha: 0.95),
                          color.withValues(alpha: 0.3),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.65, 1.0],
                      ),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 10,
                                  sigmaY: 10,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.3,
                                      ),
                                    ),
                                  ),
                                  child: Icon(
                                    widget.dept['icon'],
                                    color: Colors.white,
                                    size: 26,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.dept['name'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.dept['subtitle'],
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.85,
                                      ),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            _badge(
                              Icons.people_rounded,
                              '${widget.dept['students']} قوتابی',
                            ),
                            const SizedBox(width: 12),
                            _badge(
                              Icons.person_rounded,
                              '${widget.dept['teachers']} مامۆستا',
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
                delay: Duration(milliseconds: 100 + (widget.index * 80)),
                duration: 800.ms,
                curve: Curves.fastEaseInToSlowEaseOut,
              )
              .slideY(
                begin: 0.08,
                delay: Duration(milliseconds: 100 + (widget.index * 80)),
                duration: 800.ms,
                curve: Curves.fastEaseInToSlowEaseOut,
              ),
    );
  }

  Widget _badge(IconData icon, String text) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                text,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.95),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
