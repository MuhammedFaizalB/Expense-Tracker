import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/core/theme/theme_extensions.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:expense_tracker/features/dashboard/presentation/widgets/dashboard_hero_heade.dart';
import 'package:expense_tracker/features/dashboard/presentation/widgets/spending_overview_card.dart';
import 'package:expense_tracker/features/dashboard/presentation/widgets/spending_trend_card.dart';
import 'package:expense_tracker/features/transactions/presentation/bloc/transaction_bloc.dart';
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
    context.read<TransactionBloc>().add(const TransactionLoadRequested());
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          final allTransactions = context
              .watch<TransactionBloc>()
              .state
              .transactions;
          final categoriesById = {
            for (final c in context.watch<CategoryBloc>().state.categories)
              c.id: c,
          };

          return RefreshIndicator(
            onRefresh: () async => context.read<DashboardBloc>().add(
              const DashboardLoadRequested(),
            ),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: DashboardHeroHeader(
                    greeting: _greeting,
                    balance: summary.balance,
                    income: summary.totalIncome,
                    expense: summary.totalExpense,
                    onWalletTap: () => context.go('/transactions'),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.xl,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      SpendingOverviewCard(
                        transactions: allTransactions,
                        categories: context
                            .watch<CategoryBloc>()
                            .state
                            .categories,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SpendingTrendCard(transactions: allTransactions),
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
                            onTap: () => context.push('/transactions/${t.id}'),
                          ),
                        ),
                    ]),
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
