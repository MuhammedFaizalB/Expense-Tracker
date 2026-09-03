import 'package:equatable/equatable.dart';
import 'package:expense_tracker/features/dashboard/domain/dashboard_calculator.dart';
import 'package:expense_tracker/features/lending/domain/entities/lending_entity.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction_entity.dart';

class DashboardSummary extends Equatable {
  final double totalIncome;
  final double totalExpense;
  final double toReceive;
  final double toPay;
  final List<TransactionEntity> recentTransactions;
  final List<LendingEntity> recentLending;

  const DashboardSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.toReceive,
    required this.toPay,
    required this.recentTransactions,
    required this.recentLending,
  });

  double get balance => DashboardCalculator.balance(
    totalIncome: totalIncome,
    totalExpense: totalExpense,
  );

  const DashboardSummary.empty()
    : totalIncome = 0,
      totalExpense = 0,
      toReceive = 0,
      toPay = 0,
      recentTransactions = const [],
      recentLending = const [];

  @override
  List<Object?> get props => [
    totalIncome,
    totalExpense,
    toReceive,
    toPay,
    recentTransactions,
    recentLending,
  ];
}
