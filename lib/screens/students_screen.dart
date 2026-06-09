import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sd_institute/theme/app_colors.dart';
import 'package:sd_institute/screens/news_screen.dart';
import 'package:sd_institute/screens/schedule_screen.dart';
import 'package:sd_institute/widgets/clay_container.dart';
import 'package:sd_institute/utils/app_localizations.dart';

class StudentsScreen extends StatelessWidget {
  const StudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final size = MediaQuery.of(context).size;
    final loc = AppLocalizations.of(context);
    final localeProvider = LocaleProviderInherited.of(context);

    final items = [
      {
        'title': loc.get('student_articles'),
        'subtitle': loc.get('student_articles_sub'),
        'icon': Icons.menu_book_rounded,
        'color': const Color(0xFF10B981), // Emerald
        'category': 'student_news',
      },
      {
        'title': loc.get('student_quotes'),
        'subtitle': loc.get('student_quotes_sub'),
        'icon': Icons.record_voice_over_rounded,
        'color': const Color(0xFF8B5CF6), // Violet
        'category': 'quotes',
      },
      {
        'title': loc.get('class_schedule'),
        'subtitle': loc.get('class_schedule_sub'),
        'icon': Icons.schedule_rounded,
        'color': const Color(0xFF3B82F6), // Blue
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ScheduleScreen()),
        ),
      },
    ];

    return Directionality(
      textDirection: localeProvider.textDirection,
      child: Scaffold(
        backgroundColor: isDark
            ? const Color(0xFF000000)
            : const Color(0xFFF2F2F7),
        body: Stack(
          children: [
            // Atmospheric Background Orbs
            Positioned(
              top: -size.height * 0.1,
              left: -size.width * 0.3,
              child: _buildOrb(
                color: const Color(
                  0xFF8B5CF6,
                ).withValues(alpha: isDark ? 0.25 : 0.15),
                size: size.width,
              ),
            ),
            Positioned(
              bottom: size.height * 0.2,
              right: -size.width * 0.4,
              child: _buildOrb(
                color: const Color(
                  0xFF3B82F6,
                ).withValues(alpha: isDark ? 0.2 : 0.1),
                size: size.width * 1.2,
              ),
            ),

            // Glassmorphism Overlay
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: const SizedBox(),
              ),
            ),

            // Main Content
            CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      24,
                      MediaQuery.of(context).padding.top + 20,
                      24,
                      40,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Navigation
                        ClayIconButton(
                              icon: Icons.arrow_back_ios_new,
                              onTap: () {
                                Navigator.pop(context);
                              },
                            )
                            .animate()
                            .fadeIn(duration: 400.ms)
                            .slideY(begin: -0.2),

                        const SizedBox(height: 32),

                        // Title
                        Text(
                              loc.get('students_page_title'),
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w900,
                                height: 1.45,
                                letterSpacing: -1,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF111827),
                              ),
                            )
                            .animate()
                            .fadeIn(delay: 100.ms, duration: 600.ms)
                            .slideX(begin: 0.1),

                        const SizedBox(height: 32),

                        // Cinematic List
                        ...List.generate(items.length, (index) {
                          final item = items[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: _InteractiveCinematicCard(
                              isDark: isDark,
                              title: item['title'] as String,
                              subtitle: item['subtitle'] as String,
                              icon: item['icon'] as IconData,
                              color: item['color'] as Color,
                              delay: 200 + (index * 150),
                              category: item['category'] as String?,
                              onTap: item['onTap'] as VoidCallback?,
                            ),
                          );
                        }),
                      ],
                    ),
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
            blurRadius: size * 0.5,
            spreadRadius: size * 0.1,
          ),
        ],
      ),
    );
  }
}

class _InteractiveCinematicCard extends StatefulWidget {
  final bool isDark;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final int delay;
  final String? category;
  final VoidCallback? onTap;

  const _InteractiveCinematicCard({
    required this.isDark,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.delay,
    this.category,
    this.onTap,
  });

  @override
  State<_InteractiveCinematicCard> createState() =>
      _InteractiveCinematicCardState();
}

class _InteractiveCinematicCardState extends State<_InteractiveCinematicCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
          onTapDown: (_) {
            HapticFeedback.lightImpact();
            setState(() => _isPressed = true);
          },
          onTapUp: (_) {
            setState(() => _isPressed = false);
            if (widget.onTap != null) {
              widget.onTap!();
              return;
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  if (widget.category != null) {
                    return NewsScreen(
                      category: widget.category!,
                      title: widget.title,
                    );
                  }
                  return Scaffold(
                    appBar: AppBar(
                      title: Text(widget.title),
                      backgroundColor: widget.isDark
                          ? const Color(0xFF000000)
                          : Colors.white,
                      iconTheme: IconThemeData(
                        color: widget.isDark ? Colors.white : Colors.black,
                      ),
                      titleTextStyle: TextStyle(
                        color: widget.isDark ? Colors.white : Colors.black,
                        fontFamily: 'Rega',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: widget.isDark
                        ? const Color(0xFF000000)
                        : const Color(0xFFF2F2F7),
                    body: Center(
                      child: Text(
                        'بەمزووانە بەردەست دەبێت',
                        style: TextStyle(
                          fontSize: 18,
                          color: widget.isDark
                              ? Colors.white70
                              : Colors.black54,
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedScale(
            scale: _isPressed ? 0.95 : 1.0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.elasticOut,
            child: ClayContainer(
              width: double.infinity,
              height: 180,
              borderRadius: 32,
              depth: _isPressed ? 5 : 14,
              spread: _isPressed ? 0 : 2,
              emboss: _isPressed,
              color: widget.isDark
                  ? const Color(0xFF1E1E24)
                  : const Color(0xFFE8EAF0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: Stack(
                    children: [
                      // Massive spilling background icon
                      Positioned(
                        right: -30,
                        bottom: -40,
                        child: AnimatedScale(
                          scale: _isPressed ? 1.1 : 1.0,
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOutExpo,
                          child: Icon(
                            widget.icon,
                            size: 200,
                            color: widget.color.withValues(
                              alpha: widget.isDark ? 0.15 : 0.08,
                            ),
                          ),
                        ),
                      ),

                      // Main Content
                      Padding(
                        padding: const EdgeInsets.all(32),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: widget.color.withValues(
                                        alpha: 0.2,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: widget.color.withValues(
                                          alpha: 0.3,
                                        ),
                                      ),
                                    ),
                                    child: Icon(
                                      widget.icon,
                                      color: widget.color,
                                      size: 24,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    widget.title,
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.5,
                                      color: widget.isDark
                                          ? Colors.white
                                          : const Color(0xFF111827),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.subtitle,
                                    maxLines: 3,
                                    overflow: TextOverflow.visible,
                                    style: TextStyle(
                                      fontSize: 12,
                                      height: 1.2,
                                      fontWeight: FontWeight.w500,
                                      color: widget.isDark
                                          ? Colors.white70
                                          : const Color(0xFF4B5563),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Glass pill button
                            Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: widget.isDark
                                        ? Colors.white.withValues(alpha: 0.05)
                                        : Colors.white.withValues(alpha: 0.5),
                                    border: Border.all(
                                      color: widget.isDark
                                          ? Colors.white.withValues(alpha: 0.1)
                                          : Colors.white,
                                    ),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 18,
                                      color: widget.isDark
                                          ? Colors.white54
                                          : Colors.black54,
                                    ),
                                  ),
                                )
                                .animate(target: _isPressed ? 1 : 0)
                                .moveX(
                                  end: -5,
                                  duration: 300.ms,
                                  curve: Curves.easeOutExpo,
                                ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(delay: widget.delay.ms, duration: 800.ms)
        .slideY(begin: 0.2, curve: Curves.easeOutCubic);
  }
}
