import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/lending/domain/entities/lending_entity.dart';
import 'package:expense_tracker/features/lending/presentation/bloc/lending_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

class LendingFormPage extends StatefulWidget {
  final LendingEntity? existing;
  const LendingFormPage({super.key, this.existing});

  @override
  State<LendingFormPage> createState() => _LendingFormPageState();
}

class _LendingFormPageState extends State<LendingFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(
    text: widget.existing?.personName,
  );
  late final _amountController = TextEditingController(
    text: widget.existing?.amount.toStringAsFixed(2),
  );
  late final _descController = TextEditingController(
    text: widget.existing?.description,
  );
  late LendingType _type = widget.existing?.type ?? LendingType.lent;
  late DateTime _date = widget.existing?.transactionDate ?? DateTime.now();
  late DateTime? _dueDate = widget.existing?.dueDate;

  Future<void> _pickDate({required bool isDue}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isDue ? (_dueDate ?? DateTime.now()) : _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => isDue ? _dueDate = picked : _date = picked);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final userId = context.read<AuthBloc>().state.user?.id ?? '';
    final amount = double.parse(_amountController.text);
    final now = DateTime.now();

    final entity = LendingEntity(
      id: widget.existing?.id ?? const Uuid().v4(),
      userId: userId,
      personName: _nameController.text.trim(),
      type: _type,
      amount: amount,
      remainingAmount: widget.existing?.remainingAmount ?? amount,
      description: _descController.text.trim().isEmpty
          ? null
          : _descController.text.trim(),
      transactionDate: _date,
      dueDate: _dueDate,
      status: widget.existing?.status ?? LendingStatus.pending,
      createdAt: widget.existing?.createdAt ?? now,
      updatedAt: now,
    );

    if (widget.existing != null) {
      context.read<LendingBloc>().add(LendingRecordUpdated(entity));
    } else {
      context.read<LendingBloc>().add(LendingRecordAdded(entity));
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existing != null ? 'Edit Record' : 'Add Lending Record',
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
                SegmentedButton<LendingType>(
                  segments: const [
                    ButtonSegment(value: LendingType.lent, label: Text('Lent')),
                    ButtonSegment(
                      value: LendingType.borrowed,
                      label: Text('Borrowed'),
                    ),
                  ],
                  selected: {_type},
                  onSelectionChanged: (s) => setState(() => _type = s.first),
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Person'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
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
                  controller: _descController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Date'),
                  trailing: Text('${_date.day}/${_date.month}/${_date.year}'),
                  onTap: () => _pickDate(isDue: false),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Due date (optional)'),
                  trailing: Text(
                    _dueDate == null
                        ? 'Set date'
                        : '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}',
                  ),
                  onTap: () => _pickDate(isDue: true),
                ),
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Save Record'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
