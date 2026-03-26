import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:safeen_institute/theme/app_colors.dart';
import 'package:safeen_institute/services/future_activities_service.dart';
import 'package:safeen_institute/widgets/cached_image.dart';

class FutureActivitiesScreen extends StatefulWidget {
  const FutureActivitiesScreen({super.key});

  @override
  State<FutureActivitiesScreen> createState() => _FutureActivitiesScreenState();
}

class _FutureActivitiesScreenState extends State<FutureActivitiesScreen> {
  List<Map<String, dynamic>> _activities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    final data = await FutureActivitiesService.getActivities();
    if (!mounted) return;
    setState(() {
      _activities = data;
      _isLoading = false;
    });
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('yyyy/MM/dd').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  String _daysUntil(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = date.difference(now).inDays;
      if (diff < 0) return 'تێپەڕیوە';
      if (diff == 0) return 'ئەمڕۆ';
      if (diff == 1) return 'سبەینێ';
      return '$diff ڕۆژ ماوە';
    } catch (_) {
      return '';
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
            ? const Color(0xFF040405)
            : const Color(0xFFF9FAFB),
        body: Stack(
          children: [
            // Ambient aurora background
            Positioned(
              top: -size.height * 0.15,
              left: -size.width * 0.4,
              child: Container(
                width: size.width * 1.2,
                height: size.width * 1.2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(
                        0xFF10B981,
                      ).withValues(alpha: isDark ? 0.25 : 0.15),
                      const Color(
                        0xFF6C5CE7,
                      ).withValues(alpha: isDark ? 0.1 : 0.05),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -size.height * 0.1,
              right: -size.width * 0.3,
              child: Container(
                width: size.width,
                height: size.width,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(
                        0xFFFF6B6B,
                      ).withValues(alpha: isDark ? 0.15 : 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                child: const SizedBox(),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.card(context),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: AppColors.shadow(context),
                            ),
                            child: Icon(
                              Icons.arrow_back_ios_new,
                              size: 17,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'چالاکیەکانی داهاتوو',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                              ),
                              Text(
                                '${_activities.length} چالاکی',
                                style: TextStyle(
                                  color: AppColors.textSec(context),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ).animate().fadeIn(duration: 400.ms),
                  ),

                  const SizedBox(height: 20),

                  // Content
                  Expanded(
                    child: _isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                              strokeWidth: 2.5,
                            ),
                          )
                        : _activities.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(
                                          0xFF10B981,
                                        ).withValues(alpha: 0.2),
                                        const Color(
                                          0xFF6C5CE7,
                                        ).withValues(alpha: 0.2),
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.event_available_rounded,
                                    size: 40,
                                    color: AppColors.textSec(context),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'هیچ چالاکییەکی داهاتوو نییە',
                                  style: TextStyle(
                                    color: AppColors.textSec(context),
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                            physics: const BouncingScrollPhysics(),
                            itemCount: _activities.length,
                            itemBuilder: (context, index) => _buildActivityCard(
                              context,
                              _activities[index],
                              index,
                              isDark,
                            ),
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

  Widget _buildActivityCard(
    BuildContext context,
    Map<String, dynamic> activity,
    int index,
    bool isDark,
  ) {
    final title = activity['title_ku'] ?? '';
    final description = activity['description_ku'] ?? '';
    final imageUrl = (activity['image_url'] ?? '').toString().trim();
    final location = activity['location'] ?? '';
    final dateStr = activity['activity_date']?.toString() ?? '';
    final formattedDate = _formatDate(dateStr);
    final countdown = _daysUntil(dateStr);

    // Gradient colors rotate for visual variety
    final gradientSets = [
      [const Color(0xFF10B981), const Color(0xFF059669)],
      [const Color(0xFF6C5CE7), const Color(0xFF8B5CF6)],
      [const Color(0xFFFF6B6B), const Color(0xFFEF4444)],
      [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
      [const Color(0xFFF59E0B), const Color(0xFFD97706)],
    ];
    final colors = gradientSets[index % gradientSets.length];

    return Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.04),
            ),
            boxShadow: isDark
                ? [
                    BoxShadow(
                      color: colors[0].withValues(alpha: 0.1),
                      blurRadius: 20,
                      spreadRadius: -5,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image header with countdown badge
              if (imageUrl.isNotEmpty)
                Stack(
                  children: [
                    SizedBox(
                      height: 180,
                      width: double.infinity,
                      child: CachedImage(imageUrl: imageUrl, fit: BoxFit.cover),
                    ),
                    // Gradient overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.5),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Countdown badge
                    if (countdown.isNotEmpty)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: colors),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: colors[0].withValues(alpha: 0.5),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Text(
                            countdown,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

              // No image — show a colored header bar
              if (imageUrl.isEmpty)
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: colors),
                  ),
                ),

              // Content
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text(context),
                        height: 1.4,
                      ),
                    ),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSec(context),
                          height: 1.5,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    const SizedBox(height: 14),

                    // Date and location chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (formattedDate.isNotEmpty)
                          _buildChip(
                            Icons.calendar_today_rounded,
                            formattedDate,
                            colors[0],
                            isDark,
                          ),
                        if (location.isNotEmpty)
                          _buildChip(
                            Icons.location_on_rounded,
                            location,
                            colors[1],
                            isDark,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(
          delay: (index * 100).ms,
          duration: 500.ms,
          curve: Curves.easeOutCubic,
        )
        .slideY(begin: 0.08);
  }

  Widget _buildChip(IconData icon, String label, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
