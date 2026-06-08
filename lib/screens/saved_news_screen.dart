import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sd_institute/theme/app_colors.dart';
import 'package:sd_institute/screens/news_detail_screen.dart';
import 'package:sd_institute/widgets/cached_image.dart';
import 'package:sd_institute/widgets/clay_container.dart';

class SavedNewsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> savedItems;
  const SavedNewsScreen({super.key, required this.savedItems});

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bg(context),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 12,
                  left: 20,
                  right: 20,
                  bottom: 10,
                ),
                child:
                    Row(
                      children: [
                        ClayIconButton(
                          icon: Icons.arrow_back_ios_new,
                          iconSize: 17,
                          onTap: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'هەواڵە پاشەکەوتکراوەکان',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${savedItems.length} هەواڵ',
                                style: TextStyle(
                                  color: AppColors.textSec(context),
                                  fontSize: 12,
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
            ),
            if (savedItems.isEmpty)
              SliverFillRemaining(
                child:
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withValues(
                                alpha: isDark ? 0.15 : 0.08,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.bookmark_border_rounded,
                              size: 40,
                              color: AppColors.secondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'هیچ هەواڵێک پاشەکەوت نەکراوە',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSec(context),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'هەواڵەکان پاشەکەوت بکە بۆ خوێندنەوەی دواتر',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.hint(context),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(
                      delay: 100.ms,
                      duration: 400.ms,
                      curve: Curves.easeOutCubic,
                    ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildNewsCard(
                      context,
                      isDark,
                      savedItems[index],
                      index,
                    ),
                    childCount: savedItems.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsCard(
    BuildContext context,
    bool isDark,
    Map<String, dynamic> item,
    int index,
  ) {
    return GestureDetector(
          onTap: () => Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  NewsDetailScreen(newsItem: item),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    final curved = CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutQuint,
                    );
                    return FadeTransition(
                      opacity: curved,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.03),
                          end: Offset.zero,
                        ).animate(curved),
                        child: child,
                      ),
                    );
                  },
              transitionDuration: const Duration(milliseconds: 400),
            ),
          ),
          child: ClayContainer(
            margin: const EdgeInsets.only(bottom: 14),
            borderRadius: 22,
            depth: 10,
            color: isDark ? const Color(0xFF1E1E24) : const Color(0xFFE8EAF0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 140,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(18),
                    ),
                    image: DecorationImage(
                      image: cachedProvider(item['image']?.toString() ?? ''),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title']?.toString() ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          height: 1.5,
                          color: AppColors.text(context),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            color: AppColors.hint(context),
                            size: 14,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            item['time']?.toString() ?? '',
                            style: TextStyle(
                              color: AppColors.textSec(context),
                              fontSize: 12,
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.bookmark_rounded,
                            color: AppColors.secondary,
                            size: 18,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 80 + (index * 60)),
          duration: 400.ms,
          curve: Curves.easeOutCubic,
        )
        .slideY(
          begin: 0.04,
          delay: Duration(milliseconds: 80 + (index * 60)),
          duration: 400.ms,
          curve: Curves.easeOutCubic,
        );
  }
}
