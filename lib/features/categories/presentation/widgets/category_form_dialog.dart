import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/core/theme/theme_extensions.dart';
import 'package:expense_tracker/features/categories/domain/entities/category_entity.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/categories/presentation/widgets/category_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const _paletteColors = <int>[
  0xFF22C55E,
  0xFF3B82F6,
  0xFF8B5CF6,
  0xFFF59E0B,
  0xFFE0435C,
  0xFF06B6D4,
  0xFFEC4899,
  0xFFF97316,
  0xFF14B8A6,
  0xFF6366F1,
  0xFF84CC16,
  0xFF64748B,
];

class CategoryFormDialog extends StatefulWidget {
  final CategoryEntity? existing;
  final CategoryType? initialType;
  const CategoryFormDialog({super.key, this.existing, this.initialType});

  @override
  State<CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<CategoryFormDialog> {
  late final _nameController = TextEditingController(
    text: widget.existing?.name,
  );
  late CategoryType _type =
      widget.existing?.type ?? widget.initialType ?? CategoryType.expense;
  late String _icon = widget.existing?.icon ?? categoryIconMap.keys.first;
  late int _color = widget.existing?.color ?? _paletteColors.first;
  String? _nameError;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  List<int> get _swatches {
    return _paletteColors.contains(_color)
        ? _paletteColors
        : [_color, ..._paletteColors];
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = 'Give the category a name');
      return;
    }
    final bloc = context.read<CategoryBloc>();
    if (widget.existing != null) {
      bloc.add(
        CategoryUpdated(
          widget.existing!.copyWith(
            name: name,
            type: _type,
            icon: _icon,
            color: _color,
          ),
        ),
      );
    } else {
      bloc.add(
        CategoryAdded(name: name, type: _type, icon: _icon, color: _color),
      );
    }
    Navigator.of(context).pop();
  }

  Widget _typeToggle(BuildContext context) {
    final colors = context.colors;
    Widget option(CategoryType type, String label, Color tone) {
      final selected = _type == type;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _type = type),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(vertical: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected
                  ? tone.withValues(alpha: 0.14)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(
                color: selected ? tone : Colors.transparent,
                width: 1.3,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: selected ? tone : colors.textSecondary,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        children: [
          option(CategoryType.expense, 'Expense', colors.expense),
          option(CategoryType.income, 'Income', colors.income),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tone = Color(_color);
    final canDelete = widget.existing != null && !widget.existing!.isDefault;

    return Dialog(
      backgroundColor: colors.surface,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 440,
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: tone.withValues(alpha: 0.16),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      resolveCategoryIcon(_icon),
                      color: tone,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.existing != null
                              ? 'Edit category'
                              : 'New category',
                          style: context.textStyles.titleMedium?.copyWith(
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'Pick a name, icon and color',
                          style: context.textStyles.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      onChanged: (_) {
                        if (_nameError != null) {
                          setState(() => _nameError = null);
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'Name',
                        errorText: _nameError,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _typeToggle(context),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'ICON',
                      style: context.textStyles.bodyMedium?.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: categoryIconMap.entries.map((e) {
                        final selected = e.key == _icon;
                        return InkWell(
                          onTap: () => setState(() => _icon = e.key),
                          borderRadius: BorderRadius.circular(14),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 140),
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: selected
                                  ? tone.withValues(alpha: 0.16)
                                  : colors.surfaceVariant,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: selected ? tone : Colors.transparent,
                                width: 1.4,
                              ),
                            ),
                            child: Icon(
                              e.value,
                              size: 21,
                              color: selected ? tone : colors.textSecondary,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'COLOR',
                      style: context.textStyles.bodyMedium?.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _swatches.map((c) {
                        final selected = c == _color;
                        return GestureDetector(
                          onTap: () => setState(() => _color = c),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 140),
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: Color(c),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selected
                                    ? colors.textPrimary
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: selected
                                ? const Icon(
                                    Icons.check_rounded,
                                    size: 18,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
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
              child: Row(
                children: [
                  if (canDelete)
                    IconButton(
                      tooltip: 'Delete category',
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        color: colors.error,
                      ),
                      onPressed: () {
                        context.read<CategoryBloc>().add(
                          CategoryDeleted(widget.existing!.id),
                        );
                        Navigator.of(context).pop();
                      },
                    ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _save,
                      child: Text(
                        widget.existing != null
                            ? 'Save changes'
                            : 'Create category',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
