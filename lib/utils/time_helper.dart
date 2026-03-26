class TimeHelper {
  static String timeAgo(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 365) return '${(difference.inDays / 365).floor()} ساڵ پێش ئێستا';
      if (difference.inDays > 30) return '${(difference.inDays / 30).floor()} مانگ پێش ئێستا';
      if (difference.inDays > 0) return '${difference.inDays} ڕۆژ پێش ئێستا';
      if (difference.inHours > 0) return '${difference.inHours} کاتژمێر پێش ئێستا';
      if (difference.inMinutes > 0) return '${difference.inMinutes} خولەک پێش ئێستا';
      return 'کەمێک پێش ئێستا';
    } catch (_) {
      return dateStr;
    }
  }
}
