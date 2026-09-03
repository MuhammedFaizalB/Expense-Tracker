import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/core/theme/theme_extensions.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:expense_tracker/features/dashboard/presentation/widgets/balance_card.dart';
import 'package:expense_tracker/features/lending/presentation/widgets/lending_summary_card.dart';
import 'package:expense_tracker/features/transactions/presentation/widgets/transaction_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(const DashboardLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state.status == DashboardStatusUi.loading ||
              state.status == DashboardStatusUi.initial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == DashboardStatusUi.failure) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.errorMessage ?? 'Something went wrong.'),
                  const SizedBox(height: AppSpacing.md),
                  OutlinedButton(
                    onPressed: () => context.read<DashboardBloc>().add(
                      const DashboardLoadRequested(),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final summary = state.summary;
          final categoriesById = {
            for (final c in context.watch<CategoryBloc>().state.categories)
              c.id: c,
          };

          return RefreshIndicator(
            onRefresh: () async => context.read<DashboardBloc>().add(
              const DashboardLoadRequested(),
            ),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                BalanceCard(balance: summary.balance),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: IncomeExpenseCard(
                        label: 'Total Income',
                        amount: summary.totalIncome,
                        color: context.colors.income,
                        icon: Icons.trending_up,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: IncomeExpenseCard(
                        label: 'Total Expenses',
                        amount: summary.totalExpense,
                        color: context.colors.expense,
                        icon: Icons.trending_down,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                LendingSummaryCard(
                  toReceive: summary.toReceive,
                  toPay: summary.toPay,
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Transactions',
                      style: context.textStyles.titleMedium,
                    ),
                    TextButton(
                      onPressed: () => context.go('/transactions'),
                      child: const Text('See all'),
                    ),
                  ],
                ),
                if (summary.recentTransactions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    child: Text(
                      'No transactions yet',
                      style: context.textStyles.bodyMedium,
                    ),
                  )
                else
                  ...summary.recentTransactions.map(
                    (t) => TransactionListTile(
                      transaction: t,
                      category: categoriesById[t.categoryId],
                      onTap: () =>
                          context.push('/transactions/${t.id}', extra: t),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
