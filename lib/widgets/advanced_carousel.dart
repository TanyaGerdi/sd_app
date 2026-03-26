import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:safeen_institute/theme/app_colors.dart';
import 'package:safeen_institute/screens/news_detail_screen.dart';
import 'package:safeen_institute/widgets/cached_image.dart';
import 'package:safeen_institute/utils/time_helper.dart';

class AdvancedCarousel extends StatefulWidget {
  final List<Map<String, dynamic>> newsItems;
  const AdvancedCarousel({super.key, required this.newsItems});

  @override
  State<AdvancedCarousel> createState() => _AdvancedCarouselState();
}

class _AdvancedCarouselState extends State<AdvancedCarousel> {
  late PageController _pageController;
  double _currentPage = 0.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.94,
    );
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? 0.0;
      });
    });
    _startTimer();
  }

  void _startTimer() {
    if (widget.newsItems.isEmpty) return;
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        int nextPage = (_pageController.page?.round() ?? 0) + 1;
        if (nextPage >= widget.newsItems.length) {
          nextPage = 0;
        }
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PageView.builder(
            clipBehavior: Clip.none,
            controller: _pageController,
            itemCount: widget.newsItems.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              double difference = index - _currentPage;

              // Apply 3D depth scaling
              double scale = 1.0 - (difference.abs() * 0.15).clamp(0.0, 0.3);
              double opacity = 1.0 - (difference.abs() * 0.4).clamp(0.0, 0.6);
              double rotateY =
                  difference * -0.1; // slight 3D rotation based on position

              return Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.002) // perspective
                  ..rotateY(rotateY)
                  ..scale(scale),
                alignment: Alignment.center,
                child: Opacity(opacity: opacity, child: _buildCard(index)),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        // Custom Indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.newsItems.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 8,
              width: _currentPage.round() == index ? 24 : 8,
              decoration: BoxDecoration(
                color: _currentPage.round() == index
                    ? AppColors.primary
                    : AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ).animate().fadeIn(delay: 500.ms),
      ],
    );
  }

  Widget _buildCard(int index) {
    if (widget.newsItems.isEmpty) return const SizedBox.shrink();
    final item = widget.newsItems[index];
    final isDark = AppColors.isDark(context);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewsDetailScreen(
              newsItem: item,
            ),
          ),
        );
      },
      child: Hero(
        tag: 'news_image_${item['image_url']}',
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              24,
            ), // Perfect premium 24px radius
            color: AppColors.primary,
            image: DecorationImage(
              image: cachedProvider(item['image_url']!),
              fit: BoxFit.cover,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 15,
                spreadRadius: 2,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Dynamic gradient overlay over the image
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        isDark
                            ? const Color(0xFF141416).withValues(alpha: 0.8)
                            : Colors.black.withValues(alpha: 0.6),
                        isDark
                            ? const Color(0xFF040405)
                            : Colors.black.withValues(alpha: 0.85),
                      ],
                      stops: const [0.4, 0.8, 1.0],
                    ),
                  ),
                ),
              ),
              // Content Layer
              Positioned(
                bottom: 24,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'هەواڵ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ).animate().fadeIn(duration: 400.ms).slideX(),
                    const SizedBox(height: 12),
                    // Title
                    Text(
                      item['title']?.toString() ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        height: 1.3,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Meta Info (Date/Time)
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          color: Colors.white.withValues(alpha: 0.7),
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          TimeHelper.timeAgo(item['time']?.toString() ?? item['created_at']?.toString()),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
