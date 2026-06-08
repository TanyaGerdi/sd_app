import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sd_institute/services/api_service.dart';
import 'package:sd_institute/services/auth_service.dart';
import 'package:sd_institute/utils/app_localizations.dart';
import 'package:sd_institute/theme/app_colors.dart';
import 'package:intl/intl.dart' as intl;
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class TeacherHomeworkScreen extends StatefulWidget {
  const TeacherHomeworkScreen({super.key});

  @override
  State<TeacherHomeworkScreen> createState() => _TeacherHomeworkScreenState();
}

class _TeacherHomeworkScreenState extends State<TeacherHomeworkScreen> {
  List<dynamic> _homeworks = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadHomeworks();
  }

  Future<void> _loadHomeworks() async {
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
        '/homeworks',
        queryParams: {
          'department_id': deptId,
          'teacher_id': teacher['id'],
        },
      );

      setState(() {
        _homeworks = List<dynamic>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = ApiService.getErrorMessage(e);
        _isLoading = false;
      });
    }
  }

  void _showAddHomeworkSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _AddHomeworkSheet(
          onSuccess: () {
            _loadHomeworks();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          loc.get('submit_homeworks'),
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
      body: RefreshIndicator(
        onRefresh: _loadHomeworks,
        child: _isLoading && _homeworks.isEmpty
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
                            onPressed: _loadHomeworks,
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    ),
                  )
                : _homeworks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.assignment_turned_in_rounded, size: 64, color: isDark ? Colors.white30 : Colors.black38),
                            const SizedBox(height: 12),
                            Text(
                              'No homework submissions yet.',
                              style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 14),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _showAddHomeworkSheet,
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Add First Assignment'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                        padding: const EdgeInsets.all(16),
                        itemCount: _homeworks.length,
                        itemBuilder: (context, index) {
                          final hw = _homeworks[index];
                          return _buildHomeworkCard(hw, isDark, loc);
                        },
                      ),
      ),
      floatingActionButton: _homeworks.isNotEmpty
          ? FloatingActionButton(
              onPressed: _showAddHomeworkSheet,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white, size: 24),
            )
          : null,
    );
  }

  Widget _buildHomeworkCard(dynamic hw, bool isDark, AppLocalizations loc) {
    final title = hw['title'] ?? hw['title_ku'] ?? hw['title_en'] ?? '';
    final desc = hw['description'] ?? hw['description_ku'] ?? hw['description_en'] ?? '';
    final filePath = hw['file_path'] as String?;

    final dueDateStr = hw['due_date'] as String?;
    DateTime? dueDate;
    bool isOverdue = false;
    if (dueDateStr != null) {
      try {
        dueDate = DateTime.parse(dueDateStr);
        isOverdue = dueDate.isBefore(DateTime.now()) &&
            !DateUtils.isSameDay(dueDate, DateTime.now());
      } catch (_) {}
    }

    final formattedDueDate = dueDate != null
        ? intl.DateFormat('yyyy-MM-dd').format(dueDate)
        : 'No due date';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Accent border indicating status
          Container(
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isOverdue
                    ? [Colors.redAccent, Colors.red]
                    : [const Color(0xFF34C759), AppColors.primary],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isOverdue
                            ? Colors.red.withValues(alpha: 0.1)
                            : const Color(0xFF34C759).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        isOverdue ? 'Overdue' : 'Active',
                        style: TextStyle(
                          color: isOverdue ? Colors.red : const Color(0xFF34C759),
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  desc,
                  style: TextStyle(
                    color: isDark ? Colors.white60 : Colors.black54,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                if (filePath != null && filePath.isNotEmpty) ...[
                  const SizedBox(height: 12),
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
                            'View Attachment',
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
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 14,
                      color: isDark ? Colors.white30 : Colors.black38,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Due Date: ',
                      style: TextStyle(
                        color: isDark ? Colors.white30 : Colors.black38,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      formattedDueDate,
                      style: TextStyle(
                        color: isOverdue ? Colors.redAccent : (isDark ? Colors.white70 : Colors.black87),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
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
}

class _AddHomeworkSheet extends StatefulWidget {
  final VoidCallback onSuccess;
  const _AddHomeworkSheet({required this.onSuccess});

  @override
  State<_AddHomeworkSheet> createState() => _AddHomeworkSheetState();
}

class _AddHomeworkSheetState extends State<_AddHomeworkSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  PlatformFile? _selectedFile;

  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
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
      debugPrint('Error picking file: $e');
    }
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
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
    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    try {
      final teacher = AuthService.currentStudent;
      if (teacher == null) throw Exception('No teacher profile context found.');
      final deptId = teacher['department_id'];
      final teacherId = teacher['id'];

      String? uploadedFilePath;

      if (_selectedFile != null && _selectedFile!.path != null) {
        final filename = '${DateTime.now().millisecondsSinceEpoch}_${_selectedFile!.name}';
        final uploadResult = await ApiService.upload(
          '/storage/homeworks',
          filePath: _selectedFile!.path!,
          fieldName: 'file',
          extraFields: {'path': filename},
        );
        uploadedFilePath = uploadResult['publicUrl'] ?? uploadResult['path'];
      }

      final dateStr = intl.DateFormat('yyyy-MM-dd').format(_dueDate);

      await ApiService.post(
        '/homeworks',
        data: {
          'title': _titleCtrl.text.trim(),
          'description': _descCtrl.text.trim(),
          'due_date': dateStr,
          'file_path': uploadedFilePath,
          'department_id': deptId,
          'teacher_id': teacherId,
        },
      );

      // Create student notification
      try {
        await ApiService.post(
          '/notifications',
          data: {
            'title_ku': 'ئەرکی نوێ: ${_titleCtrl.text.trim()}',
            'title_en': 'New Homework: ${_titleCtrl.text.trim()}',
            'description_ku': 'ئەرکێکی نوێ بارکراوە بۆ بەشەکەت. کاتی کۆتایی: $dateStr.',
            'description_en': 'A new homework assignment has been posted. Due: $dateStr.',
            'target_audience': 'dept_$deptId',
          },
        );
      } catch (e) {
        debugPrint('Failed to send notification: $e');
      }

      if (!mounted) return;
      HapticFeedback.heavyImpact();
      widget.onSuccess();
      Navigator.pop(context);
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
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Post New Homework',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              _buildField(
                controller: _titleCtrl,
                label: 'Title',
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              
              _buildField(
                controller: _descCtrl,
                label: 'Description',
                maxLines: 3,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                isDark: isDark,
              ),
              const SizedBox(height: 16),

              Text(
                'Attachment File (Optional)',
                style: TextStyle(
                  color: isDark ? Colors.white60 : Colors.black54,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              _selectedFile == null
                  ? OutlinedButton.icon(
                      onPressed: _pickFile,
                      icon: const Icon(Icons.attach_file_rounded),
                      label: const Text('Attach File'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.insert_drive_file_rounded, color: AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _selectedFile!.name,
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                                fontSize: 13,
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
                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                          ),
                        ],
                      ),
                    ),
              const SizedBox(height: 18),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Due Date',
                        style: TextStyle(
                          color: isDark ? Colors.white60 : Colors.black54,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        intl.DateFormat('yyyy MMM dd').format(_dueDate),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () => _selectDueDate(context),
                    icon: Icon(Icons.edit_calendar_rounded, color: AppColors.primary),
                    label: Text(
                      'Choose Date',
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
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
                      : const Text(
                          'Submit Assignment',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    String? Function(String?)? validator,
    required bool isDark,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? Colors.white38 : Colors.black38,
          fontSize: 13,
        ),
        filled: true,
        fillColor: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.02),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}
