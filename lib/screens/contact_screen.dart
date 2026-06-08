import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sd_institute/theme/app_colors.dart';
import 'package:sd_institute/services/institute_service.dart';
import 'package:sd_institute/widgets/clay_container.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sd_institute/utils/app_localizations.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  String _location = 'هەولێر - کوردستان\nنزیک شەقامی سەرەکی';
  String _phone = '0750 971 4545';
  String _email = 'info@sd.edu.krd';
  List<Map<String, dynamic>> _socialLinks = [];
  bool _loadingSocial = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final contact = await InstituteService.getContactInfo();
    final socials = await InstituteService.getSocialMedia();

    if (!mounted) return;
    setState(() {
      if (contact.isNotEmpty) {
        final loc = (contact['location'] ?? '').toString().trim();
        final ph = (contact['phone'] ?? '').toString().trim();
        final em = (contact['email'] ?? '').toString().trim();

        _location = loc.isNotEmpty ? loc : _location;
        _phone = ph.isNotEmpty ? ph : _phone;
        _email = em.isNotEmpty ? em : _email;
      }
      // Explicitly filter out WhatsApp and ensure list is from DB
      _socialLinks = socials.where((s) {
        final platform = (s['platform'] ?? '').toString().toLowerCase();
        return !platform.contains('whatsapp') &&
            !platform.contains('whats_app');
      }).toList();
      _loadingSocial = false;
    });
  }

  @override
  Widget build(BuildContext context) {
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
            // Atmospheric Background Orbs
            Positioned(
              top: -size.height * 0.1,
              right: -size.width * 0.2,
              child: _buildOrb(
                color: const Color(
                  0xFF6366F1,
                ).withValues(alpha: isDark ? 0.3 : 0.15),
                size: size.width * 0.8,
              ),
            ),
            Positioned(
              bottom: -size.height * 0.1,
              left: -size.width * 0.1,
              child: _buildOrb(
                color: const Color(
                  0xFFEC4899,
                ).withValues(alpha: isDark ? 0.2 : 0.1),
                size: size.width * 0.7,
              ),
            ),
            Positioned(
              top: size.height * 0.4,
              left: -size.width * 0.3,
              child: _buildOrb(
                color: const Color(
                  0xFF14B8A6,
                ).withValues(alpha: isDark ? 0.25 : 0.1),
                size: size.width * 0.6,
              ),
            ),

            // Glassmorphism Overlay
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                child: const SizedBox(),
              ),
            ),

            // Content
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
                        // Back Button
                        GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                Navigator.pop(context);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.1)
                                      : Colors.black.withValues(alpha: 0.05),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.arrow_back_ios_new,
                                  size: 18,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                            )
                            .animate()
                            .fadeIn(duration: 400.ms)
                            .slideY(begin: -0.2),

                        const SizedBox(height: 32),

                        // Title
                        Text(
                              localizations.get('contact_title'),
                              style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.w900,
                                height: 1.1,
                                letterSpacing: -1,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF111827),
                              ),
                            )
                            .animate()
                            .fadeIn(delay: 100.ms, duration: 600.ms)
                            .slideX(begin: 0.1),

                        const SizedBox(height: 40),

                        // Hero Panel
                        _buildHeroPanel(context, isDark, localizations),

                        const SizedBox(height: 40),

                        Text(
                          localizations.get('contact_info'),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF374151),
                          ),
                        ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1),

                        const SizedBox(height: 20),

                        // Contact Cards
                        _InteractiveGlassCard(
                          isDark: isDark,
                          icon: Icons.map_rounded,
                          iconColor: const Color(0xFFF59E0B),
                          title: localizations.get('address'),
                          subtitle: _location,
                          fullWidth: true,
                          delay: 400,
                          onTap: () => _openMaps(_location),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _InteractiveGlassCard(
                                isDark: isDark,
                                icon: Icons.phone_in_talk_rounded,
                                iconColor: const Color(0xFF10B981),
                                title: localizations.get('phone'),
                                subtitle: _phone,
                                fullWidth: false,
                                delay: 500,
                                onTap: () => _makeCall(_phone),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _InteractiveGlassCard(
                                isDark: isDark,
                                icon: Icons.alternate_email_rounded,
                                iconColor: const Color(0xFF3B82F6),
                                title: localizations.get('email'),
                                subtitle: _email,
                                fullWidth: false,
                                delay: 600,
                                onTap: () => _sendEmail(_email),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 40),

                        // ── Social Media Section ──────────────────────────
                        if (_loadingSocial || _socialLinks.isNotEmpty) ...[
                          Text(
                            localizations.get('social_media'),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF374151),
                            ),
                          ).animate().fadeIn(delay: 700.ms).slideX(begin: 0.1),

                          const SizedBox(height: 20),

                          if (_loadingSocial)
                            _buildSocialSkeleton(isDark)
                          else
                            SizedBox(
                              height: 90,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                clipBehavior: Clip.none,
                                itemCount: _socialLinks.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(width: 20),
                                itemBuilder: (context, index) {
                                  final social = _socialLinks[index];
                                  final platform = (social['platform'] ?? '')
                                      .toString();
                                  final url = (social['url'] ?? '').toString();
                                  final icon = _getPlatformIcon(platform);
                                  final color = _getPlatformColor(platform);

                                  return _buildSocialOrb(
                                    isDark,
                                    icon,
                                    color,
                                    800 + (index * 100),
                                    url,
                                  );
                                },
                              ),
                            ),
                        ],
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

  // ─── Skeleton loader for social orbs ──────────────────────────────────
  Widget _buildSocialSkeleton(bool isDark) {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        separatorBuilder: (_, _) => const SizedBox(width: 20),
        itemBuilder: (_, _) =>
            Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.black.withValues(alpha: 0.05),
                  ),
                )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .fadeIn(duration: 800.ms),
      ),
    );
  }

  // ─── Platform → Icon mapping ───────────────────────────────────────────
  IconData _getPlatformIcon(String platform) {
    final p = platform.toLowerCase();
    if (p.contains('facebook') || p.contains('fb')) {
      return Icons.facebook_rounded;
    } else if (p.contains('instagram') || p.contains('insta')) {
      return Icons.camera_alt_rounded;
    } else if (p.contains('tiktok') || p.contains('tik_tok')) {
      return Icons.music_note_rounded;
    } else if (p.contains('youtube') || p.contains('yt')) {
      return Icons.play_circle_fill_rounded;
    } else if (p.contains('twitter') || p.contains('x_')) {
      return Icons.alternate_email_rounded;
    } else if (p.contains('telegram')) {
      return Icons.send_rounded;
    } else if (p.contains('linkedin')) {
      return Icons.work_rounded;
    } else {
      return Icons.link_rounded;
    }
  }

  // ─── Platform → Color mapping ─────────────────────────────────────────
  Color _getPlatformColor(String platform) {
    final p = platform.toLowerCase();
    if (p.contains('facebook') || p.contains('fb')) {
      return const Color(0xFF1877F2);
    } else if (p.contains('instagram') || p.contains('insta')) {
      return const Color(0xFFE4405F);
    } else if (p.contains('tiktok') || p.contains('tik_tok')) {
      return const Color(0xFF010101);
    } else if (p.contains('youtube') || p.contains('yt')) {
      return const Color(0xFFFF0000);
    } else if (p.contains('twitter') || p.contains('x_')) {
      return const Color(0xFF1DA1F2);
    } else if (p.contains('telegram')) {
      return const Color(0xFF229ED9);
    } else if (p.contains('linkedin')) {
      return const Color(0xFF0A66C2);
    } else {
      return const Color(0xFF6366F1);
    }
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

  Widget _buildHeroPanel(BuildContext context, bool isDark, AppLocalizations localizations) {
    return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(36),
            boxShadow: [
              BoxShadow(
                color: const Color(
                  0xFF6366F1,
                ).withValues(alpha: isDark ? 0.2 : 0.15),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(36),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            Colors.white.withValues(alpha: 0.15),
                            Colors.white.withValues(alpha: 0.05),
                          ]
                        : [
                            Colors.white.withValues(alpha: 0.9),
                            Colors.white.withValues(alpha: 0.5),
                          ],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: isDark ? 0.2 : 0.6),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF818CF8), Color(0xFF4F46E5)],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF4F46E5,
                            ).withValues(alpha: 0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child:
                          const Icon(
                                Icons.rocket_launch_rounded,
                                color: Colors.white,
                                size: 36,
                              )
                              .animate(onPlay: (c) => c.repeat(reverse: true))
                              .moveY(
                                begin: -5,
                                end: 5,
                                duration: 3.seconds,
                                curve: Curves.easeInOutSine,
                              ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localizations.get('we_are_here'),
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            localizations.get('fast_response'),
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.6,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? Colors.white70
                                  : const Color(0xFF6B7280),
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
        .fadeIn(delay: 200.ms, duration: 800.ms, curve: Curves.easeOutExpo)
        .scaleXY(begin: 0.95, duration: 800.ms, curve: Curves.easeOutExpo);
  }

  // ─── URL Launcher Helpers ──────────────────────────────────────────────────
  Future<void> _makeCall(String phone) async {
    final cleaned = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    try {
      await launchUrl(Uri.parse('tel:$cleaned'));
    } catch (_) {}
  }

  Future<void> _sendEmail(String email) async {
    try {
      await launchUrl(Uri.parse('mailto:$email'));
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
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  Widget _buildSocialOrb(
    bool isDark,
    IconData icon,
    Color color,
    int delay,
    String url,
  ) {
    return _InteractiveSocialOrb(
          isDark: isDark,
          icon: icon,
          color: color,
          onTap: () => _openUrl(url),
        )
        .animate()
        .fadeIn(delay: delay.ms, duration: 600.ms)
        .scaleXY(begin: 0.5, curve: Curves.elasticOut, duration: 1000.ms);
  }
}

// ─── Interactive Glass Card ──────────────────────────────────────────────────────
class _InteractiveGlassCard extends StatefulWidget {
  final bool isDark;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool fullWidth;
  final int delay;
  final VoidCallback? onTap;

  const _InteractiveGlassCard({
    required this.isDark,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.fullWidth,
    required this.delay,
    this.onTap,
  });

  @override
  State<_InteractiveGlassCard> createState() => _InteractiveGlassCardState();
}

class _InteractiveGlassCardState extends State<_InteractiveGlassCard> {
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
            widget.onTap?.call();
          },
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedScale(
            scale: _isPressed ? 0.93 : 1.0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.elasticOut,
            child: ClayContainer(
              width: double.infinity,
              borderRadius: 28,
              depth: _isPressed ? 5 : 12,
              emboss: _isPressed,
              color: widget.isDark
                  ? const Color(0xFF1E1E24)
                  : const Color(0xFFE8EAF0),
              padding: EdgeInsets.all(widget.fullWidth ? 26 : 22),
              child: widget.fullWidth
                  ? Row(
                      children: [
                        _buildIconBox(),
                        const SizedBox(width: 20),
                        Expanded(child: _buildTextContent()),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: widget.isDark
                              ? Colors.white30
                              : Colors.black26,
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildIconBox(),
                        const SizedBox(height: 24),
                        _buildTextContent(),
                      ],
                    ),
            ),
          ),
        )
        .animate()
        .fadeIn(delay: widget.delay.ms)
        .slideY(begin: 0.15, curve: Curves.easeOutCubic);
  }

  Widget _buildIconBox() {
    return Container(
      padding: EdgeInsets.all(widget.fullWidth ? 18 : 16),
      decoration: BoxDecoration(
        color: widget.iconColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Icon(
        widget.icon,
        color: widget.iconColor,
        size: widget.fullWidth ? 28 : 26,
      ),
    );
  }

  Widget _buildTextContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: TextStyle(
            fontSize: widget.fullWidth ? 15 : 14,
            fontWeight: FontWeight.w600,
            color: widget.isDark ? Colors.white70 : Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.subtitle,
          style: TextStyle(
            fontSize: widget.fullWidth ? 18 : 16,
            fontWeight: FontWeight.w800,
            color: widget.isDark ? Colors.white : const Color(0xFF111827),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

// ─── Interactive Social Orb ──────────────────────────────────────────────────────
class _InteractiveSocialOrb extends StatefulWidget {
  final bool isDark;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _InteractiveSocialOrb({
    required this.isDark,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  State<_InteractiveSocialOrb> createState() => _InteractiveSocialOrbState();
}

class _InteractiveSocialOrbState extends State<_InteractiveSocialOrb> {
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
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.8 : 1.0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.elasticOut,
        child: Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: _isPressed ? 0.5 : 0.15),
                blurRadius: _isPressed ? 25 : 15,
                spreadRadius: _isPressed ? 4 : 0,
                offset: Offset(0, _isPressed ? 4 : 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(38),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.white.withValues(alpha: 0.8),
                  border: Border.all(
                    color: _isPressed
                        ? widget.color
                        : Colors.white.withValues(
                            alpha: widget.isDark ? 0.1 : 0.6,
                          ),
                    width: _isPressed ? 2 : 1.5,
                  ),
                ),
                child: Center(
                  child: Icon(widget.icon, color: widget.color, size: 30),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
