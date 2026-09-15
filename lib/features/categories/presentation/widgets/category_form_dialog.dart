import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/features/categories/domain/entities/category_entity.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/categories/presentation/widgets/category_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const _paletteColors = <int>[
  0xFF1B3A5C,
  0xFF6B7280,
  0xFF1E7B4D,
  0xFFB3261E,
  0xFFB86E00,
  0xFF6D4C9C,
  0xFF3A7CA5,
  0xFF9C4C6D,
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing != null ? 'Edit category' : 'New category'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: AppSpacing.md),
            SegmentedButton<CategoryType>(
              segments: const [
                ButtonSegment(
                  value: CategoryType.expense,
                  label: Text('Expense'),
                ),
                ButtonSegment(
                  value: CategoryType.income,
                  label: Text('Income'),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (s) => setState(() => _type = s.first),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              children: categoryIconMap.entries.map((e) {
                final selected = e.key == _icon;
                return ChoiceChip(
                  label: Icon(e.value, size: 18),
                  selected: selected,
                  onSelected: (_) => setState(() => _icon = e.key),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: _paletteColors.map((c) {
                final selected = c == _color;
                return GestureDetector(
                  onTap: () => setState(() => _color = c),
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: Color(c),
                    child: selected
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        if (widget.existing != null && !widget.existing!.isDefault)
          TextButton(
            onPressed: () {
              context.read<CategoryBloc>().add(
                CategoryDeleted(widget.existing!.id),
              );
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_nameController.text.trim().isEmpty) return;
            if (widget.existing != null) {
              context.read<CategoryBloc>().add(
                CategoryUpdated(
                  widget.existing!.copyWith(
                    name: _nameController.text.trim(),
                    type: _type,
                    icon: _icon,
                    color: _color,
                  ),
                ),
              );
            } else {
              context.read<CategoryBloc>().add(
                CategoryAdded(
                  name: _nameController.text.trim(),
                  type: _type,
                  icon: _icon,
                  color: _color,
                ),
              );
            }
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
