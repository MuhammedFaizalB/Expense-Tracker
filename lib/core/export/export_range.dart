import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/core/theme/theme_extensions.dart';
import 'package:expense_tracker/core/utils/date_formatter.dart';
import 'package:flutter/material.dart';

class ExportRange {
  final DateTimeRange? range;
  final String label;
  const ExportRange({required this.range, required this.label});

  String get periodText => range == null
      ? 'All time'
      : '${DateFormatter.display(range!.start)} – ${DateFormatter.display(range!.end)}';

  String get fileSuffix => range == null
      ? 'all_time'
      : '${DateFormatter.toIso(range!.start)}_to_${DateFormatter.toIso(range!.end)}';

  bool contains(DateTime date) {
    final r = range;
    if (r == null) return true;
    final day = DateTime(date.year, date.month, date.day);
    final start = DateTime(r.start.year, r.start.month, r.start.day);
    final end = DateTime(r.end.year, r.end.month, r.end.day);
    return !day.isBefore(start) && !day.isAfter(end);
  }
}

Future<ExportRange?> showExportRangeSheet(
  BuildContext context, {
  required String title,
}) {
  return showModalBottomSheet<ExportRange>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _ExportRangeSheet(title: title),
  );
}

enum _Preset { thisMonth, lastMonth, last3Months, thisYear, allTime, custom }

class _ExportRangeSheet extends StatefulWidget {
  final String title;
  const _ExportRangeSheet({required this.title});

  @override
  State<_ExportRangeSheet> createState() => _ExportRangeSheetState();
}

class _ExportRangeSheetState extends State<_ExportRangeSheet> {
  _Preset _preset = _Preset.thisMonth;
  DateTimeRange? _custom;

  String _labelFor(_Preset p) => switch (p) {
    _Preset.thisMonth => 'This month',
    _Preset.lastMonth => 'Last month',
    _Preset.last3Months => 'Last 3 months',
    _Preset.thisYear => 'This year',
    _Preset.allTime => 'All time',
    _Preset.custom => 'Custom',
  };

  DateTimeRange? _rangeFor(_Preset p) {
    final n = DateTime.now();
    return switch (p) {
      _Preset.thisMonth => DateTimeRange(
        start: DateTime(n.year, n.month, 1),
        end: DateTime(n.year, n.month + 1, 0),
      ),
      _Preset.lastMonth => DateTimeRange(
        start: DateTime(n.year, n.month - 1, 1),
        end: DateTime(n.year, n.month, 0),
      ),
      _Preset.last3Months => DateTimeRange(
        start: DateTime(n.year, n.month - 2, 1),
        end: DateTime(n.year, n.month + 1, 0),
      ),
      _Preset.thisYear => DateTimeRange(
        start: DateTime(n.year, 1, 1),
        end: DateTime(n.year, 12, 31),
      ),
      _Preset.allTime => null,
      _Preset.custom => _custom,
    };
  }

  String get _periodText {
    final r = _rangeFor(_preset);
    return r == null
        ? 'Every record, no date limit'
        : '${DateFormatter.display(r.start)} – ${DateFormatter.display(r.end)}';
  }

  Future<void> _pickCustom() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 1, 12, 31),
      initialDateRange: _custom,
      helpText: 'Select export period',
    );
    if (!mounted || picked == null) return;
    setState(() {
      _custom = picked;
      _preset = _Preset.custom;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, style: context.textStyles.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Choose the period to include in the PDF.',
              style: context.textStyles.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: _Preset.values.map((p) {
                return ChoiceChip(
                  avatar: p == _Preset.custom
                      ? const Icon(Icons.date_range, size: 16)
                      : null,
                  label: Text(_labelFor(p)),
                  selected: _preset == p,
                  onSelected: (_) => p == _Preset.custom
                      ? _pickCustom()
                      : setState(() => _preset = p),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.md),
            InkWell(
              onTap: _preset == _Preset.custom ? _pickCustom : null,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: context.colors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: context.colors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        _periodText,
                        style: context.textStyles.bodyLarge,
                      ),
                    ),
                    if (_preset == _Preset.custom)
                      Icon(
                        Icons.edit_outlined,
                        size: 16,
                        color: context.colors.textSecondary,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: const Text('Generate PDF'),
                onPressed: () => Navigator.pop(
                  context,
                  ExportRange(
                    range: _rangeFor(_preset),
                    label: _labelFor(_preset),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
