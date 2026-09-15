import 'package:collection/collection.dart';
import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/core/theme/theme_extensions.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/core/utils/date_formatter.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction_entity.dart';
import 'package:expense_tracker/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:expense_tracker/features/transactions/presentation/pages/transaction_form_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class TransactionDetailPage extends StatelessWidget {
  final String transactionId;
  const TransactionDetailPage({super.key, required this.transactionId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      buildWhen: (prev, curr) => prev.transactions != curr.transactions,
      builder: (context, state) {
        final transaction = state.transactions.firstWhereOrNull(
          (t) => t.id == transactionId,
        );

        if (transaction == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Transaction')),
            body: const Center(
              child: Text('This transaction is no longer available.'),
            ),
          );
        }

        final isIncome = transaction.type == TransactionType.income;
        final color = isIncome ? context.colors.income : context.colors.expense;
        final category = context
            .watch<CategoryBloc>()
            .state
            .categories
            .where((c) => c.id == transaction.categoryId)
            .firstOrNull;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Transaction'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => TransactionFormPage(existing: transaction),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete transaction?'),
                      content: const Text('This cannot be undone.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true && context.mounted) {
                    context.read<TransactionBloc>().add(
                      TransactionDeleted(transaction.id),
                    );
                    context.pop();
                  }
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: context.textStyles.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${isIncome ? '+' : '-'}${CurrencyFormatter.format(transaction.amount)}',
                  style: context.textStyles.headlineSmall?.copyWith(
                    color: color,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _row(context, 'Type', isIncome ? 'Income' : 'Expense'),
                _row(context, 'Category', category?.name ?? 'Uncategorized'),
                _row(
                  context,
                  'Date',
                  DateFormatter.display(transaction.transactionDate),
                ),
                if (transaction.description != null)
                  _row(context, 'Description', transaction.description!),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: context.textStyles.bodyMedium),
          Flexible(child: Text(value, textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}
