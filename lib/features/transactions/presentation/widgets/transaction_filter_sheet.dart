import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/core/theme/theme_extensions.dart';
import 'package:expense_tracker/core/utils/period.dart';
import 'package:expense_tracker/core/widgets/modern_ui.dart';
import 'package:expense_tracker/features/categories/domain/entities/category_entity.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/categories/presentation/widgets/category_icons.dart';
import 'package:expense_tracker/features/categories/presentation/widgets/category_picker.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction_entity.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction_filter.dart';
import 'package:expense_tracker/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> showTransactionFilterSheet(BuildContext context) {
  return showModernSheet<void>(
    context,
    builder: (_) => const TransactionFilterSheet(),
  );
}

class TransactionFilterSheet extends StatefulWidget {
  const TransactionFilterSheet({super.key});

  @override
  State<TransactionFilterSheet> createState() => _TransactionFilterSheetState();
}

class _TransactionFilterSheetState extends State<TransactionFilterSheet> {
  late TransactionFilter _draft = context.read<TransactionBloc>().state.filter;
  late PeriodPreset _preset = Period.detect(_draft.startDate, _draft.endDate);

  void _setPreset(PeriodPreset p) {
    final range = Period.rangeFor(p);
    setState(() {
      _preset = p;
      _draft = range == null
          ? _draft.copyWith(clearDates: true)
          : _draft.copyWith(startDate: range.start, endDate: range.end);
    });
  }

  Future<void> _pickCustom() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 1, 12, 31),
      initialDateRange: (_draft.startDate != null && _draft.endDate != null)
          ? DateTimeRange(start: _draft.startDate!, end: _draft.endDate!)
          : null,
      helpText: 'Select period',
    );
    if (!mounted || picked == null) return;
    setState(() {
      _preset = PeriodPreset.custom;
      _draft = _draft.copyWith(startDate: picked.start, endDate: picked.end);
    });
  }

  String _sortLabel(TransactionSort s) => switch (s) {
    TransactionSort.dateDesc => 'Newest first',
    TransactionSort.dateAsc => 'Oldest first',
    TransactionSort.amountDesc => 'Highest amount',
    TransactionSort.amountAsc => 'Lowest amount',
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final categories = context.watch<CategoryBloc>().state.categories;
    CategoryEntity? selectedCategory;
    for (final c in categories) {
      if (c.id == _draft.categoryId) selectedCategory = c;
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SheetHandle(),
          SheetHeader(
            title: 'Filters',
            subtitle: Period.describe(_draft.startDate, _draft.endDate),
            actionLabel: 'Reset',
            onAction: () => setState(() {
              _draft = TransactionFilter.currentMonth().copyWith(
                searchQuery: _draft.searchQuery,
              );
              _preset = PeriodPreset.thisMonth;
            }),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SheetSectionLabel('Type'),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      PillOption(
                        label: 'All',
                        selected: _draft.type == null,
                        onTap: () => setState(
                          () => _draft = _draft.copyWith(clearType: true),
                        ),
                      ),
                      PillOption(
                        label: 'Income',
                        icon: Icons.south_west_rounded,
                        accent: colors.income,
                        selected: _draft.type == TransactionType.income,
                        onTap: () => setState(
                          () => _draft = _draft.copyWith(
                            type: TransactionType.income,
                          ),
                        ),
                      ),
                      PillOption(
                        label: 'Expense',
                        icon: Icons.north_east_rounded,
                        accent: colors.expense,
                        selected: _draft.type == TransactionType.expense,
                        onTap: () => setState(
                          () => _draft = _draft.copyWith(
                            type: TransactionType.expense,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const SheetSectionLabel('Period'),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: PeriodPreset.values.map((p) {
                      return PillOption(
                        label: Period.label(p),
                        icon: p == PeriodPreset.custom
                            ? Icons.date_range_rounded
                            : null,
                        selected: _preset == p,
                        onTap: () => p == PeriodPreset.custom
                            ? _pickCustom()
                            : _setPreset(p),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const SheetSectionLabel('Category'),
                  PickerField(
                    label: 'Category',
                    value: selectedCategory?.name ?? 'All categories',
                    leading: selectedCategory == null
                        ? Icon(Icons.apps_rounded, color: colors.textSecondary)
                        : TintedIcon(
                            icon: resolveCategoryIcon(selectedCategory.icon),
                            color: Color(selectedCategory.color),
                            size: 34,
                          ),
                    onTap: () async {
                      final pick = await showCategoryPickerSheet(
                        context,
                        categories: categories,
                        selectedId: _draft.categoryId,
                        allowAll: true,
                        title: 'Filter by category',
                      );
                      if (pick == null) return;
                      setState(
                        () => _draft = _draft.copyWith(
                          categoryId: pick.id,
                          clearCategory: pick.id == null,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const SheetSectionLabel('Sort by'),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: TransactionSort.values.map((s) {
                      return PillOption(
                        label: _sortLabel(s),
                        selected: _draft.sort == s,
                        onTap: () =>
                            setState(() => _draft = _draft.copyWith(sort: s)),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: ElevatedButton(
              onPressed: () {
                context.read<TransactionBloc>().add(
                  TransactionFilterChanged(_draft),
                );
                Navigator.of(context).pop();
              },
              child: const Text('Apply filters'),
            ),
          ),
        ],
      ),
    );
  }
}
