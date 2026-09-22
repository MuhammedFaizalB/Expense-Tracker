import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/core/theme/theme_extensions.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/core/utils/date_formatter.dart';
import 'package:expense_tracker/features/lending/domain/entities/lending_entity.dart';
import 'package:flutter/material.dart';

class LendingListTile extends StatelessWidget {
  final LendingEntity record;
  final VoidCallback onTap;

  const LendingListTile({super.key, required this.record, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isLent = record.type == LendingType.lent;
    final amountColor = isLent ? context.colors.income : context.colors.expense;
    final overdue = record.effectiveStatus == LendingStatus.overdue;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        leading: CircleAvatar(
          backgroundColor: amountColor.withValues(alpha: 0.14),
          child: Icon(
            isLent ? Icons.call_received : Icons.call_made,
            color: amountColor,
            size: 18,
          ),
        ),
        title: Text(record.personName, style: context.textStyles.titleMedium),
        subtitle: Row(
          children: [
            if (record.dueDate != null)
              Text(
                'Due ${DateFormatter.dayMonth(record.dueDate!)}',
                style: context.textStyles.bodyMedium?.copyWith(
                  color: overdue
                      ? context.colors.error
                      : context.colors.textSecondary,
                ),
              ),
            if (overdue) ...[
              const SizedBox(width: AppSpacing.xs),
              Icon(
                Icons.warning_amber_rounded,
                size: 14,
                color: context.colors.error,
              ),
            ],
            if (record.status == LendingStatus.partiallyPaid) ...[
              const SizedBox(width: AppSpacing.xs),
              Text('· Partially paid', style: context.textStyles.bodyMedium),
            ],
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              CurrencyFormatter.format(record.remainingAmount),
              style: context.textStyles.titleMedium?.copyWith(
                color: amountColor,
              ),
            ),
            if (record.status == LendingStatus.partiallyPaid)
              Text(
                'of ${CurrencyFormatter.format(record.amount)}',
                style: context.textStyles.bodyMedium,
              ),
          ],
        ),
      ),
    );
  }
}
