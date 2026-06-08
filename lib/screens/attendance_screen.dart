import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:sd_institute/services/auth_service.dart';
import 'package:sd_institute/theme/app_colors.dart';
import 'package:sd_institute/utils/app_localizations.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic> _attendanceData = {};
  List<Map<String, dynamic>> _records = [];
  String? _selectedMonth; // null = all months

  @override
  void initState() {
    super.initState();
    _loadAttendance();
  }

  Future<void> _loadAttendance() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final profile = await AuthService.getStudentProfile();
      if (!mounted) return;
      setState(() {
        _attendanceData = Map<String, dynamic>.from(profile['attendance'] ?? {});
        _records = List<Map<String, dynamic>>.from(
          (_attendanceData['records'] ?? []).map((r) => Map<String, dynamic>.from(r)),
        );
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredRecords {
    if (_selectedMonth == null) return _records;
    return _records.where((r) {
      final date = r['date']?.toString() ?? '';
      return date.startsWith(_selectedMonth!);
    }).toList();
  }

  List<String> get _availableMonths {
    final months = <String>{};
    for (final r in _records) {
      final date = r['date']?.toString() ?? '';
      if (date.length >= 7) {
        months.add(date.substring(0, 7));
      }
    }
    final sorted = months.toList()..sort((a, b) => b.compareTo(a));
    return sorted;
  }

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return 'â€”';
    try {
      final d = DateTime.parse(date);
      return DateFormat('yyyy/MM/dd').format(d);
    } catch (_) {
      return date;
    }
  }

  String _formatMonth(String month) {
    try {
      final d = DateTime.parse('$month-01');
      return DateFormat('MMMM yyyy').format(d);
    } catch (_) {
      return month;
    }
  }

  String _dayName(String? date) {
    if (date == null) return '';
    try {
      final d = DateTime.parse(date);
      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[d.weekday - 1];
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7),
      body: Stack(
        children: [
          // Ambient Orbs
          Positioned(
            top: -100,
            left: -80,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF5B8DEF).withValues(alpha: isDark ? 0.25 : 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -60,
            child: Container(
              width: 300,
              height: 300,
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
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: const SizedBox(),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(isDark, loc),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _error != null
                          ? _buildErrorState(isDark, loc)
                          : RefreshIndicator(
                              onRefresh: _loadAttendance,
                              child: SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(
                                  parent: BouncingScrollPhysics(),
                                ),
                                padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildSummaryCard(isDark, loc),
                                    const SizedBox(height: 20),
                                    _buildStatsRow(isDark, loc),
                                    const SizedBox(height: 24),
                                    _buildMonthFilter(isDark, loc),
                                    const SizedBox(height: 16),
                                    _buildRecordsList(isDark, loc),
                                  ],
                                ),
                              ),
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(bool isDark, AppLocalizations loc) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
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
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              loc.get('my_attendance'),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : const Color(0xFF111827),
                letterSpacing: -0.5,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF5B8DEF).withValues(alpha: 0.15),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: Color(0xFF5B8DEF),
              size: 22,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, duration: 400.ms);
  }

  Widget _buildErrorState(bool isDark, AppLocalizations loc) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: isDark ? Colors.white38 : Colors.black38,
            size: 56,
          ),
          const SizedBox(height: 16),
          Text(
            loc.get('error'),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _loadAttendance,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: AppColors.primaryGradient,
              ),
              child: Text(
                loc.get('retry'),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(bool isDark, AppLocalizations loc) {
    final summary = Map<String, dynamic>.from(_attendanceData['summary'] ?? {});
    final percentage = (summary['percentage'] ?? 0).toDouble();
    final total = (summary['total'] ?? 0).toInt();

    Color rateColor;
    if (percentage >= 75) {
      rateColor = const Color(0xFF34C759);
    } else if (percentage >= 50) {
      rateColor = const Color(0xFFF59E0B);
    } else {
      rateColor = const Color(0xFFFF3B30);
    }

    return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [const Color(0xFF1E1B4B), const Color(0xFF0F172A)]
                  : [const Color(0xFF5B8DEF), const Color(0xFF6366F1)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF5B8DEF).withValues(alpha: isDark ? 0.2 : 0.3),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
            border: Border.all(
              color: Colors.white.withValues(alpha: isDark ? 0.1 : 0.25),
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                // Circular Progress
                SizedBox(
                  width: 90,
                  height: 90,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 90,
                        height: 90,
                        child: CircularProgressIndicator(
                          value: (percentage / 100).clamp(0.0, 1.0),
                          strokeWidth: 8,
                          backgroundColor: Colors.white.withValues(alpha: 0.15),
                          valueColor: AlwaysStoppedAnimation(rateColor),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${percentage.toInt()}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.get('attendance_rate'),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${loc.get('total_days')}: $total',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        loc.get('attendance_summary'),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12,
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
        .fadeIn(delay: 100.ms, duration: 500.ms)
        .slideY(begin: 0.05, delay: 100.ms, duration: 500.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildStatsRow(bool isDark, AppLocalizations loc) {
    final summary = Map<String, dynamic>.from(_attendanceData['summary'] ?? {});
    final present = (summary['present'] ?? 0).toInt();
    final absent = (summary['absent'] ?? 0).toInt();
    final late_ = (summary['late'] ?? 0).toInt();

    return Row(
      children: [
        _buildStatChip(loc.get('present'), present, const Color(0xFF34C759), isDark),
        const SizedBox(width: 10),
        _buildStatChip(loc.get('absent'), absent, const Color(0xFFFF3B30), isDark),
        const SizedBox(width: 10),
        _buildStatChip(loc.get('late'), late_, const Color(0xFFF59E0B), isDark),
      ],
    ).animate().fadeIn(delay: 200.ms, duration: 500.ms).slideY(begin: 0.04, delay: 200.ms, duration: 500.ms);
  }

  Widget _buildStatChip(String label, int count, Color color, bool isDark) {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.white.withValues(alpha: 0.7),
              border: Border.all(
                color: color.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.15),
                  ),
                  child: Center(
                    child: Text(
                      '$count',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white70 : const Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMonthFilter(bool isDark, AppLocalizations loc) {
    final months = _availableMonths;
    if (months.isEmpty) return const SizedBox();

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          _buildFilterChip(loc.get('all_months'), _selectedMonth == null, isDark, () {
            setState(() => _selectedMonth = null);
          }),
          ...months.map((m) => _buildFilterChip(
                _formatMonth(m),
                _selectedMonth == m,
                isDark,
                () {
                  setState(() => _selectedMonth = m);
                },
              )),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 400.ms);
  }

  Widget _buildFilterChip(String label, bool selected, bool isDark, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: selected
                ? AppColors.primary
                : isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.white.withValues(alpha: 0.7),
            border: Border.all(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.6)
                  : isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.06),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected
                  ? Colors.white
                  : isDark
                      ? Colors.white70
                      : const Color(0xFF111827),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecordsList(bool isDark, AppLocalizations loc) {
    final filtered = _filteredRecords;
    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(
                Icons.event_busy_rounded,
                size: 56,
                color: isDark ? Colors.white24 : Colors.black26,
              ),
              const SizedBox(height: 14),
              Text(
                loc.get('no_attendance'),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: List.generate(filtered.length, (index) {
        return _buildRecordCard(filtered[index], index, isDark, loc);
      }),
    ).animate().fadeIn(delay: 350.ms, duration: 500.ms);
  }

  Widget _buildRecordCard(Map<String, dynamic> record, int index, bool isDark, AppLocalizations loc) {
    final status = record['status']?.toString() ?? 'present';
    Color statusColor;
    IconData statusIcon;
    String statusLabel;

    switch (status) {
      case 'present':
        statusColor = const Color(0xFF34C759);
        statusIcon = Icons.check_circle_rounded;
        statusLabel = loc.get('present');
        break;
      case 'absent':
        statusColor = const Color(0xFFFF3B30);
        statusIcon = Icons.cancel_rounded;
        statusLabel = loc.get('absent');
        break;
      case 'late':
        statusColor = const Color(0xFFF59E0B);
        statusIcon = Icons.watch_later_rounded;
        statusLabel = loc.get('late');
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_rounded;
        statusLabel = status;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : Colors.white.withValues(alpha: 0.65),
              border: Border.all(
                color: statusColor.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: statusColor.withValues(alpha: 0.12),
                  ),
                  child: Icon(statusIcon, color: statusColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDate(record['date']?.toString()),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: isDark ? Colors.white : const Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _dayName(record['date']?.toString()),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white38 : Colors.black38,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: statusColor.withValues(alpha: 0.12),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
