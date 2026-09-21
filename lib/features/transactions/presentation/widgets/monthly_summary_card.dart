import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/core/theme/theme_extensions.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction_entity.dart';
import 'package:flutter/material.dart';

class MonthlySummaryCard extends StatelessWidget {
  final List<TransactionEntity> transactions;
  const MonthlySummaryCard({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month - 1, 1);

    double totalFor(DateTime month) => transactions
        .where(
          (t) =>
              t.type == TransactionType.expense &&
              t.transactionDate.year == month.year &&
              t.transactionDate.month == month.month,
        )
        .fold(0.0, (sum, t) => sum + t.amount);

    final thisMonthTotal = totalFor(now);
    final lastMonthTotal = totalFor(lastMonth);
    final pctChange = lastMonthTotal == 0
        ? null
        : ((thisMonthTotal - lastMonthTotal) / lastMonthTotal * 100);
    final isHigher = (pctChange ?? 0) >= 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: context.colors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.attach_money, color: Colors.white),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Monthly Summary', style: context.textStyles.bodyMedium),
                  Text(
                    "You're spending ${CurrencyFormatter.format(thisMonthTotal)} this month",
                    style: context.textStyles.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (pctChange != null) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          isHigher ? Icons.arrow_upward : Icons.arrow_downward,
                          size: 12,
                          color: isHigher
                              ? context.colors.expense
                              : context.colors.income,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${pctChange.abs().toStringAsFixed(0)}% ${isHigher ? 'higher' : 'lower'} than last month',
                          style: context.textStyles.bodyMedium?.copyWith(
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
