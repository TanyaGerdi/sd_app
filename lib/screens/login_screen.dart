import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sd_institute/services/auth_service.dart';
import 'package:sd_institute/services/api_service.dart';
import 'package:sd_institute/services/notification_service.dart';
import 'package:sd_institute/services/lecture_reminder_service.dart';
import 'package:sd_institute/theme/app_colors.dart';
import 'package:sd_institute/utils/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginScreen({super.key, required this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _isTeacher = false;
  String? _errorMessage;
  late AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isTeacher) {
        await AuthService.loginTeacher(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      } else {
        await AuthService.login(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      }

      // Register device token with newly logged-in student ID
      try {
        final fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken != null) {
          final platform = Platform.isIOS ? 'ios' : 'android';
          await NotificationService.registerToken(fcmToken, platform);
        }
      } catch (fcmError) {
        debugPrint('FCM Token registration on login failed: $fcmError');
      }

      // Start lecture reminder for teachers
      if (_isTeacher) {
        LectureReminderService.start();
      }

      if (!mounted) return;
      HapticFeedback.heavyImpact();
      widget.onLoginSuccess();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = ApiService.getErrorMessage(e);
      });
      HapticFeedback.vibrate();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final loc = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7),
      body: Stack(
        children: [
          // Ã¢â€â‚¬Ã¢â€â‚¬ Animated Mesh Background Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, child) {
              return Stack(
                children: [
                  Positioned(
                    top: -100 + (_bgController.value * 50),
                    right: -80 - (_bgController.value * 30),
                    child: Container(
                      width: 400,
                      height: 400,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: isDark ? 0.35 : 0.15),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -120 - (_bgController.value * 40),
                    left: -60 + (_bgController.value * 20),
                    child: Container(
                      width: 350,
                      height: 350,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.accent.withValues(alpha: isDark ? 0.25 : 0.1),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: size.height * 0.4,
                    left: size.width * 0.3,
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.secondary.withValues(alpha: isDark ? 0.15 : 0.06),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          // Global blur
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: const SizedBox(),
            ),
          ),
          // Ã¢â€â‚¬Ã¢â€â‚¬ Content Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: SizedBox(
                height: size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                child: Column(
                  children: [
                    const Spacer(flex: 2),
                    // Ã¢â€â‚¬Ã¢â€â‚¬ Logo & Branding Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
                    Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.white.withValues(alpha: 0.7),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.12)
                                  : AppColors.primary.withValues(alpha: 0.15),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: isDark ? 0.3 : 0.15),
                                blurRadius: 40,
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
                        .animate()
                        .scaleXY(begin: 0.5, end: 1.0, duration: 800.ms, curve: Curves.easeOutBack)
                        .fadeIn(duration: 600.ms),
                    const SizedBox(height: 24),
                    Text(
                      loc.get('institute_name'),
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : const Color(0xFF111827),
                        letterSpacing: -0.5,
                      ),
                    ).animate().fadeIn(delay: 200.ms, duration: 500.ms).slideY(begin: 0.1),
                    const SizedBox(height: 8),
                    Text(
                      loc.get('login_subtitle'),
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white60 : Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
                    const SizedBox(height: 40),
                    // Ã¢â€â‚¬Ã¢â€â‚¬ Login Form Card Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
                    ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: Container(
                              padding: const EdgeInsets.all(28),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(28),
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.06)
                                    : Colors.white.withValues(alpha: 0.75),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.1)
                                      : Colors.black.withValues(alpha: 0.06),
                                  width: 1,
                                ),
                                boxShadow: isDark
                                    ? []
                                    : [
                                        BoxShadow(
                                          color: AppColors.primary.withValues(alpha: 0.06),
                                          blurRadius: 30,
                                          offset: const Offset(0, 12),
                                        ),
                                      ],
                              ),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // Error message
                                    if (_errorMessage != null) ...[
                                      Container(
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFF3B30).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(
                                            color: const Color(0xFFFF3B30).withValues(alpha: 0.3),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.error_outline_rounded,
                                              color: Color(0xFFFF3B30),
                                              size: 20,
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                _errorMessage!,
                                                style: const TextStyle(
                                                  color: Color(0xFFFF3B30),
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ).animate().fadeIn(duration: 300.ms).shake(hz: 2, duration: 400.ms),
                                      const SizedBox(height: 20),
                                    ],
                                    // Role toggle
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 20),
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _isTeacher = false;
                                                  _errorMessage = null;
                                                });
                                              },
                                              child: AnimatedContainer(
                                                duration: const Duration(milliseconds: 250),
                                                padding: const EdgeInsets.symmetric(vertical: 12),
                                                decoration: BoxDecoration(
                                                  color: !_isTeacher
                                                      ? AppColors.primary
                                                      : Colors.transparent,
                                                  borderRadius: BorderRadius.circular(12),
                                                  boxShadow: !_isTeacher
                                                      ? [
                                                          BoxShadow(
                                                            color: AppColors.primary.withValues(alpha: 0.3),
                                                            blurRadius: 10,
                                                            offset: const Offset(0, 4),
                                                          )
                                                        ]
                                                      : [],
                                                ),
                                                alignment: Alignment.center,
                                                child: Text(
                                                  loc.get('student'),
                                                  style: TextStyle(
                                                    color: !_isTeacher ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                    fontFamily: 'NotoKufiArabic',
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _isTeacher = true;
                                                  _errorMessage = null;
                                                });
                                              },
                                              child: AnimatedContainer(
                                                duration: const Duration(milliseconds: 250),
                                                padding: const EdgeInsets.symmetric(vertical: 12),
                                                decoration: BoxDecoration(
                                                  color: _isTeacher
                                                      ? AppColors.primary
                                                      : Colors.transparent,
                                                  borderRadius: BorderRadius.circular(12),
                                                  boxShadow: _isTeacher
                                                      ? [
                                                          BoxShadow(
                                                            color: AppColors.primary.withValues(alpha: 0.3),
                                                            blurRadius: 10,
                                                            offset: const Offset(0, 4),
                                                          )
                                                        ]
                                                      : [],
                                                ),
                                                alignment: Alignment.center,
                                                child: Text(
                                                  loc.get('teacher'),
                                                  style: TextStyle(
                                                    color: _isTeacher ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                    fontFamily: 'NotoKufiArabic',
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Email field
                                    _buildTextField(
                                      controller: _emailController,
                                      label: loc.get('email'),
                                      icon: Icons.email_rounded,
                                      isDark: isDark,
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return loc.get('email');
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 18),
                                    // Password field
                                    _buildTextField(
                                      controller: _passwordController,
                                      label: loc.get('password'),
                                      icon: Icons.lock_rounded,
                                      isDark: isDark,
                                      obscure: _obscurePassword,
                                      suffix: GestureDetector(
                                        onTap: () {
                                          setState(() => _obscurePassword = !_obscurePassword);
                                        },
                                        child: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_off_rounded
                                              : Icons.visibility_rounded,
                                          color: isDark ? Colors.white38 : Colors.black38,
                                          size: 22,
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return loc.get('password');
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 28),
                                    // Login button
                                    _buildLoginButton(isDark, loc),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 400.ms, duration: 600.ms)
                        .slideY(begin: 0.08, delay: 400.ms, duration: 600.ms, curve: Curves.easeOutCubic),
                    const Spacer(flex: 3),
                  ],
                ),
              ),
            ),
          ),
          // Ã¢â€â‚¬Ã¢â€â‚¬ Back Button Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            child: ClayBackButton(isDark: isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    TextInputType? keyboardType,
    bool obscure = false,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      validator: validator,
      style: TextStyle(
        color: isDark ? Colors.white : const Color(0xFF111827),
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? Colors.white38 : Colors.black38,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(
          icon,
          color: isDark ? AppColors.primaryLight : AppColors.primary,
          size: 22,
        ),
        suffixIcon: suffix,
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : const Color(0xFFF5F5F7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.04),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.6),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: Color(0xFFFF3B30),
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
    );
  }

  Widget _buildLoginButton(bool isDark, AppLocalizations loc) {
    return GestureDetector(
      onTap: _isLoading ? null : _handleLogin,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: _isLoading
                ? [
                    AppColors.primary.withValues(alpha: 0.5),
                    const Color(0xFF8B5CF6).withValues(alpha: 0.5),
                  ]
                : [AppColors.primary, const Color(0xFF8B5CF6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: _isLoading ? 0.1 : 0.35),
              blurRadius: 20,
              spreadRadius: -2,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.login_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      loc.get('login'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Back button for the login screen
class ClayBackButton extends StatelessWidget {
  final bool isDark;
  const ClayBackButton({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.7),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.12)
                    : Colors.black.withValues(alpha: 0.06),
              ),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: isDark ? Colors.white70 : const Color(0xFF111827),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.2, duration: 300.ms);
  }
}
