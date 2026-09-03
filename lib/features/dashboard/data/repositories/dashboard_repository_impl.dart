import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:expense_tracker/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:expense_tracker/features/lending/domain/lending_calculator.dart';
import 'package:expense_tracker/features/lending/domain/repositories/lending_repository.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction_filter.dart';
import 'package:expense_tracker/features/transactions/domain/repositories/transaction_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final TransactionRepository transactionRepository;
  final LendingRepository lendingRepository;

  const DashboardRepositoryImpl({
    required this.transactionRepository,
    required this.lendingRepository,
  });

  @override
  Future<Either<Failure, DashboardSummary>> getDashboardSummary() async {
    final totalsResult = await transactionRepository.getTotals();
    final recentTxResult = await transactionRepository.getTransactions(
      const TransactionFilter(sort: TransactionSort.dateDesc),
    );
    final lendingResult = await lendingRepository.getLendings();

    final failure =
        totalsResult.fold((f) => f, (_) => null) ??
        recentTxResult.fold((f) => f, (_) => null) ??
        lendingResult.fold((f) => f, (_) => null);
    if (failure != null) return Left(failure);

    final totals = totalsResult.getOrElse(() => (income: 0.0, expense: 0.0));
    final recentTx = recentTxResult.getOrElse(() => []).take(5).toList();
    final lending = lendingResult.getOrElse(() => []);

    return Right(
      DashboardSummary(
        totalIncome: totals.income,
        totalExpense: totals.expense,
        toReceive: LendingCalculator.totalToReceive(lending),
        toPay: LendingCalculator.totalToPay(lending),
        recentTransactions: recentTx,
        recentLending: lending.take(3).toList(),
      ),
    );
  }
}
