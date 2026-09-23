import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/core/theme/theme_extensions.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:flutter/material.dart';

class DashboardHeroHeader extends StatelessWidget {
  final String greeting;
  final double balance;
  final double income;
  final double expense;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onWalletTap;

  const DashboardHeroHeader({
    super.key,
    required this.greeting,
    required this.balance,
    required this.income,
    required this.expense,
    this.onNotificationTap,
    this.onWalletTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.heroHeader,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppRadius.xl),
          bottomRight: Radius.circular(AppRadius.xl),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Here's your money summary for this month.",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              _IconBadge(
                icon: Icons.notifications_none_rounded,
                onTap: onNotificationTap,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _BalanceCard(
            balance: balance,
            income: income,
            expense: expense,
            onWalletTap: onWalletTap,
          ),
        ],
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _IconBadge({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _BalanceCard extends StatefulWidget {
  final double balance;
  final double income;
  final double expense;
  final VoidCallback? onWalletTap;
  const _BalanceCard({
    required this.balance,
    required this.income,
    required this.expense,
    this.onWalletTap,
  });

  @override
  State<_BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<_BalanceCard> {
  bool _isVisible = true;

  String _display(double amount) =>
      _isVisible ? CurrencyFormatter.format(amount) : '••••••';

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Total Balance',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: () => setState(() => _isVisible = !_isVisible),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Icon(
                        _isVisible
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: Colors.white.withValues(alpha: 0.75),
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: widget.onWalletTap,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_outlined,
                    color: Colors.white,
                    size: 17,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _display(widget.balance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: 'Income',
                  text: _display(widget.income),
                ),
              ),
              Expanded(
                child: _MiniStat(
                  label: 'Expenses',
                  text: _display(widget.expense),
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
  final String label;
  final String text;
  const _MiniStat({required this.label, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.75),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          text,
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
