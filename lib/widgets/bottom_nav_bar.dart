import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sd_institute/theme/app_colors.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    _NavItemData(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'سەرەکی',
    ),
    _NavItemData(
      icon: Icons.school_outlined,
      activeIcon: Icons.school_rounded,
      label: 'بەشەکان',
    ),
    _NavItemData(
      icon: Icons.people_outline_rounded,
      activeIcon: Icons.people_alt_rounded,
      label: 'مامۆستا',
    ),
    _NavItemData(
      icon: Icons.info_outline_rounded,
      activeIcon: Icons.info_rounded,
      label: 'دەربارە',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    // Clay surface colors
    final surfaceColor = isDark
        ? const Color(0xFF1A1A22)
        : const Color(0xFFE4E7ED);
    // Shadow colors for the outer bar
    final darkShadow = isDark
        ? Colors.black.withValues(alpha: 0.7)
        : const Color(0xFFB8BEC9).withValues(alpha: 0.6);
    final lightShadow = isDark
        ? Colors.white.withValues(alpha: 0.04)
        : Colors.white.withValues(alpha: 0.9);

    return Container(
      padding: const EdgeInsets.all(3),
      height: 82,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(34),
        // Outer double border for clay lip
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.white.withValues(alpha: 0.7),
          width: 1.5,
        ),
        boxShadow: [
          // Dark shadow (bottom-right)
          BoxShadow(
            color: darkShadow,
            blurRadius: 18,
            offset: const Offset(4, 5),
            spreadRadius: 1,
          ),
          // Light highlight (top-left)
          BoxShadow(
            color: lightShadow,
            blurRadius: 16,
            offset: const Offset(-3, -3),
            spreadRadius: 0,
          ),
          // Subtle inner glow
          if (!isDark)
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.03),
              blurRadius: 30,
              spreadRadius: -5,
            ),
        ],
      ),
      child: Container(
        // Inner container with subtle gradient for clay depth
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(31),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.lerp(surfaceColor, Colors.white, isDark ? 0.03 : 0.08)!,
              surfaceColor,
              Color.lerp(surfaceColor, Colors.black, isDark ? 0.05 : 0.03)!,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(_items.length, (index) {
            final item = _items[index];
            final isSelected = currentIndex == index;

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onTap(index);
                },
                behavior: HitTestBehavior.opaque,
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutBack,
                    child: isSelected
                        ? _buildSelectedItem(item, isDark)
                        : _buildUnselectedItem(item, isDark),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  /// Selected item: raised clay circle with primary color
  Widget _buildSelectedItem(_NavItemData item, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      AppColors.primary.withValues(alpha: 0.9),
                      AppColors.primary.withValues(alpha: 0.7),
                    ]
                  : [
                      AppColors.primary.withValues(alpha: 0.85),
                      AppColors.primary.withValues(alpha: 0.95),
                    ],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: isDark ? 0.15 : 0.3),
              width: 2,
            ),
            boxShadow: [
              // Colored glow shadow
              BoxShadow(
                color: AppColors.primary.withValues(alpha: isDark ? 0.4 : 0.35),
                blurRadius: 14,
                offset: const Offset(0, 4),
                spreadRadius: 1,
              ),
              // Dark bottom shadow
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.5)
                    : const Color(0xFFBCC3CE).withValues(alpha: 0.5),
                blurRadius: 10,
                offset: const Offset(2, 4),
                spreadRadius: 0,
              ),
              // Light top highlight
              BoxShadow(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.white.withValues(alpha: 0.8),
                blurRadius: 8,
                offset: const Offset(-2, -2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.6, end: 1.0),
              duration: const Duration(milliseconds: 400),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(scale: value, child: child);
              },
              child: Icon(item.activeIcon, color: Colors.white, size: 28),
            ),
          ),
        ),
      ],
    );
  }

  /// Unselected item: flat icon on clay surface
  Widget _buildUnselectedItem(_NavItemData item, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 54,
          height: 54,
          child: Center(
            child: Icon(
              item.icon,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.4)
                  : const Color(0xFF8B92A0),
              size: 28,
            ),
          ),
        ),
      ],
    );
  }
}

class _NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
