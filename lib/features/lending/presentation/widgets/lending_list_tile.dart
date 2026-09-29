import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/core/theme/theme_extensions.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/core/utils/date_formatter.dart';
import 'package:expense_tracker/features/lending/domain/entities/lending_entity.dart';
import 'package:flutter/material.dart';

class LendingListTile extends StatelessWidget {
  final LendingEntity record;
  final VoidCallback onTap;
  final bool ledgerMode;

  const LendingListTile({
    super.key,
    required this.record,
    required this.onTap,
    this.ledgerMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final isLent = record.type == LendingType.lent;
    final amountColor = isLent ? context.colors.income : context.colors.expense;
    final overdue = record.effectiveStatus == LendingStatus.overdue;
    final isPaid = record.status == LendingStatus.paid;

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
        title: Text(
          ledgerMode
              ? (record.description ?? (isLent ? 'You lent' : 'You borrowed'))
              : record.personName,
          style: context.textStyles.titleMedium,
        ),
        subtitle: Row(
          children: [
            if (ledgerMode)
              Text(
                DateFormatter.dayMonth(record.transactionDate),
                style: context.textStyles.bodyMedium,
              ),
            if (isPaid) ...[
              SizedBox(width: ledgerMode ? AppSpacing.xs : 0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: context.colors.success.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  'Paid',
                  style: TextStyle(
                    color: context.colors.success,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
            if (record.dueDate != null && !isPaid)
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
              CurrencyFormatter.format(
                isPaid ? record.amount : record.remainingAmount,
              ),
              style: context.textStyles.titleMedium?.copyWith(
                color: isPaid ? context.colors.textSecondary : amountColor,
                decoration: isPaid ? TextDecoration.lineThrough : null,
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
