import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/core/theme/theme_extensions.dart';
import 'package:expense_tracker/core/utils/date_formatter.dart';
import 'package:expense_tracker/core/widgets/modern_ui.dart';
import 'package:expense_tracker/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/categories/domain/entities/category_entity.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/categories/presentation/widgets/category_picker.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction_entity.dart';
import 'package:expense_tracker/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

class TransactionFormPage extends StatefulWidget {
  final TransactionEntity? existing;
  const TransactionFormPage({super.key, this.existing});

  @override
  State<TransactionFormPage> createState() => _TransactionFormPageState();
}

class _TransactionFormPageState extends State<TransactionFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final _amountController = TextEditingController(
    text: widget.existing?.amount.toStringAsFixed(2),
  );
  late final _titleController = TextEditingController(
    text: widget.existing?.title,
  );
  late final _descController = TextEditingController(
    text: widget.existing?.description,
  );
  late TransactionType _type = widget.existing?.type ?? TransactionType.expense;
  String? _categoryId;
  bool _categoryError = false;
  late DateTime _date = _clampToToday(
    widget.existing?.transactionDate ?? DateTime.now(),
  );

  bool _submitting = false;
  int _baselineActionId = 0;

  static DateTime _today() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  static DateTime _clampToToday(DateTime d) {
    final day = DateTime(d.year, d.month, d.day);
    return day.isAfter(_today()) ? _today() : day;
  }

  @override
  void initState() {
    super.initState();
    _categoryId = widget.existing?.categoryId;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: _today(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  String _dateLabel() {
    final today = _today();
    if (_date == today) return 'Today, ${DateFormatter.display(_date)}';
    if (_date == today.subtract(const Duration(days: 1))) {
      return 'Yesterday, ${DateFormatter.display(_date)}';
    }
    return DateFormatter.display(_date);
  }

  void _submit() {
    final formOk = _formKey.currentState!.validate();
    if (_categoryId == null) setState(() => _categoryError = true);
    if (!formOk || _categoryId == null) return;

    if (_date.isAfter(_today())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Date can’t be in the future.')),
      );
      return;
    }

    final userId = context.read<AuthBloc>().state.user?.id ?? '';
    final now = DateTime.now();

    final entity = TransactionEntity(
      id: widget.existing?.id ?? const Uuid().v4(),
      userId: userId,
      type: _type,
      amount: double.parse(_amountController.text),
      categoryId: _categoryId!,
      title: _titleController.text.trim(),
      description: _descController.text.trim().isEmpty
          ? null
          : _descController.text.trim(),
      transactionDate: _date,
      createdAt: widget.existing?.createdAt ?? now,
      updatedAt: now,
    );

    setState(() {
      _submitting = true;
      _baselineActionId = context.read<TransactionBloc>().state.actionId;
    });

    if (widget.existing != null) {
      context.read<TransactionBloc>().add(TransactionUpdated(entity));
    } else {
      context.read<TransactionBloc>().add(TransactionAdded(entity));
    }
  }

  Widget _typeToggle(BuildContext context) {
    final colors = context.colors;
    Widget option(
      TransactionType type,
      String label,
      IconData icon,
      Color tone,
    ) {
      final selected = _type == type;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() {
            _type = type;
            _categoryId = null;
            _categoryError = false;
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 12),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: selected ? tone : colors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: selected ? tone : colors.textSecondary,
                  ),
                ),
              ],
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
          option(
            TransactionType.expense,
            'Expense',
            Icons.north_east_rounded,
            colors.expense,
          ),
          option(
            TransactionType.income,
            'Income',
            Icons.south_west_rounded,
            colors.income,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<CategoryEntity> categories = context
        .watch<CategoryBloc>()
        .state
        .categories
        .where(
          (c) =>
              c.type ==
              (_type == TransactionType.income
                  ? CategoryType.income
                  : CategoryType.expense),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existing != null ? 'Edit Transaction' : 'Add Transaction',
        ),
      ),
      body: BlocListener<TransactionBloc, TransactionState>(
        listener: (context, state) {
          if (!_submitting) return;
          if (state.actionId > _baselineActionId) {
            Navigator.of(context).pop();
          } else if (state.errorMessage != null) {
            setState(() => _submitting = false);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _typeToggle(context),
                  const SizedBox(height: AppSpacing.lg),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textAlign: TextAlign.center,
                    style: context.textStyles.headlineSmall?.copyWith(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                    ),
                    decoration: const InputDecoration(
                      hintText: '0.00',
                      prefixText: '₹ ',
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: AppSpacing.md,
                      ),
                    ),
                    validator: (v) {
                      final n = double.tryParse(v ?? '');
                      if (n == null || n <= 0) {
                        return 'Enter an amount greater than zero';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _titleController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Enter a title'
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  CategoryPickerField(
                    categories: categories,
                    selectedId: _categoryId,
                    errorText: _categoryError ? 'Select a category' : null,
                    onChanged: (id) => setState(() {
                      _categoryId = id;
                      _categoryError = false;
                    }),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  PickerField(
                    label: 'Date',
                    value: _dateLabel(),
                    leading: Icon(
                      Icons.calendar_today_outlined,
                      color: context.colors.textSecondary,
                    ),
                    trailingIcon: Icons.edit_calendar_outlined,
                    onTap: _pickDate,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _descController,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ElevatedButton(
                    onPressed: _submitting ? null : _submit,
                    child: _submitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Save Transaction'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
