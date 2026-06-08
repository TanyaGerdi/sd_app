import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sd_institute/theme/app_colors.dart';
import 'package:sd_institute/services/notification_service.dart';
import 'package:sd_institute/services/post_service.dart';
import 'package:sd_institute/screens/news_detail_screen.dart';
import 'package:sd_institute/widgets/clay_container.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final data = await NotificationService.getNotifications();
    if (!mounted) return;
    setState(() {
      _notifications = data;
      _isLoading = false;
    });
  }

  String _timeAgo(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      String formattedStr = dateStr;
      if (!formattedStr.endsWith('Z') && !formattedStr.contains('+')) {
        formattedStr = formattedStr.replaceAll(' ', 'T') + 'Z';
      }
      final date = DateTime.parse(formattedStr).toLocal();
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 60) return '${diff.inMinutes} خولەک لەمەوپێش';
      if (diff.inHours < 24) return '${diff.inHours} کاتژمێر لەمەوپێش';
      if (diff.inDays < 7) return '${diff.inDays} ڕۆژ لەمەوپێش';
      return '${(diff.inDays / 7).floor()} هەفتە لەمەوپێش';
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
            ? const Color(0xFF000000)
            : const Color(0xFFF2F2F7),
        body: Stack(
          children: [
            Positioned(
              top: -100,
              right: -50,
              child: _buildOrb(
                color: AppColors.primary.withValues(alpha: isDark ? 0.3 : 0.08),
                size: size.width * 0.8,
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
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: const SizedBox(),
              ),
            ),
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ClayIconButton(
                          icon: Icons.arrow_back_ios_new_rounded,
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ).animate().fadeIn(duration: 400.ms).scale(),
                        Text(
                              'ڕاگەیاندنەکان',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF111827),
                                letterSpacing: -0.5,
                              ),
                            )
                            .animate()
                            .fadeIn(delay: 50.ms, duration: 400.ms)
                            .slideY(begin: -0.2),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _notifications.isEmpty
                        ? _buildEmptyState(isDark)
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            physics: const BouncingScrollPhysics(),
                            itemCount: _notifications.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final notif = _notifications[index];
                              return _buildNotificationCard(
                                notif,
                                isDark,
                                index,
                              );
                            },
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

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.03),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_off_rounded,
              size: 48,
              color: isDark ? Colors.white54 : Colors.black38,
            ),
          ).animate().fadeIn(delay: 100.ms).scale(),
          const SizedBox(height: 24),
          Text(
            'هیچ ڕاگەیاندنێک نییە',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
          const SizedBox(height: 8),
          Text(
            'لە ئێستادا هیچ ئاگادارکردنەوەیەک نییە بۆ نیشاندان',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
    Map<String, dynamic> notif,
    bool isDark,
    int index,
  ) {
    return GestureDetector(
          onTap: () async {
            HapticFeedback.lightImpact();

            final targetId =
                (notif['target_id'] ??
                        notif['reference_id'] ??
                        notif['post_id'] ??
                        '')
                    .toString();
            final targetType = (notif['target_type'] ?? '').toString();

            if (targetId.isEmpty || targetId == 'null') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'ئەم ئاگادارکردنەوەیە بەستەری نییە (کۆنە)',
                    textDirection: TextDirection.rtl,
                  ),
                  backgroundColor: Colors.redAccent,
                ),
              );
              return;
            }

            // Show a brief loading indicator
            if (!mounted) return;
            showDialog(
              context: context,
              barrierDismissible: false,
              barrierColor: Colors.black26,
              builder: (_) => const Center(
                child: CircularProgressIndicator(
                  color: AppColors.secondary,
                  strokeWidth: 2.5,
                ),
              ),
            );

            try {
              // Determine table based on target_type
              String table = 'news';
              if (targetType == 'student_news') {
                table = 'student_news';
              } else if (targetType == 'future_activities' ||
                  targetType == 'activities') {
                table = 'activities';
              }

              final post = await PostService.getPostById(
                targetId,
                table: table,
              ).timeout(const Duration(seconds: 6));

              if (!mounted) return;
              Navigator.pop(context); // dismiss loading

              if (post != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NewsDetailScreen(newsItem: post),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'ببورە، هەواڵەکە نەدۆزرایەوە یان سڕاوەتەوە',
                      textDirection: TextDirection.rtl,
                    ),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            } catch (e) {
              if (mounted) {
                Navigator.pop(context); // dismiss loading
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'هەڵەیەک ڕوویدا لە بارکردن، تکایە جارێکی تر هەوڵبدەرەوە',
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                );
              }
            }
          },
          child: ClayContainer(
            margin: const EdgeInsets.only(bottom: 2),
            borderRadius: 24,
            depth: 10,
            color: isDark ? const Color(0xFF1E1E24) : const Color(0xFFE8EAF0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6C5CE7), Color(0xFF00CEFF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF00CEFF,
                            ).withValues(alpha: 0.3),
                            blurRadius: 12,
                            spreadRadius: 1,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.notifications_active_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  notif['title']?.toString() ?? '',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF111827),
                                    letterSpacing: -0.3,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.1)
                                      : Colors.black.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _timeAgo(notif['created_at']?.toString()),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black54,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            notif['message']?.toString() ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: isDark
                                  ? Colors.white70
                                  : const Color(0xFF4B5563),
                              fontWeight: FontWeight.w500,
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
        )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 100 + index * 60),
          duration: 500.ms,
        )
        .slideY(begin: 0.1, duration: 500.ms, curve: Curves.easeOutCirc);
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
