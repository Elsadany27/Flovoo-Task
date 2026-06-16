import 'package:intl/intl.dart';

class TimeFormatter {
  TimeFormatter._();

  static String formatChatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDay = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final difference = today.difference(messageDay).inDays;

    if (difference == 0) {
      return DateFormat.jm().format(dateTime);
    }
    if (difference == 1) {
      return 'Yesterday';
    }
    if (difference < 7) {
      return DateFormat.E().format(dateTime);
    }
    return DateFormat('dd/MM/yy').format(dateTime);
  }
}
