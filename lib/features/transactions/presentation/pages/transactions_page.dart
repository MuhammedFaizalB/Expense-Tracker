import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:expense_tracker/features/transactions/presentation/widgets/transaction_filter_sheet.dart';
import 'package:expense_tracker/features/transactions/presentation/widgets/transaction_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<TransactionBloc>().add(const TransactionLoadRequested());
  }

  void _applySearch(String value) {
    final bloc = context.read<TransactionBloc>();
    bloc.add(
      TransactionFilterChanged(
        bloc.state.filter.copyWith(
          searchQuery: value,
          clearSearch: value.trim().isEmpty,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => const TransactionFilterSheet(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/transactions/add'),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              0,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _applySearch,
              decoration: const InputDecoration(
                hintText: 'Search transactions',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<TransactionBloc, TransactionState>(
              builder: (context, state) {
                if (state.status == TransactionStatusUi.loading ||
                    state.status == TransactionStatusUi.initial) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.status == TransactionStatusUi.failure) {
                  return _ErrorState(
                    message: state.errorMessage ?? 'Something went wrong.',
                    onRetry: () => context.read<TransactionBloc>().add(
                      const TransactionLoadRequested(),
                    ),
                  );
                }
                if (state.transactions.isEmpty) {
                  return _EmptyState(
                    onAdd: () => context.push('/transactions/add'),
                  );
                }
                return BlocBuilder<CategoryBloc, CategoryState>(
                  builder: (context, catState) {
                    final categoriesById = {
                      for (final c in catState.categories) c.id: c,
                    };
                    return RefreshIndicator(
                      onRefresh: () async => context
                          .read<TransactionBloc>()
                          .add(const TransactionLoadRequested()),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        itemCount: state.transactions.length,
                        itemBuilder: (context, i) {
                          final t = state.transactions[i];
                          return TransactionListTile(
                            transaction: t,
                            category: categoriesById[t.categoryId],
                            onTap: () => context.push('/transactions/${t.id}'),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: Theme.of(context).disabledColor,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No transactions yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Start tracking your money by adding your first transaction.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: onAdd,
              child: const Text('Add Transaction'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Something went wrong.'),
          Text(message, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
