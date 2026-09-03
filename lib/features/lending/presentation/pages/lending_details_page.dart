import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/core/theme/theme_extensions.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/core/utils/date_formatter.dart';
import 'package:expense_tracker/features/lending/domain/entities/lending_entity.dart';
import 'package:expense_tracker/features/lending/domain/repositories/lending_repository.dart';
import 'package:expense_tracker/features/lending/presentation/bloc/lending_bloc.dart';
import 'package:expense_tracker/features/lending/presentation/widgets/record_payment_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LendingDetailPage extends StatefulWidget {
  final LendingEntity record;
  const LendingDetailPage({super.key, required this.record});

  @override
  State<LendingDetailPage> createState() => _LendingDetailPageState();
}

class _LendingDetailPageState extends State<LendingDetailPage> {
  late Future<List<LendingPaymentEntity>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = _loadHistory();
  }

  Future<List<LendingPaymentEntity>> _loadHistory() async {
    final repo = context.read<LendingRepository>();
    final result = await repo.getPaymentHistory(widget.record.id);
    return result.fold((_) => [], (list) => list);
  }

  void _refresh() => setState(() => _historyFuture = _loadHistory());

  @override
  Widget build(BuildContext context) {
    final r = widget.record;
    final isPaid = r.status == LendingStatus.paid;

    return Scaffold(
      appBar: AppBar(
        title: Text(r.personName),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete record?'),
                  content: const Text('This cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (confirmed == true && context.mounted) {
                context.read<LendingBloc>().add(LendingRecordDeleted(r.id));
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
      floatingActionButton: isPaid
          ? null
          : FloatingActionButton.extended(
              icon: const Icon(Icons.add),
              label: const Text('Record Payment'),
              onPressed: () async {
                final recorded = await showModalBottomSheet<bool>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => RecordPaymentSheet(record: r),
                );
                if (recorded == true) _refresh();
              },
            ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.type == LendingType.lent
                        ? '${r.personName} owes you'
                        : 'You owe ${r.personName}',
                    style: context.textStyles.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    CurrencyFormatter.format(r.amount),
                    style: context.textStyles.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      _stat(
                        context,
                        'Paid',
                        r.amountPaid,
                        context.colors.success,
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      _stat(
                        context,
                        'Remaining',
                        r.remainingAmount,
                        context.colors.warning,
                      ),
                    ],
                  ),
                  if (r.dueDate != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Due ${DateFormatter.display(r.dueDate!)}',
                      style: context.textStyles.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('PAYMENT HISTORY', style: context.textStyles.bodyMedium),
          const SizedBox(height: AppSpacing.sm),
          FutureBuilder<List<LendingPaymentEntity>>(
            future: _historyFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final payments = snapshot.data!;
              if (payments.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Text(
                    'No payments recorded yet.',
                    style: context.textStyles.bodyMedium,
                  ),
                );
              }
              return Column(
                children: payments
                    .map(
                      (p) => Card(
                        margin: const EdgeInsets.only(bottom: AppSpacing.xs),
                        child: ListTile(
                          title: Text(DateFormatter.display(p.paymentDate)),
                          subtitle: p.note != null ? Text(p.note!) : null,
                          trailing: Text(
                            CurrencyFormatter.format(p.amount),
                            style: context.textStyles.titleMedium,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _stat(BuildContext context, String label, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.textStyles.bodyMedium),
        Text(
          CurrencyFormatter.format(amount),
          style: context.textStyles.titleMedium?.copyWith(color: color),
        ),
      ],
    );
  }
}
