class DashboardCalculator {
  const DashboardCalculator._();

  static double balance({
    required double totalIncome,
    required double totalExpense,
  }) {
    return totalIncome - totalExpense;
  }
}
