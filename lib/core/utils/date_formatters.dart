import 'package:intl/intl.dart';

class DateFormatters {
  // 1. सिर्फ समय दिखाने के लिए (जैसे: "8:30 AM")
  static String formatTime(DateTime time) {
    return DateFormat.jm().format(time); // jm() का मतलब है Hour:Minute AM/PM
  }

  // 2. तारीख दिखाने के लिए (जैसे: "Mar 7, 2026")
  static String formatDate(DateTime date) {
    return DateFormat.yMMMd().format(date); 
  }

  // 3. दिन का नाम निकालने के लिए (जैसे: "Monday")
  static String formatDayOfWeek(DateTime date) {
    return DateFormat.EEEE().format(date);
  }

  // 4. रिलेटिव डेट (Today, Yesterday) दिखाने के लिए
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) {
      return 'Today';
    } else if (dateToCheck == yesterday) {
      return 'Yesterday';
    } else {
      return formatDate(date); // अगर पुराना है तो पूरी तारीख दिखाएगा
    }
  }

  // 5. ऐप के हेडर या समरी के लिए कस्टम फॉर्मेट (जैसे: "Today, 8:30 AM")
  static String formatRelativeWithTime(DateTime dateTime) {
    final relativeDay = formatRelativeDate(dateTime);
    final time = formatTime(dateTime);
    return '$relativeDay, $time';
  }
}
