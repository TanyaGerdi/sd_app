import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:sd_institute/theme/app_colors.dart';
import 'package:sd_institute/utils/app_localizations.dart';

class FeesChart extends StatefulWidget {
  final double totalAmount;
  final double totalPaid;
  final double remaining;
  final double discount;

  const FeesChart({
    super.key,
    required this.totalAmount,
    required this.totalPaid,
    required this.remaining,
    this.discount = 0.0,
  });

  @override
  State<FeesChart> createState() => _FeesChartState();
}

class _FeesChartState extends State<FeesChart> {
  int _hoveredIndex = -1; // -1: none, 0: paid, 1: remaining

  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,###', 'en_US');
    return '${formatter.format(amount)} IQD';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final loc = AppLocalizations.of(context);
    final netAmount = widget.totalAmount - widget.discount;
    final progress = netAmount > 0
        ? (widget.totalPaid / netAmount).clamp(0.0, 1.0)
        : 0.0;
    final paidPercent = (progress * 100).toInt();

    final paidColor = const Color(0xFF10B981); // Emerald
    final remainingColor = const Color(0xFFEF4444); // Rose Red

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.white.withValues(alpha: 0.75),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05),
              width: 1.5,
            ),
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.04),
                      blurRadius: 30,
                      offset: const Offset(0, 12),
                    ),
                  ],
          ),
          child: Column(
            children: [
              // Title / Header
              Row(
                children: [
                  Icon(
                    Icons.analytics_rounded,
                    color: AppColors.primaryAdaptive(context),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    loc.get('fee_status'),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  // Emoji status badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: (widget.remaining <= 0)
                          ? const Color(0xFF10B981).withValues(alpha: 0.15)
                          : const Color(0xFFF59E0B).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.remaining <= 0 ? '👍 Paid' : '⏳ Pending',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: widget.remaining <= 0
                            ? const Color(0xFF10B981)
                            : const Color(0xFFF59E0B),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Chart Core
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Animated Doughnut
                  Expanded(
                    flex: 11,
                    child: Center(
                      child: SizedBox(
                        width: 140,
                        height: 140,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0.0, end: progress),
                          duration: const Duration(milliseconds: 1200),
                          curve: Curves.easeOutBack,
                          builder: (context, animValue, child) {
                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                CustomPaint(
                                  size: const Size(140, 140),
                                  painter: DonutChartPainter(
                                    progress: animValue,
                                    isDark: isDark,
                                    paidColor: paidColor,
                                    remainingColor: remainingColor,
                                    hoveredIndex: _hoveredIndex,
                                  ),
                                ),
                                // Inner text
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${(animValue * 100).toInt()}%',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w900,
                                        color: isDark ? Colors.white : const Color(0xFF111827),
                                        letterSpacing: -1,
                                      ),
                                    ),
                                    Text(
                                      loc.get('paid_percentage').toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: isDark ? Colors.white38 : Colors.black38,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Side Interactive Legend & Value display
                  Expanded(
                    flex: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Total
                        _buildLegendRow(
                          title: loc.get('total_fees'),
                          amount: widget.totalAmount,
                          color: isDark ? Colors.white60 : Colors.black54,
                          isBold: true,
                          index: -1,
                        ),
                        if (widget.discount > 0) ...[
                          const SizedBox(height: 4),
                          _buildLegendRow(
                            title: loc.get('discount'),
                            amount: widget.discount,
                            color: const Color(0xFFF59E0B), // Amber for discount
                            index: -1,
                          ),
                        ],
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 6.0),
                          child: Divider(height: 1, thickness: 0.5),
                        ),
                        // Paid
                        GestureDetector(
                          onTapDown: (_) => setState(() => _hoveredIndex = 0),
                          onTapUp: (_) => setState(() => _hoveredIndex = -1),
                          onTapCancel: () => setState(() => _hoveredIndex = -1),
                          child: MouseRegion(
                            onEnter: (_) => setState(() => _hoveredIndex = 0),
                            onExit: (_) => setState(() => _hoveredIndex = -1),
                            child: _buildLegendRow(
                              title: loc.get('total_paid'),
                              amount: widget.totalPaid,
                              color: paidColor,
                              isActive: _hoveredIndex == 0,
                              index: 0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Remaining
                        GestureDetector(
                          onTapDown: (_) => setState(() => _hoveredIndex = 1),
                          onTapUp: (_) => setState(() => _hoveredIndex = -1),
                          onTapCancel: () => setState(() => _hoveredIndex = -1),
                          child: MouseRegion(
                            onEnter: (_) => setState(() => _hoveredIndex = 1),
                            onExit: (_) => setState(() => _hoveredIndex = -1),
                            child: _buildLegendRow(
                              title: loc.get('remaining'),
                              amount: widget.remaining,
                              color: remainingColor,
                              isActive: _hoveredIndex == 1,
                              index: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Interactive Tip
              const SizedBox(height: 16),
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                child: _hoveredIndex != -1
                    ? Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(
                          color: (_hoveredIndex == 0 ? paidColor : remainingColor)
                              .withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: (_hoveredIndex == 0 ? paidColor : remainingColor)
                                .withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _hoveredIndex == 0 ? Icons.check_circle_rounded : Icons.info_outline,
                              size: 14,
                              color: _hoveredIndex == 0 ? paidColor : remainingColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _hoveredIndex == 0
                                  ? 'Showing details of paid balance.'
                                  : 'Showing remaining fees to clear.',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: _hoveredIndex == 0 ? paidColor : remainingColor,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Text(
                        'Tap sections for breakdown',
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? Colors.white24 : Colors.black26,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendRow({
    required String title,
    required double amount,
    required Color color,
    bool isBold = false,
    bool isActive = false,
    required int index,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? color.withValues(alpha: 0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (index != -1) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isActive ? color : (AppColors.isDark(context) ? Colors.white54 : Colors.black45),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _formatCurrency(amount),
              style: TextStyle(
                fontSize: 15,
                fontWeight: isBold || isActive ? FontWeight.w900 : FontWeight.w700,
                color: isActive ? color : (AppColors.isDark(context) ? Colors.white : const Color(0xFF111827)),
                letterSpacing: -0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DonutChartPainter extends CustomPainter {
  final double progress;
  final bool isDark;
  final Color paidColor;
  final Color remainingColor;
  final int hoveredIndex;

  DonutChartPainter({
    required this.progress,
    required this.isDark,
    required this.paidColor,
    required this.remainingColor,
    required this.hoveredIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    final strokeWidth = 14.0;

    // Draw background track
    final trackPaint = Paint()
      ..color = isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    final double paidAngle = progress * 2 * math.pi;
    final double remainingAngle = (1 - progress) * 2 * math.pi;

    // 1. Paid Arc Paint
    if (progress > 0) {
      final isHovered = hoveredIndex == 0;
      final paidPaint = Paint()
        ..shader = SweepGradient(
          colors: [paidColor, paidColor.withValues(alpha: 0.8)],
          stops: [0.0, progress],
          transform: const GradientRotation(-math.pi / 2),
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = isHovered ? strokeWidth + 3 : strokeWidth
        ..strokeCap = StrokeCap.round;

      // Glow behind paid arc if hovered
      if (isHovered) {
        final glowPaint = Paint()
          ..color = paidColor.withValues(alpha: 0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth + 8
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          -math.pi / 2,
          paidAngle,
          false,
          glowPaint,
        );
      }

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        paidAngle,
        false,
        paidPaint,
      );
    }

    // 2. Remaining Arc Paint
    if (progress < 1.0) {
      final isHovered = hoveredIndex == 1;
      final remainingPaint = Paint()
        ..shader = SweepGradient(
          colors: [remainingColor, remainingColor.withValues(alpha: 0.8)],
          stops: [0.0, 1 - progress],
          transform: GradientRotation(-math.pi / 2 + paidAngle),
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = isHovered ? strokeWidth + 3 : strokeWidth
        ..strokeCap = StrokeCap.round;

      // Glow behind remaining arc if hovered
      if (isHovered) {
        final glowPaint = Paint()
          ..color = remainingColor.withValues(alpha: 0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth + 8
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          -math.pi / 2 + paidAngle,
          remainingAngle,
          false,
          glowPaint,
        );
      }

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2 + paidAngle,
        remainingAngle,
        false,
        remainingPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant DonutChartPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isDark != isDark ||
        oldDelegate.hoveredIndex != hoveredIndex;
  }
}
