import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sd_institute/theme/app_colors.dart';
import 'package:sd_institute/screens/staff_detail_screen.dart';
import 'package:sd_institute/widgets/cached_image.dart';
import 'package:sd_institute/services/staff_service.dart';
import 'package:sd_institute/utils/app_localizations.dart';

class StaffScreen extends StatefulWidget {
  final String? departmentFilter;
  const StaffScreen({super.key, this.departmentFilter});

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  int _selectedMainCategory = 0;
  final List<String> _mainCategories = const ['فەرمانبەران', 'مامۆستایان', 'ئەنجومەن'];

  int _selectedSubCategory = 0;
  final Map<String, List<String>> _subCategories = {
    'فەرمانبەران': [
      'هەموو',
      'تۆمار',
      'دڵنیایی جۆری',
      'ڕاگر',
      'ڕاگەیاندن',
      'ژمێریاری',
      'کارگێڕی',
      'نوسینگەی ڕاگر'
    ],
    'مامۆستایان': [
      'هەموو',
      'مامۆستایانی بەشی پەرستاری',
      'مامۆستایانی بەشی دەرمانسازی',
      'مامۆستایانی بەشی ئینگلیزی پیشەیی'
    ],
    'ئەنجومەن': [
      'هەموو',
      'ڕاگری پەیمانگە',
      'سەرۆک بەشی پەرستاری',
      'سەرۆک بەشی دەرمانسازی',
      'سەرۆک بەشی ئینگلیزی پیشەیی',
      'نوسینگەی ڕاگر'
    ],
  };

  List<Map<String, String>> _staff = [];

  static const _roleColors = {
    'بەڕێوەبەرایەتی': Color(0xFFA55EEA),
    'مامۆستایان': Color(0xFF5B8DEF),
  };

  @override
  void initState() {
    super.initState();
    _loadStaff();
  }

  Future<void> _loadStaff() async {
    final data = await StaffService.getStaff();
    if (!mounted) return;
    setState(() {
      _staff = data.map((s) {
        final imgUrl = (s['image_url'] ?? '').toString().trim();
        final rawName = s['name']?.toString() ?? 'Staff';
        return {
          'name': rawName,
          'role': s['role']?.toString() ?? 'پۆست',
          'department': s['department']?.toString() ?? 'بەش',
          'image': imgUrl,
          'email': s['email']?.toString() ?? '',
          'phone': s['phone']?.toString() ?? '',
          'degree': s['degree']?.toString() ?? '',
          'specialty': s['specialty']?.toString() ?? '',
          'sub_category': s['sub_category']?.toString() ?? '',
          'academic_title': s['academic_title']?.toString() ?? '',
          'job_title_en': s['job_title_en']?.toString() ?? '',
          'bio': s['bio']?.toString() ?? '',
          'id': s['id']?.toString() ?? '',
        };
      }).toList();
    });
  }

  bool _matchesFilter(String role, String dept, String filter) {
    if (filter == 'هەموو') return true;
    
    if (filter.contains('مامۆستایانی بەشی ')) {
      String deptName = filter.split('بەشی ').last.trim();
      return role.contains('مامۆستا') && dept.contains(deptName);
    } else if (filter.contains('سەرۆک بەشی ')) {
      String deptName = filter.split('بەشی ').last.trim();
      return (role.contains('سەرۆک') || role.contains('بەرپرسی')) && dept.contains(deptName);
    } else if (filter == 'ڕاگری پەیمانگە') {
      return role.contains('ڕاگر') && !role.contains('نوسینگەی');
    }
    
    return role.contains(filter) || dept.contains(filter);
  }

  String _getStaffMainCategory(Map<String, String> s) {
    String role = s['role'] ?? '';
    String dept = s['department'] ?? '';
    String subCat = s['sub_category'] ?? '';
    String jobEn = s['job_title_en'] ?? '';
    
    // Priority 1: job_title_en from the admin dashboard (management/teacher/board)
    if (jobEn.isNotEmpty) {
      final lower = jobEn.toLowerCase();
      if (lower == 'board' || lower == 'council' || lower.contains('board')) return 'ئەنجومەن';
      if (lower == 'teacher' || lower.contains('teacher') || lower.contains('lecturer')) return 'مامۆستایان';
      if (lower == 'management' || lower.contains('manage') || lower.contains('employee')) return 'فەرمانبەران';
    }
    
    // Priority 2: sub_category from the dashboard
    if (subCat.isNotEmpty) {
      if (subCat.contains('ئەنجومەن') || subCat == 'council') return 'ئەنجومەن';
      if (subCat.contains('مامۆستا') || subCat == 'teacher') return 'مامۆستایان';
      if (subCat.contains('فەرمانبەر') || subCat == 'employee') return 'فەرمانبەران';
    }
    
    // Priority 3: fallback to Kurdish string matching on role/department
    if (_subCategories['ئەنجومەن']!.any((f) => f != 'هەموو' && _matchesFilter(role, dept, f))) {
      return 'ئەنجومەن';
    }
    if (_subCategories['مامۆستایان']!.any((f) => f != 'هەموو' && _matchesFilter(role, dept, f))) {
      return 'مامۆستایان';
    }
    if (_subCategories['فەرمانبەران']!.any((f) => f != 'هەموو' && _matchesFilter(role, dept, f))) {
      return 'فەرمانبەران';
    }
    return 'فەرمانبەران';
  }

  List<Map<String, String>> get _filteredStaff {
    if (widget.departmentFilter != null) {
      return _staff
          .where((s) => s['department'] == widget.departmentFilter)
          .toList();
    }
    
    String activeMain = _mainCategories[_selectedMainCategory];
    String activeSub = _subCategories[activeMain]![_selectedSubCategory];

    return _staff.where((s) {
      String staffMain = _getStaffMainCategory(s);
      if (staffMain != activeMain) return false;
      
      String role = s['role'] ?? '';
      String dept = s['department'] ?? '';
      return _matchesFilter(role, dept, activeSub);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final canGoBack = Navigator.canPop(context);
    final size = MediaQuery.of(context).size;
    final localizations = AppLocalizations.of(context);
    final localeProvider = LocaleProviderInherited.of(context);

    return Directionality(
      textDirection: localeProvider.textDirection,
      child: Scaffold(
        backgroundColor: isDark
            ? const Color(0xFF040405)
            : const Color(0xFFF9FAFB),
        body: Stack(
          children: [
            // Ambient Aura Meshes
            Positioned(
              top: -100,
              right: -50,
              child: _buildOrb(
                color: AppColors.primary.withValues(
                  alpha: isDark ? 0.25 : 0.08,
                ),
                size: size.width * 0.8,
              ),
            ),
            Positioned(
              bottom: size.height * 0.2,
              left: -100,
              child: _buildOrb(
                color: AppColors.accent.withValues(alpha: isDark ? 0.15 : 0.05),
                size: size.width * 0.9,
              ),
            ),
            // Global Glass Filter
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                child: const SizedBox(),
              ),
            ),
            
            RefreshIndicator(
              onRefresh: () async {
                await _loadStaff();
              },
              color: AppColors.primary,
              backgroundColor: isDark ? const Color(0xFF141822) : Colors.white,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top + 16,
                        left: 20,
                        right: 20,
                        bottom: 12,
                      ),
                      child: Row(
                        children: [
                          if (canGoBack) ...[
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
                                          ? const Color(0xFF141822).withValues(alpha: 0.6)
                                          : Colors.white.withValues(alpha: 0.7),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isDark
                                            ? Colors.white.withValues(alpha: 0.08)
                                            : Colors.black.withValues(alpha: 0.05),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.arrow_back_ios_new,
                                      size: 18,
                                      color: isDark ? Colors.white : AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                          ],
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.departmentFilter != null
                                      ? localizations.get('dept_staff_title')
                                      : localizations.get('staff_title'),
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    color: isDark ? Colors.white : const Color(0xFF111827),
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_filteredStaff.length} ${localizations.get('staff_members')}',
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white60
                                        : const Color(0xFF6B7280),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ).animate().fadeIn(
                                  duration: 400.ms,
                                  curve: Curves.easeOutCirc,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  if (widget.departmentFilter == null)
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _StickyFilterDelegate(
                        isDark: isDark,
                        mainCategories: _mainCategories,
                        subCategories: _subCategories,
                        selectedMainIndex: _selectedMainCategory,
                        selectedSubIndex: _selectedSubCategory,
                        onMainChanged: (index) {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _selectedMainCategory = index;
                            _selectedSubCategory = 0;
                          });
                        },
                        onSubChanged: (index) {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedSubCategory = index);
                        },
                      ),
                    ),
  
                  // Empty State Notice
                  if (_staff.isNotEmpty && _filteredStaff.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 60),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                           children: [
                             Icon(
                               Icons.group_off_rounded,
                               size: 64,
                               color: isDark ? Colors.white24 : Colors.black26,
                             ),
                             const SizedBox(height: 16),
                             Text(
                               localizations.get('no_staff_found'),
                               style: TextStyle(
                                 color: isDark ? Colors.white60 : Colors.black54,
                                 fontSize: 16,
                                 fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.72,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildStaffCard(
                          context,
                          _filteredStaff[index],
                          index,
                          isDark,
                        ),
                        childCount: _filteredStaff.length,
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

  Widget _buildStaffCard(
    BuildContext context,
    Map<String, String> person,
    int index,
    bool isDark,
  ) {
    return _InteractiveStaffCard(
      person: person,
      isDark: isDark,
      roleColors: _roleColors,
    )
    .animate()
    .fadeIn(
      delay: Duration(milliseconds: 100 + (index * 60)),
      duration: 500.ms,
      curve: Curves.easeOutCirc,
    )
    .slideY(
      begin: 0.1,
      delay: Duration(milliseconds: 100 + (index * 60)),
      duration: 500.ms,
      curve: Curves.easeOutCirc,
    );
  }
}

class _InteractiveStaffCard extends StatefulWidget {
  final Map<String, String> person;
  final bool isDark;
  final Map<String, Color> roleColors;

  const _InteractiveStaffCard({
    required this.person,
    required this.isDark,
    required this.roleColors,
  });

  @override
  State<_InteractiveStaffCard> createState() => _InteractiveStaffCardState();
}

class _InteractiveStaffCardState extends State<_InteractiveStaffCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final roleColor = widget.roleColors[widget.person['department']] ?? AppColors.accent;

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
                StaffDetailScreen(staff: widget.person),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              final curved = CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
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
        scale: _isPressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: Container(
          decoration: BoxDecoration(
            color: widget.isDark
                ? const Color(0xFF141416).withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: widget.isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.03),
              width: 1.5,
            ),
            boxShadow: [
              if (!widget.isDark)
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              if (widget.isDark)
                BoxShadow(
                  color: roleColor.withValues(alpha: 0.08),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [roleColor, roleColor.withValues(alpha: 0.3)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: roleColor.withValues(alpha: 0.3),
                            blurRadius: 15,
                            spreadRadius: -5,
                          ),
                        ],
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.isDark ? const Color(0xFF11111E) : Colors.white,
                        ),
                        child: Builder(
                          builder: (context) {
                            final String img = (widget.person['image'] ?? '').trim();
                            // Checking if it's not empty, not 'null', and actually a link
                            final bool isInvalid = img.isEmpty || img == 'null' || !img.startsWith('http');
                            
                            return CircleAvatar(
                              radius: 36,
                              backgroundColor: widget.isDark ? Colors.black : Colors.white,
                              backgroundImage: isInvalid ? null : cachedProvider(img),
                              child: isInvalid
                                  ? Icon(Icons.person_rounded, size: 36, color: widget.isDark ? Colors.white54 : Colors.black26)
                                  : null,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      widget.person['name']!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: widget.isDark ? Colors.white : const Color(0xFF111827),
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.person['role']!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: widget.isDark
                            ? Colors.white.withValues(alpha: 0.6)
                            : const Color(0xFF6B7280),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: roleColor.withValues(
                          alpha: widget.isDark ? 0.15 : 0.1,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        widget.person['department']!,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: widget.isDark
                              ? roleColor
                              : roleColor.withBlue(roleColor.b.toInt() - 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StickyFilterDelegate extends SliverPersistentHeaderDelegate {
  final bool isDark;
  final List<String> mainCategories;
  final Map<String, List<String>> subCategories;
  final int selectedMainIndex;
  final int selectedSubIndex;
  final ValueChanged<int> onMainChanged;
  final ValueChanged<int> onSubChanged;

  _StickyFilterDelegate({
    required this.isDark,
    required this.mainCategories,
    required this.subCategories,
    required this.selectedMainIndex,
    required this.selectedSubIndex,
    required this.onMainChanged,
    required this.onSubChanged,
  });

  @override
  double get minExtent => 134.0;
  @override
  double get maxExtent => 134.0;

  String _getCategoryDisplay(String category, AppLocalizations localizations) {
    if (category == 'فەرمانبەران') return localizations.get('employees');
    if (category == 'مامۆستایان') return localizations.get('teachers');
    if (category == 'ئەنجومەن') return localizations.get('council');
    return category;
  }

  String _getSubCategoryDisplay(String sub, AppLocalizations localizations) {
    switch (sub) {
      case 'هەموو':
        return localizations.get('all');
      case 'تۆمار':
        return localizations.get('registration');
      case 'دڵنیایی جۆری':
        return localizations.get('quality_assurance');
      case 'ڕاگر':
        return localizations.get('dean');
      case 'ڕاگەیاندن':
        return localizations.get('media');
      case 'ژمێریاری':
        return localizations.get('accounting');
      case 'کارگێڕی':
        return localizations.get('administration');
      case 'نوسینگەی ڕاگر':
        return localizations.get('dean_office');
      case 'مامۆستایانی بەشی پەرستاری':
        return localizations.get('nursing_teachers');
      case 'مامۆستایانی بەشی دەرمانسازی':
        return localizations.get('pharmacy_teachers');
      case 'مامۆستایانی بەشی ئینگلیزی پیشەیی':
        return localizations.get('english_teachers');
      case 'ڕاگری پەیمانگە':
        return localizations.get('dean_of_institute');
      case 'سەرۆک بەشی پەرستاری':
        return localizations.get('head_of_nursing');
      case 'سەرۆک بەشی دەرمانسازی':
        return localizations.get('head_of_pharmacy');
      case 'سەرۆک بەشی ئینگلیزی پیشەیی':
        return localizations.get('head_of_english');
      default:
        return sub;
    }
  }

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final localizations = AppLocalizations.of(context);
    final localeProvider = LocaleProviderInherited.of(context);
    final isRtl = localeProvider.textDirection == TextDirection.rtl;

    // Glassmorphic background that intensifies when pinned/scrolling
    final blurAmount = (shrinkOffset > 0) ? 20.0 : 0.0;
    final bgOpacity = (shrinkOffset > 0) ? (isDark ? 0.8 : 0.9) : 0.0;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
        child: Container(
          color: isDark
              ? const Color(0xFF040405).withValues(alpha: bgOpacity)
              : const Color(0xFFF9FAFB).withValues(alpha: bgOpacity),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Main Categories Segmented Control
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      height: 56,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.black.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.black.withValues(alpha: 0.02),
                        ),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final itemWidth = constraints.maxWidth / mainCategories.length;
                          double leftPosition = isRtl
                              ? constraints.maxWidth - (itemWidth * (selectedMainIndex + 1))
                              : itemWidth * selectedMainIndex;

                          return Stack(
                            children: [
                              AnimatedPositioned(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.fastEaseInToSlowEaseOut,
                                left: leftPosition,
                                top: 0,
                                bottom: 0,
                                width: itemWidth,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.15)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.08),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Row(
                                children: List.generate(
                                  mainCategories.length,
                                  (index) {
                                    final isSelected = selectedMainIndex == index;
                                    return Expanded(
                                      child: GestureDetector(
                                        onTap: () => onMainChanged(index),
                                        behavior: HitTestBehavior.opaque,
                                        child: Center(
                                          child: AnimatedDefaultTextStyle(
                                            duration: const Duration(milliseconds: 200),
                                            style: TextStyle(
                                              color: isDark
                                                  ? Colors.white.withValues(alpha: isSelected ? 1.0 : 0.5)
                                                  : (isSelected ? Colors.black : Colors.black54),
                                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                              fontSize: 14,
                                              fontFamily: 'Rabar',
                                            ),
                                            child: Text(_getCategoryDisplay(mainCategories[index], localizations)),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),

              // Sub Categories Chips
              SizedBox(
                height: 42,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: subCategories[mainCategories[selectedMainIndex]]!.length,
                  itemBuilder: (context, index) {
                    final subCat = subCategories[mainCategories[selectedMainIndex]]![index];
                    final isSelected = selectedSubIndex == index;
                    
                    return GestureDetector(
                      onTap: () => onSubChanged(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? AppColors.primary 
                              : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03)),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected 
                              ? AppColors.primary.withValues(alpha: 0.5)
                              : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
                            width: isSelected ? 1.5 : 1.0,
                          ),
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _getSubCategoryDisplay(subCat, localizations),
                            style: TextStyle(
                              color: isSelected 
                                  ? Colors.white 
                                  : (isDark ? Colors.white70 : Colors.black87),
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_StickyFilterDelegate oldDelegate) {
    return isDark != oldDelegate.isDark ||
        selectedMainIndex != oldDelegate.selectedMainIndex ||
        selectedSubIndex != oldDelegate.selectedSubIndex ||
        mainCategories != oldDelegate.mainCategories ||
        subCategories != oldDelegate.subCategories;
  }
}