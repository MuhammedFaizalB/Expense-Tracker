extension DateTimeX on DateTime {
  DateTime get dateOnly => DateTime(year, month, day);

  bool isSameDay(DateTime other) => dateOnly == other.dateOnly;

  bool get isToday => isSameDay(DateTime.now());

  bool get isPast => dateOnly.isBefore(DateTime.now().dateOnly);

  DateTime get startOfMonth => DateTime(year, month, 1);

  DateTime get endOfMonth => DateTime(year, month + 1, 0);
}
