import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:safeen_institute/theme/app_colors.dart';
import 'package:safeen_institute/services/post_service.dart';
import 'package:safeen_institute/widgets/cached_image.dart';
import 'package:safeen_institute/screens/news_screen.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class NewsDetailScreen extends StatefulWidget {
  final Map<String, dynamic> newsItem;

  const NewsDetailScreen({super.key, required this.newsItem});

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen>
    with SingleTickerProviderStateMixin {
  bool _isBookmarked = false;
  List<String> _galleryImages = [];

  @override
  void initState() {
    super.initState();
    _isBookmarked = NewsScreen.savedNews.any(
      (item) => item['title'] == widget.newsItem['title'],
    );
    _loadGallery();
  }

  List<String> _parseGalleryImages(dynamic raw) {
    if (raw == null) return [];
    if (raw is List) {
      return raw
          .where((e) => e != null && e.toString().trim().isNotEmpty)
          .map((e) => e.toString().trim())
          .toList();
    }
    if (raw is String) {
      final str = raw.trim();
      if (str.isEmpty) return [];
      if (str.startsWith('{') && str.endsWith('}')) {
        final inner = str.substring(1, str.length - 1);
        if (inner.trim().isEmpty) return [];
        return inner
            .split(',')
            .map((e) => e.trim().replaceAll('"', ''))
            .where((e) => e.isNotEmpty)
            .toList();
      }
      if (str.startsWith('http')) return [str];
    }
    return [];
  }

  Future<void> _loadGallery() async {
    final inlineGallery = _parseGalleryImages(widget.newsItem['gallery_images']);
    if (inlineGallery.isNotEmpty) {
      if (mounted) setState(() => _galleryImages = inlineGallery);
      return;
    }
    final postId = widget.newsItem['id']?.toString();
    if (postId == null || postId.isEmpty) return;
    final category = widget.newsItem['category']?.toString() ?? 'news';
    String table = 'news';
    if (category == 'activities') {
      table = 'activities';
    } else if (category == 'student_news') {
      table = 'student_news';
    } else if (category == 'quotes') {
      table = 'student_quotes';
    }

    final images = await PostService.getPostGallery(postId, table: table);
    if (!mounted || images.isEmpty) return;
    setState(() {
      _galleryImages = images
          .expand((e) => _parseGalleryImages(e))
          .where((url) => url.isNotEmpty)
          .toList();
    });
  }

  String _timeAgo(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);
      if (difference.inDays > 365) return '${(difference.inDays / 365).floor()} ساڵ پێش ئێستا';
      if (difference.inDays > 30) return '${(difference.inDays / 30).floor()} مانگ پێش ئێستا';
      if (difference.inDays > 0) return '${difference.inDays} ڕۆژ پێش ئێستا';
      if (difference.inHours > 0) return '${difference.inHours} کاتژمێر پێش ئێستا';
      if (difference.inMinutes > 0) return '${difference.inMinutes} خولەک پێش ئێستا';
      return 'کەمێک پێش ئێستا';
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final newsItem = widget.newsItem;
    final isDark = AppColors.isDark(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF040405) : Colors.white,
        body: Stack(
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Header
                  Stack(
                    children: [
                      Hero(
                        tag: 'news_image_${newsItem['image']}',
                        child: Container(
                          height: 380,
                          width: double.infinity,
                          foregroundDecoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.3),
                                Colors.transparent,
                                (isDark ? const Color(0xFF040405) : Colors.white).withValues(alpha: 0.8),
                                isDark ? const Color(0xFF040405) : Colors.white,
                              ],
                              stops: const [0.0, 0.4, 0.85, 1.0],
                            ),
                          ),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: cachedProvider(newsItem['image']?.toString() ?? ''),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 10,
                        right: 16,
                        left: 16,
                        child: Row(
                          children: [
                            _topIconButton(Icons.arrow_back_ios_new, () => Navigator.pop(context)),
                            const Spacer(),
                            _topIconButton(_isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, () {
                              setState(() {
                                _isBookmarked = !_isBookmarked;
                                if (_isBookmarked) {
                                  NewsScreen.savedNews.add(Map<String, String>.from(newsItem.map((k, v) => MapEntry(k, v?.toString() ?? ''))));
                                } else {
                                  NewsScreen.savedNews.removeWhere((item) => item['title'] == newsItem['title']);
                                }
                              });
                              NewsScreen.persistSavedNews();
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Content Body
                  Transform.translate(
                    offset: const Offset(0, -40),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text('هەواڵ', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w800, fontSize: 13)),
                              ),
                              const Spacer(),
                              Icon(Icons.access_time_rounded, color: isDark ? Colors.white38 : Colors.black26, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                _timeAgo(newsItem['created_at']?.toString() ?? newsItem['time']?.toString()),
                                style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Text(
                            newsItem['title']?.toString() ?? '',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              height: 1.3,
                              color: isDark ? Colors.white : const Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            height: 1.5,
                            width: 60,
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            newsItem['content']?.toString() ?? '',
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.8,
                              color: isDark ? Colors.white.withValues(alpha: 0.7) : const Color(0xFF4B5563),
                            ),
                          ),

                          // ── Staggered Gallery ────────────────────────────
                          if (_galleryImages.isNotEmpty) ...[
                            const SizedBox(height: 48),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'پێشانگای وێنەکان',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: isDark ? Colors.white : const Color(0xFF111827),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            MasonryGridView.count(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _galleryImages.length,
                              itemBuilder: (context, index) {
                                // Variable heights for "masonry" staggered look
                                double heightFactor = (index % 3 == 0) ? 1.5 : 1.0;
                                return GestureDetector(
                                  onTap: () => _openGalleryViewer(_galleryImages, index),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                                          blurRadius: 15,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: AspectRatio(
                                      aspectRatio: 1 / heightFactor,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(24),
                                        child: CachedImage(
                                          imageUrl: _galleryImages[index],
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                          const SizedBox(height: 100),
                        ],
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

  Widget _topIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  void _openGalleryViewer(List<String> images, int initial) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, anim, __) => FadeTransition(opacity: anim, child: _CinematicGalleryViewer(images: images, initialIndex: initial)),
      ),
    );
  }
}

class _CinematicGalleryViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _CinematicGalleryViewer({required this.images, required this.initialIndex});

  @override
  State<_CinematicGalleryViewer> createState() => _CinematicGalleryViewerState();
}

class _CinematicGalleryViewerState extends State<_CinematicGalleryViewer> {
  late PageController _pc;
  late int _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _pc = PageController(initialPage: _current);
  }

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: CachedImage(imageUrl: widget.images[_current], fit: BoxFit.cover)),
          Positioned.fill(child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30), child: Container(color: Colors.black.withValues(alpha: 0.7)))),
          PageView.builder(
            controller: _pc,
            itemCount: widget.images.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (_, i) {
              return InteractiveViewer(minScale: 0.5, maxScale: 5.0, child: Center(child: Padding(padding: const EdgeInsets.all(20), child: ClipRRect(borderRadius: BorderRadius.circular(16), child: CachedImage(imageUrl: widget.images[i], fit: BoxFit.contain)))));
            },
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 14,
            right: 18,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(width: 44, height: 44, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), shape: BoxShape.circle, border: Border.all(color: Colors.white.withValues(alpha: 0.15))), child: const Icon(Icons.close_rounded, color: Colors.white, size: 22)),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 30,
            left: 0, right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(widget.images.length, (i) {
                    final active = i == _current;
                    return AnimatedContainer(duration: const Duration(milliseconds: 300), width: active ? 28 : 8, height: 8, margin: const EdgeInsets.symmetric(horizontal: 3), decoration: BoxDecoration(color: active ? Colors.white : Colors.white.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(4)));
                  }),
                ),
                const SizedBox(height: 12),
                Container(padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)), child: Text('${_current + 1} / ${widget.images.length}', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
