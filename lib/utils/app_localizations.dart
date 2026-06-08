import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Supported app languages
enum AppLanguage { ku, ar, en }

/// Provides localization management with persistence.
class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'app_locale';
  AppLanguage _language = AppLanguage.ku;

  AppLanguage get language => _language;

  Locale get locale {
    switch (_language) {
      case AppLanguage.ku:
        return const Locale('ku');
      case AppLanguage.ar:
        return const Locale('ar');
      case AppLanguage.en:
        return const Locale('en');
    }
  }

  bool get isRtl => _language != AppLanguage.en;

  TextDirection get textDirection =>
      isRtl ? TextDirection.rtl : TextDirection.ltr;

  /// Load saved language preference
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_localeKey);
    if (saved != null) {
      _language = AppLanguage.values.firstWhere(
        (l) => l.name == saved,
        orElse: () => AppLanguage.ku,
      );
    }
  }

  /// Change language and persist
  Future<void> setLanguage(AppLanguage lang) async {
    if (_language == lang) return;
    _language = lang;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, lang.name);
  }

  /// Get the display name of the current language
  String get languageName {
    switch (_language) {
      case AppLanguage.ku:
        return 'کوردی';
      case AppLanguage.ar:
        return 'العربية';
      case AppLanguage.en:
        return 'English';
    }
  }

  /// Get the flag emoji for the current language
  String get languageFlag {
    switch (_language) {
      case AppLanguage.ku:
        return '🇮🇶';
      case AppLanguage.ar:
        return '🇸🇦';
      case AppLanguage.en:
        return '🇬🇧';
    }
  }
}

/// InheritedWidget to provide locale access down the tree
class LocaleProviderInherited extends InheritedNotifier<LocaleProvider> {
  const LocaleProviderInherited({
    super.key,
    required LocaleProvider provider,
    required super.child,
  }) : super(notifier: provider);

  static LocaleProvider of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<LocaleProviderInherited>()!
        .notifier!;
  }
}

/// All translated strings for the app
class AppLocalizations {
  final AppLanguage _lang;

  AppLocalizations(this._lang);

  /// Factory from BuildContext
  static AppLocalizations of(BuildContext context) {
    final provider = LocaleProviderInherited.of(context);
    return AppLocalizations(provider.language);
  }

  String get(String key) => _strings[key]?[_lang.name] ?? key;

  // ─── Translation Map ────────────────────────────────────────────────────
  static const Map<String, Map<String, String>> _strings = {
    // ── Institute Name ─────────────────────────────────────────
    'institute_name': {
      'ku': 'پەیمانگەی تەکنیکی SD',
      'ar': 'معهد SD التقني',
      'en': 'SD Technical Institute',
    },
    'institute_tagline': {
      'ku': 'SD Technical and Vocational Institute',
      'ar': 'SD Technical and Vocational Institute',
      'en': 'SD Technical and Vocational Institute',
    },
    'institute_slogan': {
      'ku': 'داهاتووتان بنیاد دەنێین',
      'ar': 'نبني مستقبلكم',
      'en': 'Building Your Future',
    },

    // ── Navigation / Drawer ────────────────────────────────────
    'home': {
      'ku': 'پەڕەی سەرەکی',
      'ar': 'الصفحة الرئيسية',
      'en': 'Home',
    },
    'departments': {
      'ku': 'بەشەکان',
      'ar': 'الأقسام',
      'en': 'Departments',
    },
    'staff': {
      'ku': 'مامۆستایان',
      'ar': 'الكادر التدريسي',
      'en': 'Staff',
    },
    'about': {
      'ku': 'دەربارەی ئێمە',
      'ar': 'عن المعهد',
      'en': 'About Us',
    },
    'news': {
      'ku': 'هەواڵەکان',
      'ar': 'الأخبار',
      'en': 'News',
    },
    'saved': {
      'ku': 'پاشەکەوتکراوەکان',
      'ar': 'المحفوظات',
      'en': 'Saved',
    },
    'contact': {
      'ku': 'پەیوەندی',
      'ar': 'اتصل بنا',
      'en': 'Contact',
    },
    'students': {
      'ku': 'قوتابیان',
      'ar': 'الطلاب',
      'en': 'Students',
    },
    'schedule': {
      'ku': 'خشتەی وانەکان',
      'ar': 'جدول المحاضرات',
      'en': 'Schedule',
    },
    'guidelines': {
      'ku': 'ڕێنماییەکان',
      'ar': 'الإرشادات',
      'en': 'Guidelines',
    },
    'portal': {
      'ku': 'پۆرتاڵی پەیمانگە',
      'ar': 'بوابة المعهد',
      'en': 'Institute Portal',
    },

    // ── Theme ──────────────────────────────────────────────────
    'appearance': {
      'ku': 'ڕووکار',
      'ar': 'المظهر',
      'en': 'Appearance',
    },
    'light': {
      'ku': 'ڕووناکی',
      'ar': 'فاتح',
      'en': 'Light',
    },
    'dark': {
      'ku': 'تاریکی',
      'ar': 'داكن',
      'en': 'Dark',
    },

    // ── Language ───────────────────────────────────────────────
    'language': {
      'ku': 'زمان',
      'ar': 'اللغة',
      'en': 'Language',
    },

    // ── Auth ───────────────────────────────────────────────────
    'login': {
      'ku': 'چوونەژوورەوە',
      'ar': 'تسجيل الدخول',
      'en': 'Login',
    },
    'logout': {
      'ku': 'چوونەدەرەوە',
      'ar': 'تسجيل الخروج',
      'en': 'Logout',
    },
    'email': {
      'ku': 'ئیمەیڵ',
      'ar': 'البريد الإلكتروني',
      'en': 'Email',
    },
    'password': {
      'ku': 'وشەی نهێنی',
      'ar': 'كلمة المرور',
      'en': 'Password',
    },
    'login_subtitle': {
      'ku': 'بۆ بینینی زانیاریی خۆت چوونەژوورەوە بکە',
      'ar': 'سجل دخولك لعرض معلوماتك',
      'en': 'Login to view your information',
    },
    'login_error': {
      'ku': 'ئیمەیڵ یان وشەی نهێنی هەڵەیە',
      'ar': 'البريد الإلكتروني أو كلمة المرور غير صحيحة',
      'en': 'Invalid email or password',
    },
    'login_success': {
      'ku': 'سەرکەوتووانە چوویتە ژوورەوە',
      'ar': 'تم تسجيل الدخول بنجاح',
      'en': 'Login successful',
    },
    'logout_confirm': {
      'ku': 'دڵنیایت لە چوونەدەرەوە؟',
      'ar': 'هل أنت متأكد من تسجيل الخروج؟',
      'en': 'Are you sure you want to logout?',
    },
    'yes': {
      'ku': 'بەڵێ',
      'ar': 'نعم',
      'en': 'Yes',
    },
    'no': {
      'ku': 'نەخێر',
      'ar': 'لا',
      'en': 'No',
    },
    'welcome_back': {
      'ku': 'بەخێربێیتەوە',
      'ar': 'أهلاً بعودتك',
      'en': 'Welcome Back',
    },
    'student_account': {
      'ku': 'هەژماری قوتابی',
      'ar': 'حساب الطالب',
      'en': 'Student Account',
    },
    'student': {
      'ku': 'قوتابی',
      'ar': 'طالب',
      'en': 'Student',
    },
    'teacher': {
      'ku': 'مامۆستا',
      'ar': 'أستاذ',
      'en': 'Teacher',
    },
    'take_attendance': {
      'ku': 'تۆمارکردنی ئامادەبوون',
      'ar': 'تسجيل الحضور والغياب',
      'en': 'Take Attendance',
    },
    'save_attendance_changes': {
      'ku': 'پاشکەوتکردنی گۆڕانکارییەکان',
      'ar': 'حفظ التغييرات',
      'en': 'Save Changes',
    },
    'submit_attendance_log': {
      'ku': 'ناردنی ئامادەبوون',
      'ar': 'إرسال الحضور والغياب',
      'en': 'Submit Attendance Log',
    },
    'submit_homeworks': {
      'ku': 'ناردنی ئەرکەکان',
      'ar': 'إرسال الواجبات البيئية',
      'en': 'Submit Homeworks',
    },

    // ── Fees ───────────────────────────────────────────────────
    'my_fees': {
      'ku': 'باری دارایی',
      'ar': 'الرسوم الدراسية',
      'en': 'My Fees',
    },
    'my_homeworks': {
      'ku': 'ئەرکەکان',
      'ar': 'الواجبات المنزلية',
      'en': 'My Homeworks',
    },
    'total_fees': {
      'ku': 'کۆی ئەرکی دارایی',
      'ar': 'إجمالي الرسوم',
      'en': 'Total Fees',
    },
    'total_paid': {
      'ku': 'کۆی دراوە',
      'ar': 'المبلغ المدفوع',
      'en': 'Total Paid',
    },
    'remaining': {
      'ku': 'پاشماوە',
      'ar': 'المتبقي',
      'en': 'Remaining',
    },
    'discount': {
      'ku': 'داشکاندن',
      'ar': 'الخصم',
      'en': 'Discount',
    },
    'installments': {
      'ku': 'قیستەکان',
      'ar': 'الأقساط',
      'en': 'Installments',
    },
    'installment': {
      'ku': 'قیست',
      'ar': 'قسط',
      'en': 'Installment',
    },
    'payment_history': {
      'ku': 'مێژووی پارەدان',
      'ar': 'سجل المدفوعات',
      'en': 'Payment History',
    },
    'due_date': {
      'ku': 'بەرواری دوایین',
      'ar': 'تاريخ الاستحقاق',
      'en': 'Due Date',
    },
    'amount': {
      'ku': 'بڕ',
      'ar': 'المبلغ',
      'en': 'Amount',
    },
    'receipt': {
      'ku': 'ژمارەی وەصڵ',
      'ar': 'رقم الإيصال',
      'en': 'Receipt',
    },
    'cash': {
      'ku': 'نەقد',
      'ar': 'نقدي',
      'en': 'Cash',
    },
    'bank_transfer': {
      'ku': 'حەوالەی بانکی',
      'ar': 'تحويل بنكي',
      'en': 'Bank Transfer',
    },
    'fib': {
      'ku': 'FIB',
      'ar': 'FIB',
      'en': 'FIB',
    },
    'no_fees': {
      'ku': 'هیچ زانیارییەکی دارایی نییە',
      'ar': 'لا توجد معلومات مالية',
      'en': 'No fee information available',
    },
    'paid_percentage': {
      'ku': 'دراوە',
      'ar': 'مدفوع',
      'en': 'Paid',
    },
    'fee_status': {
      'ku': 'بارودۆخی دارایی',
      'ar': 'الحالة المالية',
      'en': 'Fee Status',
    },

    // ── Attendance ─────────────────────────────────────────────
    'my_attendance': {
      'ku': 'ئامادەبوون',
      'ar': 'الحضور',
      'en': 'My Attendance',
    },
    'present': {
      'ku': 'ئامادە',
      'ar': 'حاضر',
      'en': 'Present',
    },
    'absent': {
      'ku': 'نەهاتوو',
      'ar': 'غائب',
      'en': 'Absent',
    },
    'late': {
      'ku': 'دوا کەوتوو',
      'ar': 'متأخر',
      'en': 'Late',
    },
    'attendance_rate': {
      'ku': 'ڕێژەی ئامادەبوون',
      'ar': 'نسبة الحضور',
      'en': 'Attendance Rate',
    },
    'total_days': {
      'ku': 'کۆی ڕۆژەکان',
      'ar': 'إجمالي الأيام',
      'en': 'Total Days',
    },
    'no_attendance': {
      'ku': 'هیچ تۆمارێکی ئامادەبوون نییە',
      'ar': 'لا توجد سجلات حضور',
      'en': 'No attendance records found',
    },
    'all_months': {
      'ku': 'هەموو مانگەکان',
      'ar': 'جميع الأشهر',
      'en': 'All Months',
    },
    'attendance_summary': {
      'ku': 'پوختەی ئامادەبوون',
      'ar': 'ملخص الحضور',
      'en': 'Attendance Summary',
    },

    // ── Home Screen ───────────────────────────────────────────
    'latest_news': {
      'ku': 'نوێترین هەواڵەکان',
      'ar': 'آخر الأخبار',
      'en': 'Latest News',
    },
    'see_all': {
      'ku': 'هەموو',
      'ar': 'عرض الكل',
      'en': 'See All',
    },
    'quick_access': {
      'ku': 'بەستەرە خێراکان',
      'ar': 'الوصول السريع',
      'en': 'Quick Access',
    },
    'latest_guidelines': {
      'ku': 'نوێترین ڕێنماییەکان',
      'ar': 'أحدث الإرشادات',
      'en': 'Latest Guidelines',
    },
    'admission_guidelines': {
      'ku': 'ڕێنماییەکانی وەرگرتنی قوتابیان',
      'ar': 'إرشادات القبول',
      'en': 'Admission Guidelines',
    },
    'admission_subtitle': {
      'ku': 'زانیاری تەواو دەربارەی وەرگرتن دراستە',
      'ar': 'معلومات كاملة عن القبول والتسجيل',
      'en': 'Complete information about admission',
    },
    'future_activities': {
      'ku': 'چالاکییەکانی داهاتوو',
      'ar': 'الأنشطة المستقبلية',
      'en': 'Future Activities',
    },
    'future_activities_subtitle': {
      'ku': 'خشتەی بۆنە و چالاکییەکانی پەیمانگە',
      'ar': 'جدول الفعاليات والأنشطة',
      'en': 'Events and activities schedule',
    },

    // ── General ────────────────────────────────────────────────
    'loading': {
      'ku': 'چاوەڕوان بە...',
      'ar': 'جاري التحميل...',
      'en': 'Loading...',
    },
    'error': {
      'ku': 'هەڵە ڕوویدا',
      'ar': 'حدث خطأ',
      'en': 'An error occurred',
    },
    'retry': {
      'ku': 'هەوڵبدەرەوە',
      'ar': 'إعادة المحاولة',
      'en': 'Retry',
    },
    'cancel': {
      'ku': 'پاشگەزبوونەوە',
      'ar': 'إلغاء',
      'en': 'Cancel',
    },
    'notifications': {
      'ku': 'ئاگاداریەکان',
      'ar': 'الإشعارات',
      'en': 'Notifications',
    },
    'now': {
      'ku': 'ئێستا',
      'ar': 'الآن',
      'en': 'Now',
    },
    'no_data': {
      'ku': 'هیچ زانیارییەک نەدۆزرایەوە',
      'ar': 'لا توجد بيانات',
      'en': 'No data found',
    },
    'please_login': {
      'ku': 'تکایە سەرەتا چوونەژوورەوە بکە',
      'ar': 'يرجى تسجيل الدخول أولاً',
      'en': 'Please login first',
    },
    // Extra translations for screens
    'departments_title': {
      'ku': 'بەشەکانی پەیمانگە',
      'ar': 'أقسام المعهد',
      'en': 'Institute Departments',
    },
    'scientific_dept': {
      'ku': 'بەشی زانستی',
      'ar': 'القسم العلمي',
      'en': 'Scientific Department',
    },
    'specialty': {
      'ku': 'تایبەتمەندی',
      'ar': 'التخصّص',
      'en': 'Specialty',
    },
    'students_count': {
      'ku': 'قوتابیان',
      'ar': 'الطلاب',
      'en': 'Students',
    },
    'teachers_count': {
      'ku': 'مامۆستایان',
      'ar': 'الأساتذة',
      'en': 'Teachers',
    },
    'about_title': {
      'ku': 'دەربارەی ئێمە',
      'ar': 'عن المعهد',
      'en': 'About Us',
    },
    'our_story': {
      'ku': 'چیرۆکی ئێمە',
      'ar': 'قصتنا',
      'en': 'Our Story',
    },
    'contact_info': {
      'ku': 'زانیاری پەیوەندی',
      'ar': 'معلومات الاتصال',
      'en': 'Contact Information',
    },
    'working_hours': {
      'ku': 'کاتژمێری کارکردن',
      'ar': 'ساعات العمل',
      'en': 'Working Hours',
    },
    'contact_title': {
      'ku': 'پەیوەندیمان پێوە بکە',
      'ar': 'اتصل بنا',
      'en': 'Get in Touch',
    },
    'we_are_here': {
      'ku': 'ئێمە لێرەین',
      'ar': 'نحن هنا',
      'en': 'We Are Here',
    },
    'fast_response': {
      'ku': 'بە خێرایی وەڵامی پرسیارەکانت دەدەینەوە',
      'ar': 'سنجيب على استفساراتكم بسرعة',
      'en': 'We reply to your queries quickly',
    },
    'address': {
      'ku': 'ناونیشان',
      'ar': 'العنوان',
      'en': 'Address',
    },
    'phone': {
      'ku': 'تەلەفۆن',
      'ar': 'الهاتف',
      'en': 'Phone',
    },
    'social_media': {
      'ku': 'تۆڕە کۆمەڵایەتییەکان',
      'ar': 'وسائل التواصل الاجتماعي',
      'en': 'Social Media',
    },
    'post_saved': {
      'ku': 'پاشەکەوتکرا',
      'ar': 'تم الحفظ',
      'en': 'Saved',
    },
    'post_removed': {
      'ku': 'لاڕبرا',
      'ar': 'تم الإزالة',
      'en': 'Removed',
    },
    'read_more': {
      'ku': 'زیاتر',
      'ar': 'المزيد',
      'en': 'Read More',
    },
    'employees': {
      'ku': 'فەرمانبەران',
      'ar': 'الموظفين',
      'en': 'Employees',
    },
    'teachers': {
      'ku': 'مامۆستایان',
      'ar': 'المعلمين',
      'en': 'Teachers',
    },
    'council': {
      'ku': 'ئەنجومەن',
      'ar': 'مجلس الإدارة',
      'en': 'Council',
    },
    'all': {
      'ku': 'هەموو',
      'ar': 'الكل',
      'en': 'All',
    },
    'registration': {
      'ku': 'تۆمار',
      'ar': 'التسجيل',
      'en': 'Registration',
    },
    'quality_assurance': {
      'ku': 'دڵنیایی جۆری',
      'ar': 'ضمان الجودة',
      'en': 'Quality Assurance',
    },
    'dean': {
      'ku': 'ڕاگر',
      'ar': 'العميد',
      'en': 'Dean',
    },
    'media': {
      'ku': 'ڕاگەیاندن',
      'ar': 'الإعلام',
      'en': 'Media',
    },
    'accounting': {
      'ku': 'ژمێریاری',
      'ar': 'الحسابات',
      'en': 'Accounting',
    },
    'administration': {
      'ku': 'کارگێڕی',
      'ar': 'الإدارة',
      'en': 'Administration',
    },
    'dean_office': {
      'ku': 'نوسینگەی ڕاگر',
      'ar': 'مكتب العميد',
      'en': 'Dean\'s Office',
    },
    'nursing_teachers': {
      'ku': 'مامۆستایانی بەشی پەرستاری',
      'ar': 'مدرسي قسم التمريض',
      'en': 'Nursing Teachers',
    },
    'pharmacy_teachers': {
      'ku': 'مامۆستایانی بەشی دەرمانسازی',
      'ar': 'مدرسي قسم الصيدلة',
      'en': 'Pharmacy Teachers',
    },
    'english_teachers': {
      'ku': 'مامۆستایانی بەشی ئینگلیزی پیشەیی',
      'ar': 'مدرسي قسم اللغة الإنجليزية المهنية',
      'en': 'Professional English Teachers',
    },
    'dean_of_institute': {
      'ku': 'ڕاگری پەیمانگە',
      'ar': 'عميد المعهد',
      'en': 'Dean of Institute',
    },
    'head_of_nursing': {
      'ku': 'سەرۆک بەشی پەرستاری',
      'ar': 'رئيس قسم التمريض',
      'en': 'Head of Nursing',
    },
    'head_of_pharmacy': {
      'ku': 'سەرۆک بەشی دەرمانسازی',
      'ar': 'رئيس قسم الصيدلة',
      'en': 'Head of Pharmacy',
    },
    'head_of_english': {
      'ku': 'سەرۆک بەشی ئینگلیزی پیشەیی',
      'ar': 'رئيس قسم اللغة الإنجليزية المهنية',
      'en': 'Head of Professional English',
    },
    'staff_members': {
      'ku': 'ئەندام',
      'ar': 'عضو',
      'en': 'Members',
    },
    'staff_title': {
      'ku': 'مامۆستایان و ستاف',
      'ar': 'الكادر التدريسي والموظفين',
      'en': 'Staff & Teachers',
    },
    'dept_staff_title': {
      'ku': 'مامۆستایانی بەشەکە',
      'ar': 'مدرسي القسم',
      'en': 'Department Staff',
    },
    'no_staff_found': {
      'ku': 'هیچ ستافێک نەدۆزرایەوە لەم بەشەدا',
      'ar': 'لم يتم العثور على أي موظف في هذا القسم',
      'en': 'No staff members found in this department',
    },
  };
}
