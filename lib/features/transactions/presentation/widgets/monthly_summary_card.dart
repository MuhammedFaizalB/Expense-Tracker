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
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: AppEffects.heroGradient(colors),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppEffects.glow(colors.glow),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.attach_money, color: Colors.white),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Monthly Summary',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 12,
                  ),
                ),
                Text(
                  "You're spending ${CurrencyFormatter.format(thisMonthTotal)} this month",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                if (pctChange != null) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        isHigher ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 12,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${pctChange.abs().toStringAsFixed(0)}% ${isHigher ? 'higher' : 'lower'} than last month',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
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
    );
  }
}
