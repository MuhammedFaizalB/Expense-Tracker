import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/core/theme/theme_extensions.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/core/utils/date_formatter.dart';
import 'package:expense_tracker/features/categories/domain/entities/category_entity.dart';
import 'package:expense_tracker/features/categories/presentation/widgets/category_icons.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction_entity.dart';
import 'package:flutter/material.dart';

class TransactionListTile extends StatelessWidget {
  final TransactionEntity transaction;
  final CategoryEntity? category;
  final VoidCallback onTap;

  const TransactionListTile({
    super.key,
    required this.transaction,
    required this.onTap,
    this.category,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final amountColor = isIncome
        ? context.colors.income
        : context.colors.expense;
    final iconColor = category != null ? Color(category!.color) : amountColor;
    final icon = category != null
        ? resolveCategoryIcon(category!.icon)
        : (isIncome ? Icons.arrow_downward : Icons.arrow_upward);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: iconColor.withValues(alpha: 0.14),

          child: Icon(icon, color: iconColor, size: 18),
        ),
        title: Text(
          transaction.title,
          style: context.textStyles.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${category?.name ?? 'Uncategorized'} · ${DateFormatter.dayMonth(transaction.transactionDate)}',
        ),
        trailing: Text(
          '${isIncome ? '+' : '-'}${CurrencyFormatter.format(transaction.amount)}',
          style: context.textStyles.titleMedium?.copyWith(
            color: amountColor,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
