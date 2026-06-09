import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sd_institute/theme/app_colors.dart';
import 'package:sd_institute/screens/news_detail_screen.dart';
import 'package:sd_institute/services/post_service.dart';
import 'package:sd_institute/widgets/cached_image.dart';
import 'package:sd_institute/widgets/clay_container.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sd_institute/utils/time_helper.dart';
import 'package:sd_institute/utils/app_localizations.dart';

class NewsScreen extends StatefulWidget {
  final String category;
  final String title;

  const NewsScreen({
    super.key,
    this.category = 'news',
    this.title = 'نوێترین هەواڵەکان',
  });

  // Static saved items accessible from outside
  static List<Map<String, dynamic>> savedNews = [];

  /// Load saved news from disk (called once at app start)
  static Future<void> loadSavedNews() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('saved_news');
    if (raw != null) {
      try {
        final decoded = jsonDecode(raw) as List;
        savedNews = decoded
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      } catch (_) {}
    }
  }

  static Future<void> persistSavedNews() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_news', jsonEncode(savedNews));
  }

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final Set<int> _bookmarked = {};
  bool _isLoading = true;
  List<Map<String, dynamic>> _newsItems = [];

  @override
  void initState() {
    super.initState();
    _initBookmarks();
    _loadNews();
  }

  void _initBookmarks() {
    _bookmarked.clear();
    for (int i = 0; i < _newsItems.length; i++) {
      if (NewsScreen.savedNews.any(
        (saved) => saved['title'] == _newsItems[i]['title'],
      )) {
        _bookmarked.add(i);
      }
    }
  }

  Future<void> _loadNews() async {
    final data = await PostService.getPosts(category: widget.category);
    if (!mounted) return;
    setState(() {
      if (data.isNotEmpty) {
        _newsItems = data.map((item) {
          final imgUrl = (item['image_url'] ?? item['image'] ?? '')
              .toString()
              .trim();
          return <String, dynamic>{
            'id': item['id']?.toString() ?? '',
            'title': item['title']?.toString() ?? 'هەواڵێکی نوێ',
            'time': item['created_at']?.toString() ?? 'کەمێک پێش ئێستا',
            'created_at': item['created_at']?.toString() ?? '',
            'category': item['category']?.toString() ?? widget.category,
            'image': imgUrl.isNotEmpty ? imgUrl : '',
            'image_url': imgUrl.isNotEmpty ? imgUrl : '',
            'content': item['content']?.toString() ?? 'درێژەی هەواڵ...',
            'gallery_images': item['gallery_images'] ?? [],
          };
        }).toList();
        _initBookmarks();
      }
      _isLoading = false;
    });
  }

  void _toggleBookmark(int index) {
    HapticFeedback.lightImpact();
    final item = _newsItems[index];
    final bool isSaving = !_bookmarked.contains(index);

    setState(() {
      if (isSaving) {
        _bookmarked.add(index);
        NewsScreen.savedNews.add(item);
      } else {
        _bookmarked.remove(index);
        NewsScreen.savedNews.removeWhere(
          (saved) => saved['title'] == item['title'],
        );
      }
    });

    NewsScreen.persistSavedNews(); // persist to disk
    if (item['id'] != null && item['id']!.isNotEmpty) {
      PostService.toggleSavedPost(item['id']!, isSaving); // persist to database
    }

    final localizations = AppLocalizations.of(context);
    final localeProvider = LocaleProviderInherited.of(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _bookmarked.contains(index)
              ? localizations.get('post_saved')
              : localizations.get('post_removed'),
          textDirection: localeProvider.textDirection,
        ),
        backgroundColor: _bookmarked.contains(index)
            ? AppColors.secondary
            : AppColors.textSec(context),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  String _getLocalizedTitle(BuildContext context, String rawTitle) {
    final loc = AppLocalizations.of(context);
    if (rawTitle == 'نوێترین هەواڵەکان' || rawTitle == 'news') {
      return loc.get('latest_news');
    }
    if (rawTitle == 'بابەتی قوتابیان') {
      return loc.get('student_articles');
    }
    if (rawTitle == 'وتەی قوتابیان') {
      return loc.get('student_quotes');
    }
    return rawTitle;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final localeProvider = LocaleProviderInherited.of(context);

    return Directionality(
      textDirection: localeProvider.textDirection,
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
                                _getLocalizedTitle(context, widget.title),
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${_newsItems.length} ${localizations.get('news')}',
                                style: TextStyle(
                                  color: AppColors.textSec(context),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_bookmarked.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.bookmark_rounded,
                                  size: 14,
                                  color: AppColors.secondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${_bookmarked.length}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.secondary,
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
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
              sliver: _isLoading
                  ? SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildShimmerCard(context),
                        childCount: 4,
                      ),
                    )
                  : _newsItems.isEmpty
                  ? SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 100),
                          child: Text(
                            localizations.get('no_data'),
                            style: TextStyle(
                              color: AppColors.isDark(context)
                                  ? Colors.white54
                                  : Colors.black54,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                            _buildNewsCard(context, _newsItems[index], index),
                        childCount: _newsItems.length,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerCard(BuildContext context) {
    return ClayContainer(
      margin: const EdgeInsets.only(bottom: 24),
      height: 340,
      color: AppColors.isDark(context)
          ? const Color(0xFF1E1E24)
          : const Color(0xFFE8EAF0),
      child: const SizedBox.expand(),
    ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1500.ms);
  }

  Widget _buildNewsCard(
    BuildContext context,
    Map<String, dynamic> item,
    int index,
  ) {
    final isBookmarked = _bookmarked.contains(index);
    return _PremiumNewsCard(
          item: item,
          index: index,
          isBookmarked: isBookmarked,
          onBookmark: () => _toggleBookmark(index),
        )
        .animate()
        .fadeIn(
          delay: (100 * index).ms,
          duration: 600.ms,
          curve: Curves.easeOutCirc,
        )
        .slideY(
          begin: 0.1,
          delay: (100 * index).ms,
          duration: 600.ms,
          curve: Curves.easeOutCirc,
        );
  }
}

class _PremiumNewsCard extends StatefulWidget {
  final Map<String, dynamic> item;
  final int index;
  final bool isBookmarked;
  final VoidCallback onBookmark;

  const _PremiumNewsCard({
    required this.item,
    required this.index,
    required this.isBookmarked,
    required this.onBookmark,
  });

  @override
  State<_PremiumNewsCard> createState() => _PremiumNewsCardState();
}

class _PremiumNewsCardState extends State<_PremiumNewsCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        setState(() => _isPressed = true);
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                NewsDetailScreen(newsItem: widget.item),
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
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        child: Container(
          margin: const EdgeInsets.only(bottom: 24),
          height: 360,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              if (_isPressed)
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                )
              else
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background Image
              ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Image(
                  image: cachedProvider(widget.item['image']?.toString() ?? ''),
                  fit: BoxFit.cover,
                ),
              ),
              // Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.4),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.95),
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1.5,
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Category Badge
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ),
                              child: Text(
                                localizations.get('news'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Bookmark
                        GestureDetector(
                          onTap: widget.onBookmark,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: widget.isBookmarked
                                      ? AppColors.secondary
                                      : Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Icon(
                                  widget.isBookmarked
                                      ? Icons.bookmark_rounded
                                      : Icons.bookmark_border_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Bottom Info
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Hero(
                          tag: 'news_title_${widget.item['title']}',
                          child: Material(
                            color: Colors.transparent,
                            child: Text(
                              widget.item['title']?.toString() ?? '',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                height: 1.3,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.access_time_rounded,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        TimeHelper.timeAgo(
                                          widget.item['time']?.toString() ??
                                              widget.item['created_at']
                                                  ?.toString(),
                                        ),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const Spacer(),
                            // Glowing Read More Button
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.25),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.12),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    localizations.get('read_more'),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                ],
                              ),
                            ),
                          ],
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
