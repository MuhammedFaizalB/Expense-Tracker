import 'package:collection/collection.dart';
import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/core/theme/theme_extensions.dart';
import 'package:expense_tracker/features/lending/domain/entities/lending_entity.dart';
import 'package:expense_tracker/features/lending/domain/lending_calculator.dart';
import 'package:expense_tracker/features/lending/presentation/bloc/lending_bloc.dart';
import 'package:expense_tracker/features/lending/presentation/widgets/lending_list_tile.dart';
import 'package:expense_tracker/features/lending/presentation/widgets/lending_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class PersonLedgerPage extends StatelessWidget {
  final String contactId;

  final String? name;
  const PersonLedgerPage({super.key, required this.contactId, this.name});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<LendingBloc>().state;
    final contact = state.contacts.firstWhereOrNull((c) => c.id == contactId);
    final title = contact?.name ?? name ?? 'Person';

    final records =
        state.records.where((r) => r.contactId == contactId).toList()
          ..sort((a, b) {
            final byDate = b.transactionDate.compareTo(a.transactionDate);
            return byDate != 0 ? byDate : b.createdAt.compareTo(a.createdAt);
          });

    final toReceive = LendingCalculator.totalToReceive(records);
    final toPay = LendingCalculator.totalToPay(records);
    final settled = (toReceive - toPay).abs() < 0.005;
    final openRecords = records
        .where((r) => r.status != LendingStatus.paid)
        .toList();

    // ignore: no_leading_underscores_for_local_identifiers
    Future<void> _markAllPaid(
      BuildContext context,
      List<LendingEntity> open,
    ) async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Mark all as paid?'),
          content: const Text(
            'These transactions cancel each other out. Each open one will be '
            'marked as paid with a settlement entry in its history.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Mark paid'),
            ),
          ],
        ),
      );
      if (confirmed != true || !context.mounted) return;

      final bloc = context.read<LendingBloc>();
      final now = DateTime.now();
      for (final r in open) {
        bloc.add(
          LendingPaymentRecorded(
            lendingId: r.id,
            remainingAmount: r.remainingAmount,
            amount: r.remainingAmount,
            paymentDate: now,
            note: 'Settled against other transactions',
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Add Transaction'),
        onPressed: () => context.push(
          Uri(
            path: '/lending/add',
            queryParameters: {'contactId': contactId, 'name': title},
          ).toString(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          96,
        ),
        children: [
          LendingSummaryCard(
            toReceive: settled ? 0 : toReceive,
            toPay: settled ? 0 : toPay,
            title: title,
          ),
          if (settled && openRecords.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Mark all as paid'),
              onPressed: () => _markAllPaid(context, openRecords),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          Text('ALL TRANSACTIONS', style: context.textStyles.bodyMedium),
          const SizedBox(height: AppSpacing.sm),
          if (records.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Center(
                child: Text(
                  'No transactions yet.',
                  style: context.textStyles.bodyMedium,
                ),
              ),
            )
          else
            ...records.map(
              (r) => LendingListTile(
                record: r,
                ledgerMode: true,
                onTap: () => context.push('/lending/${r.id}'),
              ),
            ),
        ],
      ),
    );
  }
}
