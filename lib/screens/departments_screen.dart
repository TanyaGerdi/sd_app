import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sd_institute/theme/app_colors.dart';
import 'package:sd_institute/screens/department_detail_screen.dart';
import 'package:sd_institute/services/department_service.dart';
import 'package:sd_institute/widgets/cached_image.dart';
import 'package:sd_institute/widgets/clay_container.dart';
import 'package:sd_institute/utils/app_localizations.dart';

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
      'image': '',
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
        } else if (d['icon'] == 'local_pharmacy_rounded') {
          iconData = Icons.local_pharmacy_rounded;
        } else if (d['icon'] == 'language_rounded') {
          iconData = Icons.language_rounded;
        } else if (d['icon'] == 'computer_rounded') {
          iconData = Icons.computer_rounded;
        } else if (d['icon'] == 'calculate_rounded') {
          iconData = Icons.calculate_rounded;
        } else if (d['icon'] == 'business_center_rounded') {
          iconData = Icons.business_center_rounded;
        }

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
          'image': imgUrl.isNotEmpty ? imgUrl : '',
          'duration_years': d['duration_years'] ?? 2,
        };
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final canGoBack = Navigator.canPop(context);
    final isDark = AppColors.isDark(context);
    final size = MediaQuery.of(context).size;
    final localizations = AppLocalizations.of(context);
    final localeProvider = LocaleProviderInherited.of(context);

    return Directionality(
      textDirection: localeProvider.textDirection,
      child: Scaffold(
        backgroundColor: isDark
            ? const Color(0xFF000000)
            : const Color(0xFFF2F2F7),
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
                              ClayIconButton(
                                icon: Icons.arrow_back_ios_new,
                                iconSize: 18,
                                onTap: () {
                                  Navigator.pop(context);
                                },
                              ),
                              const SizedBox(width: 16),
                            ],
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    localizations.get('departments_title'),
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
                                    '${departments.length} ${localizations.get('departments')}',
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
  @override
  Widget build(BuildContext context) {
    final Color color = widget.dept['color'];
    final hasImage = widget.dept['image']?.toString().isNotEmpty == true;
    final localizations = AppLocalizations.of(context);

    return ClayButton(
          onTap: () {
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
          borderRadius: 28,
          depth: 12,
          child: Container(
            height: 214,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              image: hasImage
                  ? DecorationImage(
                      image: cachedProvider(widget.dept['image']),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.white.withValues(
                    alpha: widget.isDark ? 0.10 : 0.18,
                  ),
                  width: 1.1,
                ),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: hasImage
                      ? [
                          Colors.black.withValues(alpha: 0.78),
                          Colors.black.withValues(alpha: 0.18),
                          Colors.transparent,
                        ]
                      : [
                          Color.lerp(
                            color,
                            Colors.black,
                            widget.isDark ? 0.34 : 0.18,
                          )!,
                          color.withValues(alpha: 0.92),
                          Color.lerp(
                            color,
                            Colors.white,
                            widget.isDark ? 0.04 : 0.16,
                          )!,
                        ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.18),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.22),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Icon(
                          widget.dept['icon'],
                          color: Colors.white.withValues(alpha: 0.94),
                          size: 26,
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
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.dept['subtitle'],
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.22),
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      _badge(
                        Icons.people_rounded,
                        '${widget.dept['students']} ${localizations.get(widget.dept['students'] == '1' ? 'student' : 'students_count')}',
                      ),
                      _badge(
                        Icons.person_rounded,
                        '${widget.dept['teachers']} ${localizations.get(widget.dept['teachers'] == '1' ? 'teacher' : 'teachers_count')}',
                      ),
                      _badge(
                        Icons.access_time_rounded,
                        '${widget.dept['duration_years']} ${localizations.get('duration_years_label') ?? 'ساڵ'}',
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
        );
  }

  Widget _badge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: widget.isDark ? 0.12 : 0.18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.95)),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.95),
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
