import 'package:expense_tracker/core/utils/date_formatter.dart';
import 'package:flutter/material.dart';

enum PeriodPreset {
  thisMonth,
  lastMonth,
  last3Months,
  thisYear,
  allTime,
  custom,
}

class Period {
  const Period._();

  static String label(PeriodPreset p) => switch (p) {
    PeriodPreset.thisMonth => 'This month',
    PeriodPreset.lastMonth => 'Last month',
    PeriodPreset.last3Months => 'Last 3 months',
    PeriodPreset.thisYear => 'This year',
    PeriodPreset.allTime => 'All time',
    PeriodPreset.custom => 'Custom',
  };

  static DateTimeRange? rangeFor(
    PeriodPreset p, {
    DateTimeRange? custom,
    DateTime? now,
  }) {
    final n = now ?? DateTime.now();
    return switch (p) {
      PeriodPreset.thisMonth => DateTimeRange(
        start: DateTime(n.year, n.month, 1),
        end: DateTime(n.year, n.month + 1, 0),
      ),
      PeriodPreset.lastMonth => DateTimeRange(
        start: DateTime(n.year, n.month - 1, 1),
        end: DateTime(n.year, n.month, 0),
      ),
      PeriodPreset.last3Months => DateTimeRange(
        start: DateTime(n.year, n.month - 2, 1),
        end: DateTime(n.year, n.month + 1, 0),
      ),
      PeriodPreset.thisYear => DateTimeRange(
        start: DateTime(n.year, 1, 1),
        end: DateTime(n.year, 12, 31),
      ),
      PeriodPreset.allTime => null,
      PeriodPreset.custom => custom,
    };
  }

  static PeriodPreset detect(DateTime? start, DateTime? end) {
    if (start == null || end == null) return PeriodPreset.allTime;
    bool same(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;
    for (final p in [
      PeriodPreset.thisMonth,
      PeriodPreset.lastMonth,
      PeriodPreset.last3Months,
      PeriodPreset.thisYear,
    ]) {
      final r = rangeFor(p)!;
      if (same(r.start, start) && same(r.end, end)) return p;
    }
    return PeriodPreset.custom;
  }

  static bool isWholeMonth(DateTime? start, DateTime? end) =>
      start != null &&
      end != null &&
      start.day == 1 &&
      start.year == end.year &&
      start.month == end.month &&
      end.day == DateTime(end.year, end.month + 1, 0).day;

  static String describe(DateTime? start, DateTime? end) {
    if (start == null || end == null) return 'All time';
    if (isWholeMonth(start, end)) {
      const months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];
      return '${months[start.month - 1]} ${start.year}';
    }
    return '${DateFormatter.display(start)} – ${DateFormatter.display(end)}';
  }
}
