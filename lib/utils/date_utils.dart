import 'package:intl/intl.dart';

class AppDateUtils {
  const AppDateUtils._();

  static DateTime onlyDate(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  static bool isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static String formatShortDate(DateTime date, String localeCode) {
    return DateFormat.yMMMd(localeCode).format(date);
  }

  static String formatMonth(DateTime date, String localeCode) {
    return DateFormat.yMMMM(localeCode).format(date);
  }

  static String formatDateTime(DateTime date, String localeCode) {
    return DateFormat.yMMMd(localeCode).add_jm().format(date);
  }
}
