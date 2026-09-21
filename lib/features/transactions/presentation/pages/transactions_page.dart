import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/core/theme/theme_extensions.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction_entity.dart';
import 'package:expense_tracker/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:expense_tracker/features/transactions/presentation/widgets/monthly_summary_card.dart';
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

  void _setTypeFilter(TransactionType? type) {
    final bloc = context.read<TransactionBloc>();
    bloc.add(
      TransactionFilterChanged(
        bloc.state.filter.copyWith(type: type, clearType: type == null),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeType = context.watch<TransactionBloc>().state.filter.type;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/transactions/add'),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: context.colors.heroHeader,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(AppRadius.xl),
                bottomRight: Radius.circular(AppRadius.xl),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Transactions',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.tune, color: Colors.white),
                        onPressed: () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (_) => const TransactionFilterSheet(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Row(
                      children: [
                        _PillTab(
                          label: 'All',
                          selected: activeType == null,
                          onTap: () => _setTypeFilter(null),
                        ),
                        _PillTab(
                          label: 'Income',
                          selected: activeType == TransactionType.income,
                          onTap: () => _setTypeFilter(TransactionType.income),
                        ),
                        _PillTab(
                          label: 'Expenses',
                          selected: activeType == TransactionType.expense,
                          onTap: () => _setTypeFilter(TransactionType.expense),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
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
                      child: ListView(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        children: [
                          ...state.transactions.map(
                            (t) => TransactionListTile(
                              transaction: t,
                              category: categoriesById[t.categoryId],
                              onTap: () =>
                                  context.push('/transactions/${t.id}'),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          MonthlySummaryCard(transactions: state.transactions),
                        ],
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

class _PillTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _PillTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? context.colors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: selected
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.6),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
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
