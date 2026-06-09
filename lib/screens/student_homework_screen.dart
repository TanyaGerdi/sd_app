import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sd_institute/services/api_service.dart';
import 'package:sd_institute/services/auth_service.dart';
import 'package:sd_institute/utils/app_localizations.dart';
import 'package:sd_institute/theme/app_colors.dart';
import 'package:intl/intl.dart' as intl;
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentHomeworkScreen extends StatefulWidget {
  const StudentHomeworkScreen({super.key});

  @override
  State<StudentHomeworkScreen> createState() => _StudentHomeworkScreenState();
}

class _StudentHomeworkScreenState extends State<StudentHomeworkScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _homeworks = [];
  List<dynamic> _submissions = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final student = AuthService.currentStudent;
      if (student == null) {
        throw Exception('Student profile not found.');
      }
      final deptId = student['department_id'];
      if (deptId == null) {
        throw Exception('No department assigned to this student.');
      }

      // Fetch homeworks for department
      final hwResponse = await ApiService.get(
        '/homeworks',
        queryParams: {'department_id': deptId},
      );

      // Fetch student's submissions
      final subResponse = await ApiService.get(
        '/homework_submissions',
        queryParams: {'student_id': student['id']},
      );

      setState(() {
        _homeworks = List<dynamic>.from(hwResponse);
        _submissions = List<dynamic>.from(subResponse);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = ApiService.getErrorMessage(e);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRtl = loc.get('yes') == 'بەڵێ';

    // Group homeworks into Pending vs Submitted
    final submittedHwIds = _submissions.map((s) => s['homework_id']?.toString()).toSet();
    
    final pendingHomeworks = _homeworks.where((hw) => !submittedHwIds.contains(hw['id']?.toString())).toList();
    final completedHomeworks = _homeworks.where((hw) => submittedHwIds.contains(hw['id']?.toString())).toList();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          loc.get('my_homeworks'),
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelColor: AppColors.primary,
          unselectedLabelColor: isDark ? Colors.white60 : Colors.black54,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: [
            Tab(text: loc.get('pending')),
            Tab(text: loc.get('submitted')),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _isLoading
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
                            onPressed: _loadData,
                            child: Text(loc.get('retry')),
                          ),
                        ],
                      ),
                    ),
                  )
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildHomeworkList(pendingHomeworks, false, isDark, isRtl),
                      _buildHomeworkList(completedHomeworks, true, isDark, isRtl),
                    ],
                  ),
      ),
    );
  }

  Widget _buildHomeworkList(List<dynamic> list, bool isSubmittedTab, bool isDark, bool isRtl) {
    final loc = AppLocalizations.of(context);
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSubmittedTab ? Icons.check_circle_outline_rounded : Icons.assignment_outlined,
              size: 64,
              color: isDark ? Colors.white24 : Colors.black26,
            ),
            const SizedBox(height: 16),
            Text(
              isSubmittedTab
                  ? loc.get('no_submitted_homeworks')
                  : loc.get('no_pending_homeworks'),
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.black54,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final hw = list[index];
        return _buildHomeworkCard(hw, isSubmittedTab, isDark, isRtl);
      },
    );
  }

  Widget _buildHomeworkCard(dynamic hw, bool isSubmittedTab, bool isDark, bool isRtl) {
    final loc = AppLocalizations.of(context);
    final title = hw['title'] ?? hw['title_ku'] ?? hw['title_en'] ?? '';
    final desc = hw['description'] ?? hw['description_ku'] ?? hw['description_en'] ?? '';
    final filePath = hw['file_path'] as String?;

    final dueDateStr = hw['due_date'] as String?;
    DateTime? dueDate;
    bool isOverdue = false;
    bool isNearDeadline = false;
    int remainingHours = 999;

    if (dueDateStr != null) {
      try {
        dueDate = DateTime.parse(dueDateStr);
        isOverdue = dueDate.isBefore(DateTime.now()) &&
            !DateUtils.isSameDay(dueDate, DateTime.now());
        final diff = dueDate.difference(DateTime.now());
        remainingHours = diff.inHours;
        if (!isOverdue && remainingHours <= 48 && remainingHours >= 0) {
          isNearDeadline = true;
        }
      } catch (_) {}
    }

    final formattedDueDate = dueDate != null
        ? intl.DateFormat('yyyy-MM-dd').format(dueDate)
        : 'No due date';

    // Find student's submission for this homework
    final submission = isSubmittedTab
        ? _submissions.firstWhere(
            (s) => s['homework_id']?.toString() == hw['id']?.toString(),
            orElse: () => null,
          )
        : null;

    final submissionPath = submission?['file_path'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
          if (isNearDeadline && !isSubmittedTab)
            BoxShadow(
              color: Colors.redAccent.withValues(alpha: 0.15),
              blurRadius: 10,
              spreadRadius: 2,
            ),
        ],
        border: Border.all(
          color: isNearDeadline && !isSubmittedTab
              ? Colors.redAccent.withValues(alpha: 0.4)
              : isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.04),
          width: isNearDeadline && !isSubmittedTab ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dynamic accent top border
          Container(
            height: 5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isSubmittedTab
                    ? [const Color(0xFF34C759), const Color(0xFF30B0C7)]
                    : isOverdue
                        ? [Colors.grey.shade400, Colors.grey.shade600]
                        : isNearDeadline
                            ? [Colors.redAccent, Colors.orangeAccent]
                            : [AppColors.primary, const Color(0xFF9F7AEA)],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (isSubmittedTab)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF34C759).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          loc.get('submitted'),
                          style: const TextStyle(
                            color: Color(0xFF34C759),
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      )
                    else if (isOverdue)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          loc.get('overdue'),
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      )
                    else if (isNearDeadline)
                      Animate(
                        onPlay: (controller) => controller.repeat(reverse: true),
                        effects: const [
                          FadeEffect(duration: Duration(milliseconds: 700), begin: 0.5, end: 1.0)
                        ],
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            loc.get('deadline_near'),
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          loc.get('active'),
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  desc,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black87,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                
                // Show teacher's attachment
                if (filePath != null && filePath.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final uri = Uri.parse(filePath);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.02),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? Colors.white10 : Colors.black12,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.insert_drive_file_rounded, color: AppColors.primary, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            loc.get('view_attachment'),
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                
                const SizedBox(height: 16),
                Container(
                  height: 1,
                  color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                ),
                const SizedBox(height: 16),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 14,
                          color: isDark ? Colors.white30 : Colors.black38,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          loc.get('due'),
                          style: TextStyle(
                            color: isDark ? Colors.white54 : Colors.black54,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          formattedDueDate,
                          style: TextStyle(
                            color: isOverdue ? Colors.redAccent : (isDark ? Colors.white : Colors.black),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (isSubmittedTab && submissionPath != null && submissionPath.isNotEmpty)
                      TextButton.icon(
                        onPressed: () async {
                          final uri = Uri.parse(submissionPath);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          }
                        },
                        icon: const Icon(Icons.done_all_rounded, size: 16, color: Color(0xFF34C759)),
                        label: Text(
                          loc.get('view_submission'),
                          style: const TextStyle(
                            color: Color(0xFF34C759),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      )
                    else if (!isSubmittedTab && !isOverdue)
                      ElevatedButton(
                        onPressed: () => _showSubmitAnswerSheet(hw),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        child: Text(
                          loc.get('submit_answer'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSubmitAnswerSheet(dynamic homework) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _SubmitAnswerSheet(
          homework: homework,
          onSuccess: () {
            _loadData();
          },
        );
      },
    );
  }
}

class _SubmitAnswerSheet extends StatefulWidget {
  final dynamic homework;
  final VoidCallback onSuccess;
  const _SubmitAnswerSheet({required this.homework, required this.onSuccess});

  @override
  State<_SubmitAnswerSheet> createState() => _SubmitAnswerSheetState();
}

class _SubmitAnswerSheetState extends State<_SubmitAnswerSheet> {
  PlatformFile? _selectedFile;
  bool _submitting = false;

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.pickFiles();
      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFile = result.files.single;
        });
      }
    } catch (e) {
      debugPrint('Error picking answer file: $e');
    }
  }

  Future<void> _submitAnswer() async {
    final loc = AppLocalizations.of(context);
    if (_selectedFile == null || _selectedFile!.path == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.get('please_select_file')),
          backgroundColor: const Color(0xFFFF3B30),
        ),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      final student = AuthService.currentStudent;
      if (student == null) throw Exception('No student profile found.');

      // Upload submission file
      final filename = '${DateTime.now().millisecondsSinceEpoch}_answer_${_selectedFile!.name}';
      final uploadResult = await ApiService.upload(
        '/storage/homework_submissions',
        filePath: _selectedFile!.path!,
        fieldName: 'file',
        extraFields: {'path': filename},
      );
      final String? uploadedPath = uploadResult['publicUrl'] ?? uploadResult['path'];

      if (uploadedPath == null) throw Exception('Failed to upload file.');

      // Create homework_submissions record
      await ApiService.post(
        '/homework_submissions',
        data: {
          'homework_id': widget.homework['id'],
          'student_id': student['id'],
          'file_path': uploadedPath,
          'submitted_at': intl.DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
        },
      );

      if (!mounted) return;
      HapticFeedback.heavyImpact();
      widget.onSuccess();
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.get('answer_submitted_success')),
          backgroundColor: const Color(0xFF34C759),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final title = widget.homework['title'] ?? widget.homework['title_ku'] ?? widget.homework['title_en'] ?? '';
    final loc = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: bottomInset + MediaQuery.of(context).padding.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  loc.get('submit_your_homework'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            Text(
              loc.get('select_answer_file'),
              style: TextStyle(
                color: isDark ? Colors.white60 : Colors.black54,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _selectedFile == null
                ? OutlinedButton.icon(
                    onPressed: _pickFile,
                    icon: const Icon(Icons.cloud_upload_rounded),
                    label: Text(loc.get('choose_file')),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.insert_drive_file_rounded, color: AppColors.primary, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _selectedFile!.name,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _selectedFile = null;
                            });
                          },
                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 22),
                        ),
                      ],
                    ),
                  ),
            const SizedBox(height: 24),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submitAnswer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        loc.get('upload_and_submit'),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
