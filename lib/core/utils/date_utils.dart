import 'package:intl/intl.dart';

class ChatDateUtils {
  static String formatMessageTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) return DateFormat.jm().format(date);
    if (diff.inDays < 7) return DateFormat.E().format(date);
    return DateFormat.yMd().format(date);
  }

  static String formatConversationTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inDays == 0) return DateFormat.jm().format(date);
    if (diff.inDays < 7) return DateFormat.E().format(date);
    return DateFormat.yMd().format(date);
  }
}
