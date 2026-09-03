import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final _display = DateFormat('d MMM yyyy'); // e.g. 11 Aug 2026
  static final _dayMonth = DateFormat('d MMM'); // e.g. 11 Aug
  static final _iso = DateFormat('yyyy-MM-dd');

  static String display(DateTime date) => _display.format(date);
  static String dayMonth(DateTime date) => _dayMonth.format(date);
  static String toIso(DateTime date) => _iso.format(date);
  static DateTime fromIso(String date) => DateTime.parse(date);

  static bool isOverdue(DateTime dueDate) {
    final today = DateTime.now();
    final todayDateOnly = DateTime(today.year, today.month, today.day);
    return dueDate.isBefore(todayDateOnly);
  }
}
