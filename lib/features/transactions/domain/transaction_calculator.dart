import 'package:expense_tracker/features/transactions/domain/entities/transaction_entity.dart';

class TransactionTotals {
  final double income;
  final double expense;
  const TransactionTotals({required this.income, required this.expense});

  double get net => income - expense;
}

class TransactionCalculator {
  const TransactionCalculator._();

  static TransactionTotals totals(Iterable<TransactionEntity> transactions) {
    var income = 0.0;
    var expense = 0.0;
    for (final t in transactions) {
      if (t.type == TransactionType.income) {
        income += t.amount;
      } else {
        expense += t.amount;
      }
    }
    return TransactionTotals(income: income, expense: expense);
  }

  static Map<String, double> expenseByCategory(
    Iterable<TransactionEntity> transactions,
  ) {
    final out = <String, double>{};
    for (final t in transactions.where(
      (t) => t.type == TransactionType.expense,
    )) {
      out.update(t.categoryId, (v) => v + t.amount, ifAbsent: () => t.amount);
    }
    return out;
  }
}
