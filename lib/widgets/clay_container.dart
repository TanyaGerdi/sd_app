import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sd_institute/theme/app_colors.dart';

/// Claymorphism container with convex dual-shadow effect.
///
/// Light mode: dark shadow bottom-right, bright highlight top-left.
/// Dark mode: deeper dark shadow, subtle bright edge.
class ClayContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double depth;
  final double spread;
  final Color? color;
  final Color? parentColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final bool emboss; // true = concave (pressed in), false = convex (raised)
  final BoxShape shape;

  const ClayContainer({
    super.key,
    required this.child,
    this.borderRadius = 28,
    this.depth = 12,
    this.spread = 2,
    this.color,
    this.parentColor,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.emboss = false,
    this.shape = BoxShape.rectangle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    final surfaceColor = color ??
        (isDark ? const Color(0xFF1E1E24) : const Color(0xFFE8EAF0));

    // Shadow colors
    final darkShadow = isDark
        ? Colors.black.withValues(alpha: 0.6)
        : const Color(0xFFBCC3CE).withValues(alpha: 0.65);
    final lightShadow = isDark
        ? Colors.white.withValues(alpha: 0.04)
        : Colors.white.withValues(alpha: 0.85);

    // Inner highlight for the clay "lip"
    final innerHighlight = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.white.withValues(alpha: 0.7);
    final innerShadow = isDark
        ? Colors.black.withValues(alpha: 0.3)
        : const Color(0xFFBCC3CE).withValues(alpha: 0.35);

    final isCircle = shape == BoxShape.circle;

    final outerShadows = emboss
        ? <BoxShadow>[
            // Embossed = pressed in: inner shadows simulated with outer
            BoxShadow(
              color: darkShadow,
              blurRadius: depth * 0.6,
              offset: Offset(-depth * 0.15, -depth * 0.15),
              spreadRadius: -spread * 0.5,
            ),
            BoxShadow(
              color: lightShadow,
              blurRadius: depth * 0.6,
              offset: Offset(depth * 0.15, depth * 0.15),
              spreadRadius: -spread * 0.5,
            ),
          ]
        : <BoxShadow>[
            // Convex = raised up
            BoxShadow(
              color: darkShadow,
              blurRadius: depth,
              offset: Offset(depth * 0.3, depth * 0.35),
              spreadRadius: spread * 0.3,
            ),
            BoxShadow(
              color: lightShadow,
              blurRadius: depth,
              offset: Offset(-depth * 0.25, -depth * 0.25),
              spreadRadius: spread * 0.2,
            ),
          ];

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: surfaceColor,
        shape: shape,
        borderRadius: isCircle ? null : BorderRadius.circular(borderRadius),
        boxShadow: outerShadows,
        border: Border.all(
          color: emboss ? innerShadow : innerHighlight,
          width: emboss ? 0.8 : 1.2,
        ),
      ),
      child: ClipRRect(
        borderRadius: isCircle
            ? BorderRadius.circular(999)
            : BorderRadius.circular(borderRadius),
        child: Container(
          padding: padding,
          // Inner gradient for clay lip effect
          decoration: BoxDecoration(
            shape: shape,
            borderRadius:
                isCircle ? null : BorderRadius.circular(borderRadius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: emboss
                  ? [
                      surfaceColor
                          .withValues(alpha: isDark ? 0.8 : 0.95),
                      surfaceColor,
                      surfaceColor,
                    ]
                  : [
                      Color.lerp(surfaceColor, Colors.white,
                              isDark ? 0.05 : 0.12) ??
                          surfaceColor,
                      surfaceColor,
                      Color.lerp(surfaceColor, Colors.black,
                              isDark ? 0.08 : 0.04) ??
                          surfaceColor,
                    ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Interactive clay button with press-to-emboss animation.
class ClayButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double borderRadius;
  final double depth;
  final Color? color;
  final Color? parentColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final BoxShape shape;

  const ClayButton({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius = 28,
    this.depth = 12,
    this.color,
    this.parentColor,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.shape = BoxShape.rectangle,
  });

  @override
  State<ClayButton> createState() => _ClayButtonState();
}

class _ClayButtonState extends State<ClayButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (widget.onTap != null) {
          HapticFeedback.lightImpact();
          setState(() => _isPressed = true);
        }
      },
      onTapUp: (_) {
        if (widget.onTap != null) {
          setState(() => _isPressed = false);
          widget.onTap!();
        }
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: ClayContainer(
            borderRadius: widget.borderRadius,
            depth: _isPressed ? widget.depth * 0.4 : widget.depth,
            spread: _isPressed ? 0 : 2,
            color: widget.color,
            parentColor: widget.parentColor,
            padding: widget.padding,
            margin: widget.margin,
            width: widget.width,
            height: widget.height,
            emboss: _isPressed,
            shape: widget.shape,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// Circular clay icon button â€” for back buttons, action buttons, etc.
class ClayIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final double iconSize;
  final Color? iconColor;
  final Color? color;
  final double depth;
  final Widget? badge;

  const ClayIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.size = 48,
    this.iconSize = 22,
    this.iconColor,
    this.color,
    this.depth = 10,
    this.badge,
  });

  @override
  State<ClayIconButton> createState() => _ClayIconButtonState();
}

class _ClayIconButtonState extends State<ClayIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final defaultIconColor =
        isDark ? Colors.white : AppColors.primary;

    return GestureDetector(
      onTapDown: (_) {
        if (widget.onTap != null) {
          HapticFeedback.lightImpact();
          setState(() => _isPressed = true);
        }
      },
      onTapUp: (_) {
        if (widget.onTap != null) {
          setState(() => _isPressed = false);
          widget.onTap!();
        }
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.90 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutBack,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ClayContainer(
              width: widget.size,
              height: widget.size,
              shape: BoxShape.circle,
              depth: _isPressed ? widget.depth * 0.3 : widget.depth,
              emboss: _isPressed,
              color: widget.color,
              child: Center(
                child: Icon(
                  widget.icon,
                  size: widget.iconSize,
                  color: widget.iconColor ?? defaultIconColor,
                ),
              ),
            ),
            if (widget.badge != null) widget.badge!,
          ],
        ),
      ),
    );
  }
}
