import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/core/theme/theme_extensions.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:flutter/material.dart';

class LendingSummaryCard extends StatelessWidget {
  final double toReceive;
  final double toPay;

  const LendingSummaryCard({
    super.key,
    required this.toReceive,
    required this.toPay,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _tile(
            context,
            'You will receive',
            toReceive,
            context.colors.income,
            Icons.call_received,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _tile(
            context,
            'You need to pay',
            toPay,
            context.colors.expense,
            Icons.call_made,
          ),
        ),
      ],
    );
  }

  Widget _tile(
    BuildContext context,
    String label,
    double amount,
    Color color,
    IconData icon,
  ) {
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
