import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/categories/domain/entities/category_entity.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_bloc.dart';
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
  late DateTime _date = widget.existing?.transactionDate ?? DateTime.now();

  @override
  void initState() {
    super.initState();
    _categoryId = widget.existing?.categoryId;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category.')),
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

    if (widget.existing != null) {
      context.read<TransactionBloc>().add(TransactionUpdated(entity));
    } else {
      context.read<TransactionBloc>().add(TransactionAdded(entity));
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoryBloc>().state.categories.where(
      (c) =>
          c.type ==
          (_type == TransactionType.income
              ? CategoryType.income
              : CategoryType.expense),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existing != null ? 'Edit Transaction' : 'Add Transaction',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SegmentedButton<TransactionType>(
                  segments: const [
                    ButtonSegment(
                      value: TransactionType.expense,
                      label: Text('Expense'),
                    ),
                    ButtonSegment(
                      value: TransactionType.income,
                      label: Text('Income'),
                    ),
                  ],
                  selected: {_type},
                  onSelectionChanged: (s) => setState(() {
                    _type = s.first;
                    _categoryId = null;
                  }),
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixText: '₹ ',
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
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Enter a title' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<String>(
                  initialValue: _categoryId,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: categories
                      .map(
                        (c) =>
                            DropdownMenuItem(value: c.id, child: Text(c.name)),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _categoryId = v),
                  validator: (v) => v == null ? 'Select a category' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: AppSpacing.md),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Date'),
                  trailing: Text('${_date.day}/${_date.month}/${_date.year}'),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setState(() => _date = picked);
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Save Transaction'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
