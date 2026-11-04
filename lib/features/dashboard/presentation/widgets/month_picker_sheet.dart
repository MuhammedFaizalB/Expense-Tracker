import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/core/widgets/modern_ui.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Future<DateTime?> showMonthPickerSheet(
  BuildContext context, {
  required DateTime selected,
}) {
  return showModernSheet<DateTime>(
    context,
    builder: (_) => _MonthPickerSheet(selected: selected),
  );
}

class _MonthPickerSheet extends StatelessWidget {
  final DateTime selected;
  const _MonthPickerSheet({required this.selected});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final months = List.generate(
      12,
      (i) => DateTime(now.year, now.month - i, 1),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SheetHandle(),
        const SheetHeader(
          title: 'Select month',
          subtitle: 'The whole dashboard follows this month',
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: months.map((m) {
              final isThisMonth = m.year == now.year && m.month == now.month;
              return PillOption(
                label: isThisMonth
                    ? 'This month'
                    : DateFormat('MMM yyyy').format(m),
                selected: m.year == selected.year && m.month == selected.month,
                onTap: () => Navigator.of(context).pop(m),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
