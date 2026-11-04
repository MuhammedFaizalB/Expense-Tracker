import 'package:equatable/equatable.dart';
import 'package:expense_tracker/features/dashboard/domain/dashboard_calculator.dart';
import 'package:expense_tracker/features/lending/domain/entities/lending_entity.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction_entity.dart';

class MonthTotal extends Equatable {
  final DateTime month;
  final double total;
  const MonthTotal({required this.month, required this.total});

  @override
  List<Object?> get props => [month, total];
}

class DashboardSummary extends Equatable {
  final DateTime month;
  final double totalIncome;
  final double totalExpense;
  final double toReceive;
  final double toPay;

  final List<TransactionEntity> monthTransactions;

  final List<MonthTotal> trend;
  final List<LendingEntity> recentLending;

  const DashboardSummary({
    required this.month,
    required this.totalIncome,
    required this.totalExpense,
    required this.toReceive,
    required this.toPay,
    required this.monthTransactions,
    required this.trend,
    required this.recentLending,
  });

  double get balance => DashboardCalculator.balance(
    totalIncome: totalIncome,
    totalExpense: totalExpense,
  );

  List<TransactionEntity> get recentTransactions =>
      monthTransactions.take(5).toList();

  DashboardSummary.empty([DateTime? forMonth])
    : month =
          forMonth ?? DateTime(DateTime.now().year, DateTime.now().month, 1),
      totalIncome = 0,
      totalExpense = 0,
      toReceive = 0,
      toPay = 0,
      monthTransactions = const [],
      trend = const [],
      recentLending = const [];

  @override
  List<Object?> get props => [
    month,
    totalIncome,
    totalExpense,
    toReceive,
    toPay,
    monthTransactions,
    trend,
    recentLending,
  ];
}
