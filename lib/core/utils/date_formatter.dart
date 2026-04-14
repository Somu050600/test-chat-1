import 'package:timeago/timeago.dart' as timeago;

class DateFormatter {
  DateFormatter._();

  static String relative(DateTime date) {
    return timeago.format(date);
  }

  static String time(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
