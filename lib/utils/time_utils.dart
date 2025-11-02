import 'package:intl/intl.dart';

class TimeUtils {
  /// Trả về thời gian dạng "x phút trước" hoặc ngày nếu quá lâu
  static String formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inSeconds < 60) {
      return '${diff.inSeconds} giây trước';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} phút trước';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} giờ trước';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} ngày trước';
    } else {
      return DateFormat('dd/MM/yyyy HH:mm').format(time);
    }
  }

  /// Hỗ trợ khi dữ liệu là chuỗi (String)
  static String formatFromString(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return formatTime(date);
    } catch (e) {
      return dateStr;
    }
  }
}
