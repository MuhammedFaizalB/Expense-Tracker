import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/core/theme/theme_extensions.dart';
import 'package:expense_tracker/core/widgets/modern_ui.dart';
import 'package:expense_tracker/features/categories/domain/entities/category_entity.dart';
import 'package:expense_tracker/features/categories/presentation/widgets/category_icons.dart';
import 'package:flutter/material.dart';

class CategoryPick {
  final String? id;
  const CategoryPick(this.id);
}

Future<CategoryPick?> showCategoryPickerSheet(
  BuildContext context, {
  required List<CategoryEntity> categories,
  String? selectedId,
  bool allowAll = false,
  String title = 'Select category',
}) {
  return showModernSheet<CategoryPick>(
    context,
    builder: (_) => _CategoryPickerSheet(
      categories: categories,
      selectedId: selectedId,
      allowAll: allowAll,
      title: title,
    ),
  );
}

class _CategoryPickerSheet extends StatefulWidget {
  final List<CategoryEntity> categories;
  final String? selectedId;
  final bool allowAll;
  final String title;
  const _CategoryPickerSheet({
    required this.categories,
    required this.selectedId,
    required this.allowAll,
    required this.title,
  });

  @override
  State<_CategoryPickerSheet> createState() => _CategoryPickerSheetState();
}

class _CategoryPickerSheetState extends State<_CategoryPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final q = _query.trim().toLowerCase();
    final visible = widget.categories
        .where((c) => q.isEmpty || c.name.toLowerCase().contains(q))
        .toList();
    final height = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: height * 0.78),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SheetHandle(),
            SheetHeader(title: widget.title),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                decoration: const InputDecoration(
                  hintText: 'Search categories',
                  prefixIcon: Icon(Icons.search_rounded),
                  isDense: true,
                ),
              ),
            ),
            if (widget.allowAll)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: PillOption(
                    label: 'All categories',
                    icon: Icons.apps_rounded,
                    selected: widget.selectedId == null,
                    onTap: () =>
                        Navigator.of(context).pop(const CategoryPick(null)),
                  ),
                ),
              ),
            Flexible(
              child: visible.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Center(
                        child: Text(
                          'No categories found',
                          style: context.textStyles.bodyMedium,
                        ),
                      ),
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.xs,
                        AppSpacing.lg,
                        AppSpacing.lg,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 1.0,
                          ),
                      itemCount: visible.length,
                      itemBuilder: (context, i) {
                        final c = visible[i];
                        final color = Color(c.color);
                        final selected = c.id == widget.selectedId;
                        return InkWell(
                          onTap: () =>
                              Navigator.of(context).pop(CategoryPick(c.id)),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: selected
                                  ? color.withValues(alpha: 0.12)
                                  : colors.surfaceVariant,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              border: Border.all(
                                color: selected ? color : Colors.transparent,
                                width: 1.4,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TintedIcon(
                                  icon: resolveCategoryIcon(c.icon),
                                  color: color,
                                  size: 40,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  c.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: selected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: colors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryPickerField extends StatelessWidget {
  final List<CategoryEntity> categories;
  final String? selectedId;
  final ValueChanged<String> onChanged;
  final String? errorText;
  final String label;

  const CategoryPickerField({
    super.key,
    required this.categories,
    required this.selectedId,
    required this.onChanged,
    this.errorText,
    this.label = 'Category',
  });

  @override
  Widget build(BuildContext context) {
    CategoryEntity? selected;
    for (final c in categories) {
      if (c.id == selectedId) selected = c;
    }

    return PickerField(
      label: label,
      value: selected?.name,
      placeholder: 'Choose a category',
      errorText: errorText,
      leading: selected == null
          ? Icon(Icons.category_outlined, color: context.colors.textSecondary)
          : TintedIcon(
              icon: resolveCategoryIcon(selected.icon),
              color: Color(selected.color),
              size: 34,
            ),
      onTap: () async {
        final pick = await showCategoryPickerSheet(
          context,
          categories: categories,
          selectedId: selectedId,
        );
        if (pick?.id != null) onChanged(pick!.id!);
      },
    );
  }
}
