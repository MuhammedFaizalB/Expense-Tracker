import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/core/theme/theme_extensions.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/features/categories/domain/entities/category_entity.dart';
import 'package:expense_tracker/features/categories/presentation/widgets/category_icons.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction_entity.dart';
import 'package:expense_tracker/features/transactions/domain/transaction_calculator.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class _CategorySlice {
  final String name;
  final double amount;
  final Color color;
  final IconData icon;
  const _CategorySlice({
    required this.name,
    required this.amount,
    required this.color,
    required this.icon,
  });
}

class SpendingOverviewCard extends StatelessWidget {
  final List<TransactionEntity> transactions;
  final List<CategoryEntity> categories;
  final String monthLabel;

  const SpendingOverviewCard({
    super.key,
    required this.transactions,
    required this.categories,
    required this.monthLabel,
  });

  static const _fallbackPalette = [
    Color(0xFF22C55E),
    Color(0xFF3B82F6),
    Color(0xFF8B5CF6),
    Color(0xFFF59E0B),
    Color(0xFFE0435C),
    Color(0xFF06B6D4),
  ];

  List<_CategorySlice> _slices() {
    final categoriesById = {for (final c in categories) c.id: c};
    final entries = TransactionCalculator.expenseByCategory(
      transactions,
    ).entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return List.generate(entries.length, (i) {
      final category = categoriesById[entries[i].key];
      return _CategorySlice(
        name: category?.name ?? 'Uncategorised',
        amount: entries[i].value,
        color: category != null
            ? Color(category.color)
            : _fallbackPalette[i % _fallbackPalette.length],
        icon: category != null
            ? resolveCategoryIcon(category.icon)
            : Icons.category_outlined,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final slices = _slices();
    final total = slices.fold(0.0, (sum, s) => sum + s.amount);
    final maxAmount = slices.isEmpty ? 1.0 : slices.first.amount;
    final colors = context.colors;

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
                Text(monthLabel, style: context.textStyles.bodyMedium),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (slices.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: Center(
                  child: Text(
                    'No expenses in $monthLabel',
                    style: context.textStyles.bodyMedium,
                  ),
                ),
              )
            else ...[
              Center(
                child: SizedBox(
                  height: 170,
                  width: 170,
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
                                  radius: 20,
                                  showTitle: false,
                                ),
                              )
                              .toList(),
                          sectionsSpace: 2,
                          centerSpaceRadius: 58,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            CurrencyFormatter.format(total),
                            style: context.textStyles.titleMedium?.copyWith(
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            'Total spent',
                            style: context.textStyles.bodyMedium?.copyWith(
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ...slices.map((s) {
                final pct = total == 0 ? 0 : (s.amount / total * 100).round();
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: s.color.withValues(alpha: 0.14),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(s.icon, size: 16, color: s.color),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              s.name,
                              overflow: TextOverflow.ellipsis,
                              style: context.textStyles.bodyLarge?.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text('$pct%', style: context.textStyles.bodyMedium),
                          const SizedBox(width: 10),
                          Text(
                            CurrencyFormatter.format(s.amount),
                            style: context.textStyles.bodyMedium?.copyWith(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.only(left: 40),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          child: LinearProgressIndicator(
                            value: (s.amount / maxAmount).clamp(0.02, 1.0),
                            minHeight: 5,
                            backgroundColor: colors.surfaceVariant,
                            valueColor: AlwaysStoppedAnimation(s.color),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}
