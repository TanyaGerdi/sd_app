import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sd_institute/services/api_service.dart';
import 'package:sd_institute/services/auth_service.dart';
import 'package:sd_institute/utils/app_localizations.dart';
import 'package:sd_institute/theme/app_colors.dart';
import 'package:intl/intl.dart' as intl;

class TeacherAttendanceScreen extends StatefulWidget {
  const TeacherAttendanceScreen({super.key});

  @override
  State<TeacherAttendanceScreen> createState() => _TeacherAttendanceScreenState();
}

class _TeacherAttendanceScreenState extends State<TeacherAttendanceScreen> {
  DateTime _selectedDate = DateTime.now();
  List<dynamic> _students = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Map of studentId -> status ('present', 'absent', 'late')
  final Map<int, String> _attendanceMap = {};

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final teacher = AuthService.currentStudent;
      if (teacher == null) {
        throw Exception('Teacher profile not found.');
      }
      final deptId = teacher['department_id'];
      if (deptId == null) {
        throw Exception('No department assigned to this teacher.');
      }

      final response = await ApiService.get(
        '/students',
        queryParams: {'department_id': deptId},
      );

      final list = List<dynamic>.from(response);
      setState(() {
        _students = list;
        for (var student in list) {
          final id = student['id'] as int;
          // Default to present
          _attendanceMap[id] = 'present';
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = ApiService.getErrorMessage(e);
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2025),
      lastDate: DateTime.now(),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: isDark ? const Color(0xFF1F2937) : Colors.white,
              onSurface: isDark ? Colors.white : Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitAttendance() async {
    setState(() => _isLoading = true);
    try {
      final records = _attendanceMap.entries.map((entry) {
        return {
          'student_id': entry.key,
          'status': entry.value,
        };
      }).toList();

      final dateStr = intl.DateFormat('yyyy-MM-dd').format(_selectedDate);

      await ApiService.post(
        '/attendance/bulk',
        data: {
          'date': dateStr,
          'records': records,
        },
      );

      // Create student notification
      try {
        final teacher = AuthService.currentStudent;
        final deptId = teacher?['department_id'];
        if (deptId != null) {
          await ApiService.post(
            '/notifications',
            data: {
              'title_ku': 'تۆمارکردنی ئامادەبوون',
              'title_en': 'Attendance Recorded',
              'description_ku': 'ئامادەبوونی ڕێکەوتی $dateStr تۆمارکرا بۆ بەشەکەت.',
              'description_en': 'Attendance for $dateStr has been recorded for your department.',
              'target_audience': 'dept_$deptId',
            },
          );
        }
      } catch (e) {
        debugPrint('Failed to send notification: $e');
      }

      if (!mounted) return;
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).get('success'),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF34C759),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ApiService.getErrorMessage(e)),
          backgroundColor: const Color(0xFFFF3B30),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Calculate real-time stats
    int total = _students.length;
    int present = _attendanceMap.values.where((v) => v == 'present').length;
    int absent = _attendanceMap.values.where((v) => v == 'absent').length;
    int late = _attendanceMap.values.where((v) => v == 'late').length;
    double rate = total > 0 ? (present + late * 0.5) / total : 0.0;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          loc.get('take_attendance'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                  : [Colors.white, const Color(0xFFF8FAFC)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: _isLoading && _students.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 64),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 15),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loadStudents,
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    // Header Stats & Date selector
                    _buildHeaderWidget(isDark, loc, total, present, absent, late, rate),
                    
                    // List of Students
                    Expanded(
                      child: _students.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.group_off_rounded, size: 64, color: isDark ? Colors.white30 : Colors.black38),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No students found in your department.',
                                    style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 14),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              itemCount: _students.length,
                              itemBuilder: (context, index) {
                                final student = _students[index];
                                return _buildStudentCard(student, isDark, loc);
                              },
                            ),
                    ),
                    
                    // Submit bar
                    if (_students.isNotEmpty) _buildSubmitBar(isDark, loc),
                  ],
                ),
    );
  }

  Widget _buildHeaderWidget(
    bool isDark,
    AppLocalizations loc,
    int total,
    int present,
    int absent,
    int late,
    double rate,
  ) {
    final ratePercent = (rate * 100).toStringAsFixed(0);
    final dateFormatted = intl.DateFormat('yyyy MMM dd').format(_selectedDate);
    final themeColor = rate > 0.8 ? const Color(0xFF34C759) : rate > 0.5 ? Colors.orange : Colors.red;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: themeColor.withValues(alpha: 0.08),
            blurRadius: 25,
            spreadRadius: 5,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Date & Change picker
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_month_rounded, size: 20, color: isDark ? Colors.white70 : Colors.black87),
                  const SizedBox(width: 8),
                  Text(
                    dateFormatted,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _selectDate(context),
                icon: const Icon(Icons.edit_calendar_rounded, size: 16, color: Colors.white),
                label: const Text(
                  'Change Date',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 1,
            color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
          ),
          const SizedBox(height: 20),
          
          // Stats Row with beautiful radial circular indicator
          Row(
            children: [
              // Large Circular Progress
              SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer glow container
                    Container(
                      width: 104,
                      height: 104,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? const Color(0xFF0F172A) : Colors.grey.shade50,
                        boxShadow: [
                          BoxShadow(
                            color: themeColor.withValues(alpha: 0.15),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 110,
                      height: 110,
                      child: CircularProgressIndicator(
                        value: rate,
                        strokeWidth: 12,
                        backgroundColor: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                        valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$ratePercent%',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w900,
                            fontSize: 24,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'Rate',
                          style: TextStyle(
                            color: isDark ? Colors.white54 : Colors.black54,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 28),
              // Stats Labels
              Expanded(
                child: Column(
                  children: [
                    _buildStatLine('Total Students', total.toString(), isDark, const Color(0xFF5B8DEF)),
                    const SizedBox(height: 8),
                    _buildStatLine('Present', present.toString(), isDark, const Color(0xFF34C759)),
                    const SizedBox(height: 8),
                    _buildStatLine('Late', late.toString(), isDark, Colors.orange),
                    const SizedBox(height: 8),
                    _buildStatLine('Absent', absent.toString(), isDark, Colors.redAccent),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatLine(String label, String value, bool isDark, Color dotColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.white60 : Colors.black54,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildStudentCard(dynamic student, bool isDark, AppLocalizations loc) {
    final id = student['id'] as int;
    final currentStatus = _attendanceMap[id] ?? 'present';
    final name = student['full_name_ku'] ?? student['full_name_en'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
        ),
      ),
      child: Row(
        children: [
          // Student details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: #${student['student_number'] ?? student['id']}',
                  style: TextStyle(
                    color: isDark ? Colors.white38 : Colors.black38,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          
          // Present/Absent/Late selector segments
          Row(
            children: [
              _buildSegmentBtn('present', 'P', currentStatus == 'present', const Color(0xFF34C759), isDark, id),
              const SizedBox(width: 4),
              _buildSegmentBtn('late', 'L', currentStatus == 'late', Colors.orange, isDark, id),
              const SizedBox(width: 4),
              _buildSegmentBtn('absent', 'A', currentStatus == 'absent', Colors.red, isDark, id),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentBtn(
    String statusValue,
    String label,
    bool isActive,
    Color activeColor,
    bool isDark,
    int studentId,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _attendanceMap[studentId] = statusValue;
        });
        HapticFeedback.lightImpact();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: isActive
              ? activeColor
              : (isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.02)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? activeColor
                : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : (isDark ? Colors.white54 : Colors.black54),
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitBar(bool isDark, AppLocalizations loc) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).padding.bottom + 12,
        top: 12,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white10 : Colors.black12,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitAttendance,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text(
                      'Submit Attendance Log',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
