import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/core/theme/theme_extensions.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:flutter/material.dart';

class LendingSummaryCard extends StatelessWidget {
  final double toReceive;
  final double toPay;
  final String title;

  const LendingSummaryCard({
    super.key,
    required this.toReceive,
    required this.toPay,
    this.title = 'Lending Overview',
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final net = toReceive - toPay;
    final settled = net.abs() < 0.005;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: AppEffects.heroGradient(colors),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppEffects.glow(colors.glow),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.handshake_outlined,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            settled
                ? CurrencyFormatter.format(0)
                : '${net > 0 ? '+' : '-'}${CurrencyFormatter.format(net.abs())}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            settled
                ? 'All settled'
                : (net > 0 ? 'Net owed to you' : 'Net you owe'),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  icon: Icons.call_received,
                  label: 'You will receive',
                  amount: toReceive,
                ),
              ),
              Expanded(
                child: _MiniStat(
                  icon: Icons.call_made,
                  label: 'You need to pay',
                  amount: toPay,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final double amount;
  const _MiniStat({
    required this.icon,
    required this.label,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: Colors.white.withValues(alpha: 0.75)),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 11,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          CurrencyFormatter.format(amount),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
