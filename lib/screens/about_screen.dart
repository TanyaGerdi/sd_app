import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sd_institute/theme/app_colors.dart';
import 'package:sd_institute/services/institute_service.dart';
import 'package:sd_institute/widgets/clay_container.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sd_institute/utils/app_localizations.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  // ─── Live data with fallback defaults ───
  String _instituteName = 'پەیمانگەی SD';
  String _instituteTagline = 'SD Technical Institute';
  final String _instituteSlogan = 'داهاتووتان بنیاد دەنێین';
  String _instituteDescription =
      'پەیمانگەی SD بۆ خوێندنی تەکنیکی و پیشەیی و پێگەیاندنی کادری ئەکادیمی و پیشەیی بەرز بە فەرمانی فەرمی دامەزراوە.\n\nئامانجمان پێگەیاندنی نەوەیەکی هۆشیار و لێهاتوو و زانستخوازە کە بتوانن خزمەت بە بازاڕی کار و کۆمەڵگە بکەن.';

  String _statsDepartments = '٦';
  String _statsTeachers = '+٣٠';
  String _statsStudents = '+٥٠٠';

  String _contactLocation = 'هەولێر، کوردستان';
  String _contactPhone = '+964 750 000 0000';
  String _contactEmail = 'info@sd.edu.krd';
  String _contactWebsite = 'www.sd.edu.krd';

  String _weekdayHours = '٨:٠٠ — ٣:٠٠';
  String _weekendHours = 'پشوو';
  String _weekdayLabel = 'یەکشەممە — پێنجشەممە';
  String _weekendLabel = 'هەینی — شەممە';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Fetch all data in parallel
    final results = await Future.wait([
      InstituteService.getInstitute(),
      InstituteService.getStats(),
      InstituteService.getContactInfo(),
      InstituteService.getWorkingHours(),
    ]);

    final institute = results[0];
    final stats = results[1];
    final contact = results[2];
    final hours = results[3];

    if (!mounted) return;
    setState(() {
      if (institute.isNotEmpty) {
        final iName = (institute['name'] ?? '').toString().trim();
        final iTag = (institute['tagline'] ?? '').toString().trim();
        final iDesc = (institute['description'] ?? '').toString().trim();

        _instituteName = iName.isNotEmpty ? iName : _instituteName;
        _instituteTagline = iTag.isNotEmpty ? iTag : _instituteTagline;
        _instituteDescription = iDesc.isNotEmpty
            ? iDesc
            : _instituteDescription;
      }
      if (stats.isNotEmpty) {
        final sDept = (stats['departments_count'] ?? '').toString().trim();
        final sTeach = (stats['teachers_count'] ?? '').toString().trim();
        final sStud = (stats['students_count'] ?? '').toString().trim();

        _statsDepartments = sDept.isNotEmpty ? sDept : _statsDepartments;
        _statsTeachers = sTeach.isNotEmpty
            ? (sTeach == '0' ? '0' : '+$sTeach')
            : _statsTeachers;
        _statsStudents = sStud.isNotEmpty
            ? (sStud == '0' ? '0' : '+$sStud')
            : _statsStudents;
      }
      if (contact.isNotEmpty) {
        final cLoc = (contact['location'] ?? '').toString().trim();
        final cPhone = (contact['phone'] ?? '').toString().trim();
        final cEmail = (contact['email'] ?? '').toString().trim();
        final cWeb = (contact['website'] ?? '').toString().trim();

        _contactLocation = cLoc.isNotEmpty ? cLoc : _contactLocation;
        _contactPhone = cPhone.isNotEmpty ? cPhone : _contactPhone;
        _contactEmail = cEmail.isNotEmpty ? cEmail : _contactEmail;
        _contactWebsite = cWeb.isNotEmpty ? cWeb : _contactWebsite;
      }
      if (hours.isNotEmpty) {
        final hWeekd = (hours['weekdays'] ?? '').toString().trim();
        final hWeeke = (hours['weekend'] ?? '').toString().trim();
        final hDays = (hours['working_days'] ?? '').toString().trim();
        final hWeekendDays = (hours['weekend_days'] ?? '').toString().trim();

        _weekdayHours = hWeekd.isNotEmpty ? hWeekd : _weekdayHours;
        _weekendHours = hWeeke.isNotEmpty ? hWeeke : _weekendHours;
        _weekdayLabel = hDays.isNotEmpty ? hDays : _weekdayLabel;
        _weekendLabel = hWeekendDays.isNotEmpty ? hWeekendDays : _weekendLabel;
      }
    });
  }

  String getLocalizedWeekendHours(String lang) {
    if (lang == 'en') return 'Holiday';
    if (lang == 'ar') return 'عطلة';
    return 'پشوو';
  }

  String getLocalizedWeekdayLabel(String lang) {
    if (lang == 'en') return 'Sunday — Thursday';
    if (lang == 'ar') return 'الأحد — الخميس';
    return 'یەکشەممە — پێنجشەممە';
  }

  String getLocalizedWeekendLabel(String lang) {
    if (lang == 'en') return 'Friday — Saturday';
    if (lang == 'ar') return 'الجمعة — السبت';
    return 'هەینی — شەممە';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final canGoBack = Navigator.canPop(context);
    final size = MediaQuery.of(context).size;
    final localizations = AppLocalizations.of(context);
    final localeProvider = LocaleProviderInherited.of(context);
    final lang = localeProvider.language.name;

    final displayWeekdayLabel = _weekdayLabel == 'یەکشەممە — پێنجشەممە' ? getLocalizedWeekdayLabel(lang) : _weekdayLabel;
    final displayWeekendLabel = _weekendLabel == 'هەینی — شەممە' ? getLocalizedWeekendLabel(lang) : _weekendLabel;
    final displayWeekendHours = _weekendHours == 'پشوو' ? getLocalizedWeekendHours(lang) : _weekendHours;

    return Directionality(
      textDirection: localeProvider.textDirection,
      child: Scaffold(
        backgroundColor: isDark
            ? const Color(0xFF000000)
            : const Color(0xFFF2F2F7),
        body: Stack(
          children: [
            // Ambient Aura Meshes
            Positioned(
              top: -100,
              right: -100,
              child: _buildOrb(
                color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.08),
                size: size.width * 0.9,
              ),
            ),
            Positioned(
              bottom: -50,
              left: -50,
              child: _buildOrb(
                color: AppColors.secondary.withValues(
                  alpha: isDark ? 0.15 : 0.05,
                ),
                size: size.width,
              ),
            ),
            // Global Glass Filter
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                child: const SizedBox(),
              ),
            ),

            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 16,
                      left: 20,
                      right: 20,
                      bottom: 120,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Premium Header
                        Row(
                          children: [
                            if (canGoBack)
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
                                            ? Colors.white.withValues(
                                                alpha: 0.1,
                                              )
                                            : Colors.black.withValues(
                                                alpha: 0.03,
                                              ),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: isDark
                                              ? Colors.white.withValues(
                                                  alpha: 0.15,
                                                )
                                              : Colors.black.withValues(
                                                  alpha: 0.05,
                                                ),
                                        ),
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
                            if (canGoBack) const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                localizations.get('about_title'),
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF111827),
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                          ],
                        ).animate().fadeIn(
                          duration: 400.ms,
                          curve: Curves.easeOutCirc,
                        ),

                        const SizedBox(height: 32),

                        // Aura Banner Card
                        ClipRRect(
                              borderRadius: BorderRadius.circular(32),
                              child: Stack(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(32),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: isDark
                                            ? [
                                                const Color(0xFF1A1A2E),
                                                const Color(0xFF0E0E1A),
                                              ]
                                            : [
                                                AppColors.primary,
                                                AppColors.primary.withValues(
                                                  alpha: 0.85,
                                                ),
                                              ],
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Container(
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withValues(
                                                  alpha: 0.2,
                                                ),
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withValues(alpha: 0.1),
                                                    blurRadius: 20,
                                                    spreadRadius: 5,
                                                  ),
                                                ],
                                              ),
                                              child: ClipOval(
                                                child: Image.asset(
                                                  'assets/img/sd_logo.png',
                                                  width: 80,
                                                  height: 80,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            )
                                            .animate(
                                              onPlay: (c) =>
                                                  c.repeat(reverse: true),
                                            )
                                            .scaleXY(
                                              begin: 0.95,
                                              end: 1.05,
                                              duration: 4.seconds,
                                              curve: Curves.easeInOut,
                                            ),
                                        const SizedBox(height: 20),
                                        Text(
                                          _instituteName,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 26,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: -0.5,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          _instituteTagline,
                                          style: TextStyle(
                                            color: Colors.white.withValues(
                                              alpha: 0.8,
                                            ),
                                            fontSize: 14,
                                            letterSpacing: 2,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 12),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(
                                              alpha: 0.15,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Text(
                                            _instituteSlogan,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Glass reflection sweep
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.white.withValues(alpha: 0.4),
                                            Colors.transparent,
                                            Colors.transparent,
                                          ],
                                          stops: const [0.0, 0.2, 1.0],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                            .animate()
                            .fadeIn(
                              delay: 100.ms,
                              duration: 600.ms,
                              curve: Curves.easeOutCirc,
                            )
                            .slideY(
                              begin: 0.1,
                              delay: 100.ms,
                              duration: 600.ms,
                              curve: Curves.easeOutCirc,
                            ),

                        const SizedBox(height: 24),

                        // Aura Stats Row
                        Row(
                          children: [
                            _buildStatCard(
                              context,
                              isDark,
                              Icons.school_rounded,
                              _statsDepartments,
                              localizations.get('departments'),
                              const Color(0xFF5B8DEF),
                              200,
                            ),
                            const SizedBox(width: 12),
                            _buildStatCard(
                              context,
                              isDark,
                              Icons.groups_rounded,
                              _statsTeachers,
                              localizations.get('teachers_count'),
                              const Color(0xFFE8985E),
                              300,
                            ),
                            const SizedBox(width: 12),
                            _buildStatCard(
                              context,
                              isDark,
                              Icons.person_rounded,
                              _statsStudents,
                              localizations.get('students_count'),
                              const Color(0xFF48C78E),
                              400,
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Story Component
                        _buildGlassPanel(
                          context,
                          isDark,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildCardTitle(
                                context,
                                isDark,
                                localizations.get('our_story'),
                                AppColors.secondary,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                _instituteDescription,
                                style: TextStyle(
                                  height: 2.2,
                                  color: isDark
                                      ? Colors.white70
                                      : const Color(0xFF4B5563),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          delay: 500,
                        ),

                        const SizedBox(height: 24),

                        // Contact Details Component
                        _buildGlassPanel(
                          context,
                          isDark,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildCardTitle(
                                context,
                                isDark,
                                localizations.get('contact_info'),
                                AppColors.accent,
                              ),
                              const SizedBox(height: 24),
                              _buildContactItem(
                                context,
                                isDark,
                                Icons.location_on_rounded,
                                _contactLocation,
                                AppColors.accent,
                                copyable: false,
                                onTap: () => _openMaps(_contactLocation),
                              ),
                              _buildDivider(isDark),
                              _buildContactItem(
                                context,
                                isDark,
                                Icons.phone_rounded,
                                _contactPhone,
                                AppColors.secondary,
                                onTap: () => _makeCall(_contactPhone),
                              ),
                              _buildDivider(isDark),
                              _buildContactItem(
                                context,
                                isDark,
                                Icons.email_rounded,
                                _contactEmail,
                                const Color(0xFF48C78E),
                                onTap: () => _sendEmail(_contactEmail),
                              ),
                              _buildDivider(isDark),
                              _buildContactItem(
                                context,
                                isDark,
                                Icons.language_rounded,
                                _contactWebsite,
                                const Color(0xFFA55EEA),
                                onTap: () =>
                                    _openUrl('https://$_contactWebsite'),
                              ),
                            ],
                          ),
                          delay: 600,
                        ),

                        const SizedBox(height: 24),

                        // Working Hours Component
                        _buildGlassPanel(
                          context,
                          isDark,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildCardTitle(
                                context,
                                isDark,
                                localizations.get('working_hours'),
                                const Color(0xFF48C78E),
                              ),
                              const SizedBox(height: 24),
                              _buildHourRow(
                                context,
                                isDark,
                                displayWeekdayLabel,
                                _weekdayHours,
                              ),
                              const SizedBox(height: 16),
                              _buildHourRow(
                                context,
                                isDark,
                                displayWeekendLabel,
                                displayWeekendHours,
                                isOff: true,
                              ),
                            ],
                          ),
                          delay: 700,
                        ),

                        const SizedBox(height: 48),

                        // Social Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildSocialIcon(
                              context,
                              isDark,
                              Icons.facebook,
                              const Color(0xFF1877F2),
                              'https://facebook.com/sdinstitute',
                            ),
                            const SizedBox(width: 16),
                            _buildSocialIcon(
                              context,
                              isDark,
                              Icons.camera_alt_rounded,
                              const Color(0xFFE4405F),
                              'https://instagram.com/sdinstitute',
                            ),
                            const SizedBox(width: 16),
                            _buildSocialIcon(
                              context,
                              isDark,
                              Icons.play_arrow_rounded,
                              isDark ? Colors.white : Colors.black87,
                              'https://tiktok.com/@sdinstitute',
                            ),
                            const SizedBox(width: 16),
                            _buildSocialIcon(
                              context,
                              isDark,
                              Icons.telegram,
                              const Color(0xFF0088CC),
                              'https://t.me/sdinstitute',
                            ),
                          ],
                        )
                        .animate()
                        .fadeIn(delay: 800.ms, duration: 600.ms)
                        .slideY(begin: 0.2, curve: Curves.easeOutCirc),
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
            blurRadius: size * 0.4,
            spreadRadius: size * 0.1,
          ),
        ],
      ),
    );
  }

  Widget _buildGlassPanel(
    BuildContext context,
    bool isDark, {
    required Widget child,
    required int delay,
  }) {
    return ClayContainer(
          width: double.infinity,
          borderRadius: 28,
          depth: 12,
          color: isDark ? const Color(0xFF1E1E24) : const Color(0xFFE8EAF0),
          padding: const EdgeInsets.all(26),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: isDark ? 0.03 : 0.14),
                  Colors.transparent,
                  AppColors.primary.withValues(alpha: isDark ? 0.03 : 0.04),
                ],
              ),
            ),
            child: child,
          ),
        )
        .animate()
        .fadeIn(delay: delay.ms, duration: 600.ms)
        .slideY(begin: 0.1, curve: Curves.easeOutCirc);
  }

  Widget _buildCardTitle(
    BuildContext context,
    bool isDark,
    String title,
    Color color,
  ) {
    return Row(
      children: [
        Container(
              width: 5,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
            )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .shimmer(duration: 2.seconds, color: Colors.white),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : const Color(0xFF111827),
              letterSpacing: -0.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    bool isDark,
    IconData icon,
    String value,
    String label,
    Color color,
    int delay,
  ) {
    return Expanded(
      child:
          _InteractiveGlassCard(
                isDark: isDark,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 8,
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: isDark ? 0.18 : 0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: color.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Icon(icon, color: color, size: 20),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: color,
                          letterSpacing: -1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.white60
                              : const Color(0xFF6B7280),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              )
              .animate()
              .fadeIn(delay: delay.ms, duration: 500.ms)
              .scaleXY(begin: 0.8, curve: Curves.easeOutBack),
    );
  }

  Widget _buildContactItem(
    BuildContext context,
    bool isDark,
    IconData icon,
    String text,
    Color color, {
    bool copyable = true,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        if (onTap != null) {
          onTap();
        } else if (copyable) {
          Clipboard.setData(ClipboardData(text: text));
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.15 : 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white : const Color(0xFF111827),
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (copyable)
            Icon(
              Icons.copy_rounded,
              color: isDark ? Colors.white30 : Colors.black26,
              size: 20,
            ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Divider(
        height: 1,
        color: isDark
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.black.withValues(alpha: 0.05),
      ),
    );
  }

  Widget _buildHourRow(
    BuildContext context,
    bool isDark,
    String day,
    String time, {
    bool isOff = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            day,
            style: TextStyle(
              fontSize: 15,
              color: isDark ? Colors.white70 : const Color(0xFF4B5563),
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isOff
                ? (isDark ? const Color(0xFF3D1F1F) : const Color(0xFFFFF0F0))
                : (isDark ? const Color(0xFF1F3D2A) : const Color(0xFFF0FFF5)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isOff
                  ? const Color(0xFFFC5C65).withValues(alpha: 0.3)
                  : const Color(0xFF48C78E).withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            time,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isOff ? const Color(0xFFFC5C65) : const Color(0xFF48C78E),
            ),
          ),
        ),
      ],
    );
  }

  // ─── URL Launcher Helpers ─────────────────────────────────────────────
  Future<void> _makeCall(String phone) async {
    final cleaned = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('tel:$cleaned');
    try {
      await launchUrl(uri);
    } catch (_) {}
  }

  Future<void> _sendEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    try {
      await launchUrl(uri);
    } catch (_) {}
  }

  Future<void> _openMaps(String location) async {
    final encoded = Uri.encodeComponent(location);
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$encoded',
    );
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  Widget _buildSocialIcon(
    BuildContext context,
    bool isDark,
    IconData icon,
    Color color,
    String url,
  ) {
    return _InteractiveGlassCard(
      isDark: isDark,
      child: GestureDetector(
        onTap: () => _openUrl(url),
        child: Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 26),
        ),
      ),
    );
  }
}

class _InteractiveGlassCard extends StatefulWidget {
  final Widget child;
  final bool isDark;

  const _InteractiveGlassCard({required this.child, required this.isDark});

  @override
  State<_InteractiveGlassCard> createState() => _InteractiveGlassCardState();
}

class _InteractiveGlassCardState extends State<_InteractiveGlassCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.selectionClick();
        setState(() => _isPressed = true);
      },
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: ClayContainer(
          borderRadius: 24,
          depth: _isPressed ? 4 : 10,
          spread: _isPressed ? 0 : 2,
          emboss: _isPressed,
          color: widget.isDark
              ? const Color(0xFF1E1E24)
              : const Color(0xFFE8EAF0),
          child: widget.child,
        ),
      ),
    );
  }
}
