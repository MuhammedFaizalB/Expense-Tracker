import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/core/theme/theme_extensions.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction_entity.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SpendingTrendCard extends StatelessWidget {
  final List<TransactionEntity> transactions;
  const SpendingTrendCard({super.key, required this.transactions});

  List<({String label, double total})> _computeMonthlyTotals() {
    final now = DateTime.now();
    final months = List.generate(
      6,
      (i) => DateTime(now.year, now.month - (5 - i), 1),
    );

    return months.map((month) {
      final total = transactions
          .where(
            (t) =>
                t.type == TransactionType.expense &&
                t.transactionDate.year == month.year &&
                t.transactionDate.month == month.month,
          )
          .fold(0.0, (sum, t) => sum + t.amount);
      return (label: DateFormat('MMM').format(month), total: total);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final data = _computeMonthlyTotals();
    final maxValue = data
        .map((d) => d.total)
        .fold(0.0, (a, b) => a > b ? a : b);
    final chartMax = maxValue <= 0 ? 100.0 : maxValue * 1.2;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Spending Trend', style: context.textStyles.titleMedium),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 140,
              child: BarChart(
                BarChartData(
                  maxY: chartMax,
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final i = value.toInt();
                          if (i < 0 || i >= data.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              data[i].label,
                              style: context.textStyles.bodyMedium?.copyWith(
                                fontSize: 11,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: List.generate(data.length, (i) {
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: data[i].total,
                          color: context.colors.primary,
                          width: 18,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
