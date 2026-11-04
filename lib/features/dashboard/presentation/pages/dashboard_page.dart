import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/core/theme/theme_extensions.dart';
import 'package:expense_tracker/core/utils/period.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:expense_tracker/features/dashboard/presentation/widgets/dashboard_hero_heade.dart';
import 'package:expense_tracker/features/dashboard/presentation/widgets/month_picker_sheet.dart';
import 'package:expense_tracker/features/dashboard/presentation/widgets/spending_overview_card.dart';
import 'package:expense_tracker/features/dashboard/presentation/widgets/spending_trend_card.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction_filter.dart';
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
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  String _monthLabel(DateTime month) =>
      Period.describe(month, DateTime(month.year, month.month + 1, 0));

  Future<void> _pickMonth(DateTime selected) async {
    final picked = await showMonthPickerSheet(context, selected: selected);
    if (picked != null && mounted) {
      context.read<DashboardBloc>().add(DashboardLoadRequested(month: picked));
    }
  }

  void _seeAll(DateTime month) {
    context.read<TransactionBloc>().add(
      TransactionFilterChanged(TransactionFilter.forMonth(month)),
    );
    context.go('/transactions');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          final hasData = state.summary.trend.isNotEmpty;
          if (state.status == DashboardStatusUi.initial ||
              (state.status == DashboardStatusUi.loading && !hasData)) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == DashboardStatusUi.failure && !hasData) {
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
          final categories = context.watch<CategoryBloc>().state.categories;
          final categoriesById = {for (final c in categories) c.id: c};
          final monthLabel = _monthLabel(state.selectedMonth);

          return RefreshIndicator(
            onRefresh: () async => context.read<DashboardBloc>().add(
              const DashboardLoadRequested(),
            ),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: DashboardHeroHeader(
                    greeting: _greeting,
                    monthLabel: monthLabel,
                    balance: summary.balance,
                    income: summary.totalIncome,
                    expense: summary.totalExpense,
                    onMonthTap: () => _pickMonth(state.selectedMonth),
                    onWalletTap: () => _seeAll(state.selectedMonth),
                  ),
                ),
                if (state.status == DashboardStatusUi.loading)
                  const SliverToBoxAdapter(
                    child: LinearProgressIndicator(minHeight: 2),
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
                        transactions: summary.monthTransactions,
                        categories: categories,
                        monthLabel: monthLabel,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SpendingTrendCard(
                        data: summary.trend,
                        selectedMonth: summary.month,
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
                            onPressed: () => _seeAll(state.selectedMonth),
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
                            'No transactions in $monthLabel',
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
