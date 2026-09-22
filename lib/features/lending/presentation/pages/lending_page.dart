import 'package:expense_tracker/core/theme/app_section_header.dart';
import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/features/lending/domain/entities/lending_entity.dart';
import 'package:expense_tracker/features/lending/presentation/bloc/lending_bloc.dart';
import 'package:expense_tracker/features/lending/presentation/widgets/lending_list_tile.dart';
import 'package:expense_tracker/features/lending/presentation/widgets/lending_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class LendingPage extends StatefulWidget {
  const LendingPage({super.key});

  @override
  State<LendingPage> createState() => _LendingPageState();
}

class _LendingPageState extends State<LendingPage> {
  @override
  void initState() {
    super.initState();
    context.read<LendingBloc>().add(const LendingLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/lending/add'),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          const AppSectionHeader(
            title: 'Lending',
            subtitle: 'Money you lend and borrow',
          ),
          Expanded(
            child: BlocBuilder<LendingBloc, LendingState>(
              builder: (context, state) {
                if (state.status == LendingStatusUi.loading ||
                    state.status == LendingStatusUi.initial) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.status == LendingStatusUi.failure) {
                  return _ErrorState(
                    message: state.errorMessage ?? 'Something went wrong.',
                    onRetry: () => context.read<LendingBloc>().add(
                      const LendingLoadRequested(),
                    ),
                  );
                }

                final toReceive = state.records
                    .where(
                      (r) =>
                          r.type == LendingType.lent &&
                          r.status != LendingStatus.paid,
                    )
                    .toList();
                final toPay = state.records
                    .where(
                      (r) =>
                          r.type == LendingType.borrowed &&
                          r.status != LendingStatus.paid,
                    )
                    .toList();

                if (state.records.isEmpty) {
                  return _EmptyState(onAdd: () => context.push('/lending/add'));
                }

                return RefreshIndicator(
                  onRefresh: () async => context.read<LendingBloc>().add(
                    const LendingLoadRequested(),
                  ),
                  child: ListView(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    children: [
                      LendingSummaryCard(
                        toReceive: state.totalToReceive,
                        toPay: state.totalToPay,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      if (toReceive.isNotEmpty) ...[
                        Text(
                          'TO RECEIVE',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        ...toReceive.map(
                          (r) => LendingListTile(
                            record: r,
                            onTap: () => context.push('/lending/${r.id}'),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                      if (toPay.isNotEmpty) ...[
                        Text(
                          'TO PAY',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        ...toPay.map(
                          (r) => LendingListTile(
                            record: r,
                            onTap: () => context.push('/lending/${r.id}'),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.handshake_outlined,
              size: 48,
              color: Theme.of(context).disabledColor,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No lending records yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Track money you lend to or borrow from others.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(onPressed: onAdd, child: const Text('Add Record')),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
