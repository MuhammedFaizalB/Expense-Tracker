import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction_entity.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction_filter.dart';
import 'package:expense_tracker/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TransactionFilterSheet extends StatefulWidget {
  const TransactionFilterSheet({super.key});

  @override
  State<TransactionFilterSheet> createState() => _TransactionFilterSheetState();
}

class _TransactionFilterSheetState extends State<TransactionFilterSheet> {
  late TransactionFilter _draft = context.read<TransactionBloc>().state.filter;

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoryBloc>().state.categories;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Filter & Sort', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: _draft.type == null,
                onSelected: (_) =>
                    setState(() => _draft = _draft.copyWith(clearType: true)),
              ),
              ChoiceChip(
                label: const Text('Income'),
                selected: _draft.type == TransactionType.income,
                onSelected: (_) => setState(
                  () => _draft = _draft.copyWith(type: TransactionType.income),
                ),
              ),
              ChoiceChip(
                label: const Text('Expense'),
                selected: _draft.type == TransactionType.expense,
                onSelected: (_) => setState(
                  () => _draft = _draft.copyWith(type: TransactionType.expense),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<String?>(
            initialValue: _draft.categoryId,
            decoration: const InputDecoration(labelText: 'Category'),
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text('All categories'),
              ),
              ...categories.map(
                (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
              ),
            ],
            onChanged: (v) => setState(
              () => _draft = _draft.copyWith(
                categoryId: v,
                clearCategory: v == null,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<TransactionSort>(
            initialValue: _draft.sort,
            decoration: const InputDecoration(labelText: 'Sort by'),
            items: const [
              DropdownMenuItem(
                value: TransactionSort.dateDesc,
                child: Text('Date (newest first)'),
              ),
              DropdownMenuItem(
                value: TransactionSort.dateAsc,
                child: Text('Date (oldest first)'),
              ),
              DropdownMenuItem(
                value: TransactionSort.amountDesc,
                child: Text('Amount (high to low)'),
              ),
              DropdownMenuItem(
                value: TransactionSort.amountAsc,
                child: Text('Amount (low to high)'),
              ),
            ],
            onChanged: (v) => setState(() => _draft = _draft.copyWith(sort: v)),
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton(
            onPressed: () {
              context.read<TransactionBloc>().add(
                TransactionFilterChanged(_draft),
              );
              Navigator.of(context).pop();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}
