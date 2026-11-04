import 'package:expense_tracker/core/theme/app_section_header.dart';
import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/core/theme/theme_extensions.dart';
import 'package:expense_tracker/core/utils/period.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction_entity.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction_filter.dart';
import 'package:expense_tracker/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:expense_tracker/features/transactions/presentation/export/export_transactions_action.dart';
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  void _shiftMonth(TransactionFilter filter, int delta) {
    final start = filter.startDate!;
    final target = DateTime(start.year, start.month + delta, 1);
    context.read<TransactionBloc>().add(
      TransactionFilterChanged(
        filter.copyWith(
          startDate: target,
          endDate: DateTime(target.year, target.month + 1, 0),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filter = context.watch<TransactionBloc>().state.filter;
    final activeType = filter.type;
    final periodLabel = Period.describe(filter.startDate, filter.endDate);
    final isMonth = Period.isWholeMonth(filter.startDate, filter.endDate);
    final now = DateTime.now();
    final canGoNext =
        isMonth &&
        (filter.startDate!.year < now.year ||
            (filter.startDate!.year == now.year &&
                filter.startDate!.month < now.month));

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () => context.push('/transactions/add'),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          AppSectionHeader(
            title: 'Transactions',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppHeaderIconButton(
                  icon: Icons.picture_as_pdf_outlined,
                  onTap: () => exportTransactionsPdf(context),
                ),
                const SizedBox(width: AppSpacing.sm),
                AppHeaderIconButton(
                  icon: Icons.tune,
                  onTap: () => showTransactionFilterSheet(context),
                ),
              ],
            ),
            child: AppHeaderPillTabs(
              labels: const ['All', 'Income', 'Expenses'],
              selectedIndex: activeType == null
                  ? 0
                  : (activeType == TransactionType.income ? 1 : 2),
              onChanged: (i) => _setTypeFilter(
                i == 0
                    ? null
                    : (i == 1
                          ? TransactionType.income
                          : TransactionType.expense),
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
              onChanged: (v) {
                _applySearch(v);
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: 'Search transactions',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _applySearch('');
                          setState(() {});
                        },
                      ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.sm,
              AppSpacing.sm,
              AppSpacing.sm,
              0,
            ),
            child: Row(
              children: [
                if (isMonth)
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded),
                    onPressed: () => _shiftMonth(filter, -1),
                  )
                else
                  const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Center(
                    child: InkWell(
                      onTap: () => showTransactionFilterSheet(context),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: context.colors.surfaceVariant,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 15,
                              color: context.colors.primary,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                periodLabel,
                                overflow: TextOverflow.ellipsis,
                                style: context.textStyles.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 18,
                              color: context.colors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (isMonth)
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded),
                    onPressed: canGoNext ? () => _shiftMonth(filter, 1) : null,
                  )
                else
                  const SizedBox(width: AppSpacing.sm),
              ],
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
                    periodLabel: periodLabel,
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
                          MonthlySummaryCard(
                            transactions: state.transactions,
                            periodLabel: periodLabel,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          ...state.transactions.map(
                            (t) => TransactionListTile(
                              transaction: t,
                              category: categoriesById[t.categoryId],
                              onTap: () =>
                                  context.push('/transactions/${t.id}'),
                            ),
                          ),
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

class _EmptyState extends StatelessWidget {
  final String periodLabel;
  final VoidCallback onAdd;
  const _EmptyState({required this.periodLabel, required this.onAdd});

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
              'No transactions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Nothing found for $periodLabel. Add one, or pick another period.',
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
