import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/core/theme/theme_extensions.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/features/categories/domain/entities/category_entity.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction_entity.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class _CategorySlice {
  final String name;
  final double amount;
  final Color color;
  const _CategorySlice({
    required this.name,
    required this.amount,
    required this.color,
  });
}

class SpendingOverviewCard extends StatelessWidget {
  final List<TransactionEntity> transactions;
  final List<CategoryEntity> categories;

  const SpendingOverviewCard({
    super.key,
    required this.transactions,
    required this.categories,
  });

  static const _fallbackPalette = [
    Color(0xFF22C55E),
    Color(0xFF3B82F6),
    Color(0xFF8B5CF6),
    Color(0xFFF59E0B),
    Color(0xFFE0435C),
    Color(0xFF06B6D4),
  ];

  List<_CategorySlice> _computeSlices() {
    final categoriesById = {for (final c in categories) c.id: c};
    final totals = <String, double>{};
    for (final t in transactions.where(
      (t) => t.type == TransactionType.expense,
    )) {
      totals.update(
        t.categoryId,
        (v) => v + t.amount,
        ifAbsent: () => t.amount,
      );
    }
    final entries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = entries.take(5).toList();

    return List.generate(top.length, (i) {
      final category = categoriesById[top[i].key];
      return _CategorySlice(
        name: category?.name ?? 'Other',
        amount: top[i].value,
        color: category != null
            ? Color(category.color)
            : _fallbackPalette[i % _fallbackPalette.length],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final slices = _computeSlices();
    final total = slices.fold(0.0, (sum, s) => sum + s.amount);

    if (slices.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Center(
            child: Text(
              'No expenses yet this month',
              style: context.textStyles.bodyMedium,
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Spending Overview',
                  style: context.textStyles.titleMedium,
                ),
                Row(
                  children: [
                    Text('This Month', style: context.textStyles.bodyMedium),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 16,
                      color: context.colors.textSecondary,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                SizedBox(
                  height: 130,
                  width: 130,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sections: slices
                              .map(
                                (s) => PieChartSectionData(
                                  value: s.amount,
                                  color: s.color,
                                  radius: 18,
                                  showTitle: false,
                                ),
                              )
                              .toList(),
                          sectionsSpace: 2,
                          centerSpaceRadius: 42,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            CurrencyFormatter.formatPlain(total),
                            style: context.textStyles.titleMedium?.copyWith(
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Total Spent',
                            style: context.textStyles.bodyMedium?.copyWith(
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: slices.map((s) {
                      final pct = total == 0
                          ? 0
                          : (s.amount / total * 100).round();
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: s.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                s.name,
                                style: context.textStyles.bodyMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '$pct%  ',
                              style: context.textStyles.bodyMedium,
                            ),
                            Text(
                              CurrencyFormatter.formatPlain(s.amount),
                              style: context.textStyles.bodyMedium?.copyWith(
                                color: context.colors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
