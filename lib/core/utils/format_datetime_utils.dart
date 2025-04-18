import 'package:intl/intl.dart';

String formatMessageTimeFromString(String datetime, String locale) {
  return formatMessageTime(DateTime.parse(datetime), locale);
}

String formatMessageTime(DateTime timestamp, String locale) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

  if (messageDate == today) {
    return DateFormat('h:mm a', locale).format(timestamp);
  } else if (messageDate == yesterday) {
    return locale == 'ar' ? 'أمس' : 'Yesterday';
  } else if (now.difference(messageDate).inDays < 7 &&
      now.isAfter(messageDate)) {
    return DateFormat('EEEE', locale).format(timestamp);
  } else if (now.year == messageDate.year) {
    return DateFormat('MMM d', locale).format(timestamp);
  } else {
    return DateFormat('MMM d, y', locale).format(timestamp);
  }
}
