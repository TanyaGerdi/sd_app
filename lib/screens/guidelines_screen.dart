import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sd_institute/theme/app_colors.dart';
import 'package:sd_institute/services/institute_service.dart';
import 'package:sd_institute/widgets/cached_image.dart';
import 'package:sd_institute/widgets/clay_container.dart';
import 'package:sd_institute/utils/app_localizations.dart';

class GuidelinesScreen extends StatefulWidget {
  const GuidelinesScreen({super.key});

  @override
  State<GuidelinesScreen> createState() => _GuidelinesScreenState();
}

class _GuidelinesScreenState extends State<GuidelinesScreen> {
  List<Map<String, dynamic>> _guidelines = [];
  bool _isLoading = true;

  // These are now fetched from the database
  String _admissionImageUrl = '';
  String _academicYear = '2024-2025';

  // Localized fallback defaults when the database has nothing yet
  List<Map<String, dynamic>> _getLocalizedFallbacks(String lang) {
    if (lang == 'en') {
      return [
        {
          'title': 'Admission Requirements for Private Universities & Institutes',
          'content':
              'After graduating from high school, students must register in the Zankoline system; they will then be admitted to public universities and institutes according to the plan and grades set by the ministry.\n\nAfter the results are announced, the ministry will also announce enrollment in private institutes.',
        },
        {
          'title': 'Admission Guidelines According to Internal Regulations',
          'content':
              'Graduates of previous academic years have the right to apply.\n\nAccording to the specific requirements set for each department, the candidate must pass the medical examination.',
        },
        {
          'title': 'Registration Requirements',
          'content':
              '• High school graduation certificate certified by the Directorate of Education.\n• Civil status ID or National Card.\n• Recent personal photos with a white background.',
        },
      ];
    } else if (lang == 'ar') {
      return [
        {
          'title': 'شروط الدراسة في الجامعات والمعاهد الأهلية',
          'content':
              'بعد تخرج الطلاب من المرحلة الإعدادية، يجب عليهم التسجيل في نظام زانكولاين؛ ثم يتم قبولهم في الجامعات والمعاهد الحكومية وفقاً للخطة والدرجات التي تحددها الوزارة.\n\nبعد إعلان النتائج، تعلن الوزارة أيضاً عن فتح باب القبول في المعاهد الأهلية.',
        },
        {
          'title': 'تعليمات القبول وفق النظام الداخلي',
          'content':
              'يحق لخريجي السنوات السابقة التقديم.\n\nوفقاً للشروط الخاصة المحددة لكل تخصص، يجب على المتقدم اجتياز الفحص الطبي.',
        },
        {
          'title': 'مستندات التسجيل المطلوبة',
          'content':
              '• وثيقة تخرج الدراسة الإعدادية مصدقة من مديرية التربية.\n• هوية الأحوال المدنية أو البطاقة الوطنية.\n• صور شخصية حديثة بخلفية بيضاء.',
        },
      ];
    } else {
      return [
        {
          'title': 'مەرجی خوێندن لە زانکۆ و پەیمانگە تایبەتەکان',
          'content':
              'دوای دەرچوونی قوتابییان لە پۆلی دوازدەی ئامادەیی، پێویستە لە زانکۆلاین خۆیان تۆماربکەن؛ دواتر بە گوێرەی ئەو پلان و نمرەیەی کە وەزارەت دایناوە، لە زانکۆ و پەیمانگە حکومییەکان وەردەگیرێن.\n\nپاش گەراوەی ناوەکان، وەزارەت ناونووسین لە پەیمانگە تایبەتەکانیش رادەگەیەنێ.',
        },
        {
          'title': 'ڕێنمایی وەرگرتن بەپێی سیستەمی ناوەخۆیی',
          'content':
              'دەرچووانی ساڵانی پێشووی ئامادەیی، مافی پێشکەشکردنیان هەیە.\n\nبەپێی ئەو مەرجە تایبەتانەی بۆ هەر خوێندنێک دیاریکراوە، پێویستە لە پشکنینی پزیشکی دەرچووبێت.',
        },
        {
          'title': 'پێداویستییەکانی تۆمارکردن',
          'content':
              '• بڕوانامەی دەرچوونی پۆلی دوازدە کە پەسەندکراو بێت لەلایەن پەروەردە.\n• پێناسی باری شارستانی یان کارتی نیشتمانی.\n• وێنەی کەسی تازە بە باکگراوندی سپی.',
        },
      ];
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Load all three in parallel for speed
    final results = await Future.wait([
      InstituteService.getGuidelines(),
      InstituteService.getAdmissionImage(),
      InstituteService.getAcademicYear(),
    ]);

    if (!mounted) return;

    final data = results[0] as List<Map<String, dynamic>>;
    final imgUrl = (results[1] as String).trim();
    final year = (results[2] as String).trim();

    setState(() {
      _guidelines = data;
      _admissionImageUrl = imgUrl;
      _academicYear = year.isNotEmpty ? year : '2024-2025';
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final size = MediaQuery.of(context).size;
    final localeProvider = LocaleProviderInherited.of(context);
    final lang = localeProvider.language.name;

    final displayGuidelines = _guidelines.isNotEmpty
        ? _guidelines
        : _getLocalizedFallbacks(lang);

    final displayAcademicYear = lang == 'en'
        ? 'Academic Year $_academicYear'
        : (lang == 'ar' ? 'العام الدراسي $_academicYear' : 'ساڵی خوێندنی $_academicYear');

    final displayTitle = lang == 'en'
        ? 'Student Admission\nGuidelines'
        : (lang == 'ar' ? 'إرشادات\nقبول الطلاب' : 'ڕێنماییەکانی\nوەرگرتنی قوتابییان');

    return Directionality(
      textDirection: localeProvider.textDirection,
      child: Scaffold(
        backgroundColor: isDark
            ? const Color(0xFF000000)
            : const Color(0xFFF2F2F7),
        body: Stack(
          children: [
            // Background orbs
            Positioned(
              top: -size.height * 0.1,
              right: -size.width * 0.3,
              child: _buildOrb(
                color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.1),
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
                // ── Hero AppBar ──────────────────────────────────────
                SliverAppBar(
                  expandedHeight: 320,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  stretch: true,
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
                    stretchModes: const [
                      StretchMode.zoomBackground,
                      StretchMode.blurBackground,
                    ],
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Background: DB image OR gradient fallback
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(40),
                          ),
                          child: _admissionImageUrl.isNotEmpty
                              ? CachedImage(
                                  imageUrl: _admissionImageUrl,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFF6366F1),
                                        Color(0xFF2563EB),
                                        Color(0xFF6366F1),
                                      ],
                                    ),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.menu_book_rounded,
                                      size: 60,
                                      color: Colors.white24,
                                    ),
                                  ),
                                ),
                        ),

                        // Gradient overlay so text is always readable
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(40),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                (isDark
                                        ? const Color(0xFF000000)
                                        : const Color(0xFFF2F2F7))
                                    .withValues(alpha: 0.95),
                                (isDark
                                        ? const Color(0xFF000000)
                                        : const Color(0xFFF2F2F7))
                                    .withValues(alpha: 0.4),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.4, 1.0],
                            ),
                          ),
                        ),

                        // Bottom text overlay
                        Positioned(
                          bottom: 40,
                          left: 24,
                          right: 24,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Academic year badge
                              Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.2,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.primary.withValues(
                                          alpha: 0.5,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      displayAcademicYear,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? Colors.white
                                            : AppColors.primary,
                                      ),
                                    ),
                                  )
                                  .animate()
                                  .fadeIn(delay: 200.ms)
                                  .slideY(begin: 0.2),

                              const SizedBox(height: 16),

                              Text(
                                    displayTitle,
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF111827),
                                      fontSize: 36,
                                      fontWeight: FontWeight.w900,
                                      height: 1.1,
                                      letterSpacing: -1,
                                    ),
                                  )
                                  .animate()
                                  .fadeIn(delay: 300.ms)
                                  .slideX(begin: 0.1),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Guidelines List
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 60),
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List.generate(displayGuidelines.length, (i) {
                              final g = displayGuidelines[i];
                              final idx = (i + 1).toString().padLeft(2, '0');
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom: i < displayGuidelines.length - 1 ? 32 : 0,
                                ),
                                child: _buildEditorialSection(
                                  context,
                                  isDark,
                                  index: idx,
                                  title: g['title']?.toString() ?? 'Guidelines',
                                  content: g['content']?.toString() ?? '',
                                  delay: 400 + i * 150,
                                ),
                              );
                            }),
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

  Widget _buildEditorialSection(
    BuildContext context,
    bool isDark, {
    required String index,
    required String title,
    required String content,
    required int delay,
  }) {
    return ClayContainer(
          width: double.infinity,
          borderRadius: 32,
          depth: 12,
          color: isDark ? const Color(0xFF1E1E24) : const Color(0xFFE8EAF0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Stack(
              children: [
                // Giant watermark index number
                Positioned(
                  right: -20,
                  top: -30,
                  child: Text(
                    index,
                    style: TextStyle(
                      fontSize: 160,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -10,
                      color: AppColors.primary.withValues(
                        alpha: isDark ? 0.05 : 0.03,
                      ),
                      height: 1.0,
                    ),
                  ),
                ),
                // Animated left accent bar
                Positioned(
                  left: 0,
                  top: 40,
                  bottom: 40,
                  child:
                      Container(
                            width: 4,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: const BorderRadius.horizontal(
                                right: Radius.circular(4),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.5,
                                  ),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          )
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .shimmer(duration: 2.seconds, color: Colors.white),
                ),
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF111827),
                          height: 1.4,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        content,
                        style: TextStyle(
                          fontSize: 16,
                          height: 2.0,
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
        )
        .animate()
        .fadeIn(delay: delay.ms, duration: 800.ms)
        .slideY(begin: 0.15, curve: Curves.easeOutQuart);
  }
}
