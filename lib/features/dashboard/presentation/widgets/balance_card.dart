import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/core/theme/theme_extensions.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:flutter/material.dart';

class BalanceCard extends StatelessWidget {
  final double balance;
  const BalanceCard({super.key, required this.balance});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: context.colors.primary,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Balance',
              style: TextStyle(
                color: context.colors.onPrimary.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              CurrencyFormatter.format(balance),
              style: TextStyle(
                color: context.colors.onPrimary,
                fontSize: 30,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class IncomeExpenseCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final IconData icon;
  const IncomeExpenseCard({
    super.key,
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(label, style: context.textStyles.bodyMedium),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              CurrencyFormatter.format(amount),
              style: context.textStyles.titleMedium?.copyWith(
                color: color,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
