import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/core/theme/theme_extensions.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/features/lending/domain/entities/lending_contact_entity.dart';
import 'package:expense_tracker/features/lending/domain/lending_calculator.dart';
import 'package:expense_tracker/features/lending/presentation/bloc/lending_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class PeoplePage extends StatelessWidget {
  const PeoplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LendingBloc, LendingState>(
      builder: (context, state) {
        if (state.contacts.isEmpty) {
          return const _EmptyPeople();
        }
        return RefreshIndicator(
          onRefresh: () async {
            context.read<LendingBloc>()
              ..add(const LendingLoadRequested())
              ..add(const LendingContactsLoadRequested());
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: state.contacts.length,
            itemBuilder: (context, i) {
              final contact = state.contacts[i];

              final records = state.records
                  .where((r) => r.contactId == contact.id)
                  .toList();
              return _PersonTile(
                contact: contact,
                net: LendingCalculator.netBalance(records),
                count: records.length,
              );
            },
          ),
        );
      },
    );
  }
}

class _PersonTile extends StatelessWidget {
  final LendingContactEntity contact;
  final double net;
  final int count;
  const _PersonTile({
    required this.contact,
    required this.net,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final settled = net.abs() < 0.005;
    final color = settled
        ? colors.textSecondary
        : (net > 0 ? colors.income : colors.expense);
    final label = settled
        ? 'Settled'
        : (net > 0 ? 'You will get' : 'You will give');

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        onTap: () => context.push(
          Uri(
            path: '/lending/people/${contact.id}',
            queryParameters: {'name': contact.name},
          ).toString(),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        leading: CircleAvatar(
          backgroundColor: colors.primary.withValues(alpha: 0.14),
          child: Text(
            contact.name.trim().isEmpty
                ? '?'
                : contact.name.trim()[0].toUpperCase(),
            style: TextStyle(
              color: colors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        title: Text(contact.name, style: context.textStyles.titleMedium),
        subtitle: Text(
          count == 1 ? '1 transaction' : '$count transactions',
          style: context.textStyles.bodyMedium,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              CurrencyFormatter.format(net.abs()),
              style: context.textStyles.titleMedium?.copyWith(color: color),
            ),
            Text(label, style: context.textStyles.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _EmptyPeople extends StatelessWidget {
  const _EmptyPeople();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.people_outline,
              size: 48,
              color: Theme.of(context).disabledColor,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No people yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Add a lending record and the person is created automatically.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: () => context.push('/lending/add'),
              child: const Text('Add Record'),
            ),
          ],
        ),
      ),
    );
  }
}
