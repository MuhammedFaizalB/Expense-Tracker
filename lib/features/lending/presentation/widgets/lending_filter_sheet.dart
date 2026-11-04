import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/core/theme/theme_extensions.dart';
import 'package:expense_tracker/core/widgets/modern_ui.dart';
import 'package:expense_tracker/features/lending/domain/entities/lending_entity.dart';
import 'package:expense_tracker/features/lending/presentation/bloc/lending_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> showLendingFilterSheet(BuildContext context) {
  return showModernSheet<void>(
    context,
    builder: (_) => const LendingFilterSheet(),
  );
}

class LendingFilterSheet extends StatefulWidget {
  const LendingFilterSheet({super.key});

  @override
  State<LendingFilterSheet> createState() => _LendingFilterSheetState();
}

class _LendingFilterSheetState extends State<LendingFilterSheet> {
  late LendingType? _type = context.read<LendingBloc>().state.filterType;
  late LendingStatus? _status = context.read<LendingBloc>().state.filterStatus;

  String _statusLabel(LendingStatus s) => switch (s) {
    LendingStatus.pending => 'Pending',
    LendingStatus.partiallyPaid => 'Partially paid',
    LendingStatus.overdue => 'Overdue',
    LendingStatus.paid => 'Paid',
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SheetHandle(),
        SheetHeader(
          title: 'Filter records',
          subtitle: 'Narrow the lending list',
          actionLabel: 'Reset',
          onAction: () => setState(() {
            _type = null;
            _status = null;
          }),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SheetSectionLabel('Direction'),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  PillOption(
                    label: 'All',
                    selected: _type == null,
                    onTap: () => setState(() => _type = null),
                  ),
                  PillOption(
                    label: 'I lent',
                    icon: Icons.north_east_rounded,
                    accent: colors.income,
                    selected: _type == LendingType.lent,
                    onTap: () => setState(() => _type = LendingType.lent),
                  ),
                  PillOption(
                    label: 'I borrowed',
                    icon: Icons.south_west_rounded,
                    accent: colors.expense,
                    selected: _type == LendingType.borrowed,
                    onTap: () => setState(() => _type = LendingType.borrowed),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              const SheetSectionLabel('Status'),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  PillOption(
                    label: 'All',
                    selected: _status == null,
                    onTap: () => setState(() => _status = null),
                  ),
                  ...LendingStatus.values.map(
                    (s) => PillOption(
                      label: _statusLabel(s),
                      selected: _status == s,
                      onTap: () => setState(() => _status = s),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: ElevatedButton(
            onPressed: () {
              context.read<LendingBloc>().add(
                LendingFilterChanged(type: _type, status: _status),
              );
              Navigator.of(context).pop();
            },
            child: const Text('Apply filters'),
          ),
        ),
      ],
    );
  }
}
