import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:expense_tracker/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:expense_tracker/features/lending/domain/lending_calculator.dart';
import 'package:expense_tracker/features/lending/domain/repositories/lending_repository.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction_entity.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction_filter.dart';
import 'package:expense_tracker/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:expense_tracker/features/transactions/domain/transaction_calculator.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final TransactionRepository transactionRepository;
  final LendingRepository lendingRepository;

  const DashboardRepositoryImpl({
    required this.transactionRepository,
    required this.lendingRepository,
  });

  @override
  Future<Either<Failure, DashboardSummary>> getDashboardSummary(
    DateTime month,
  ) async {
    final selected = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(selected.year, selected.month + 1, 0);
    final windowStart = DateTime(selected.year, selected.month - 5, 1);

    final txResult = await transactionRepository.getTransactions(
      TransactionFilter(
        startDate: windowStart,
        endDate: endOfMonth,
        sort: TransactionSort.dateDesc,
      ),
    );
    final lendingResult = await lendingRepository.getLendings();

    final failure =
        txResult.fold((f) => f, (_) => null) ??
        lendingResult.fold((f) => f, (_) => null);
    if (failure != null) return Left(failure);

    final windowTx = txResult.getOrElse(() => []);
    final lending = lendingResult.getOrElse(() => []);

    bool inMonth(TransactionEntity t, DateTime m) =>
        t.transactionDate.year == m.year && t.transactionDate.month == m.month;

    final monthTx = windowTx.where((t) => inMonth(t, selected)).toList();
    final totals = TransactionCalculator.totals(monthTx);

    final trend = List.generate(6, (i) {
      final m = DateTime(selected.year, selected.month - (5 - i), 1);
      final expense = TransactionCalculator.totals(
        windowTx.where((t) => inMonth(t, m)),
      ).expense;
      return MonthTotal(month: m, total: expense);
    });

    return Right(
      DashboardSummary(
        month: selected,
        totalIncome: totals.income,
        totalExpense: totals.expense,
        toReceive: LendingCalculator.totalToReceive(lending),
        toPay: LendingCalculator.totalToPay(lending),
        monthTransactions: monthTx,
        trend: trend,
        recentLending: lending.take(3).toList(),
      ),
    );
  }
}
