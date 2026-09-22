import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/core/theme/theme_extensions.dart';
import 'package:expense_tracker/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const AppShell({super.key, required this.navigationShell});

  static const _destinations = [
    (icon: Icons.home_outlined, selectedIcon: Icons.home, label: 'Home'),
    (
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long,
      label: 'Transactions',
    ),
    (
      icon: Icons.handshake_outlined,
      selectedIcon: Icons.handshake,
      label: 'Lending',
    ),
    (
      icon: Icons.category_outlined,
      selectedIcon: Icons.category,
      label: 'Categories',
    ),
    (
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      label: 'Settings',
    ),
  ];

  static const _dashboardTabIndex = 0;

  void _onTap(BuildContext context, int index) {
    if (index == _dashboardTabIndex) {
      context.read<DashboardBloc>().add(const DashboardLoadRequested());
    }
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  void _showQuickAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Material(
          color: Theme.of(sheetContext).scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: sheetContext.colors.primary.withValues(
                      alpha: 0.15,
                    ),
                    child: Icon(
                      Icons.receipt_long_outlined,
                      color: sheetContext.colors.primary,
                    ),
                  ),
                  title: const Text('Add Transaction'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    context.go('/transactions/add');
                  },
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: sheetContext.colors.primary.withValues(
                      alpha: 0.15,
                    ),
                    child: Icon(
                      Icons.handshake_outlined,
                      color: sheetContext.colors.primary,
                    ),
                  ),
                  title: const Text('Add Lending Record'),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    context.go('/lending/add');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.sm,
        ),
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NavItem(
                destination: _destinations[0],
                selected: navigationShell.currentIndex == 0,
                onTap: () => _onTap(context, 0),
              ),
              _NavItem(
                destination: _destinations[1],
                selected: navigationShell.currentIndex == 1,
                onTap: () => _onTap(context, 1),
              ),
              _QuickAddButton(onTap: () => _showQuickAddSheet(context)),
              _NavItem(
                destination: _destinations[2],
                selected: navigationShell.currentIndex == 2,
                onTap: () => _onTap(context, 2),
              ),
              _NavItem(
                destination: _destinations[3],
                selected: navigationShell.currentIndex == 3,
                onTap: () => _onTap(context, 3),
              ),
              _NavItem(
                destination: _destinations[4],
                selected: navigationShell.currentIndex == 4,
                onTap: () => _onTap(context, 4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final ({IconData icon, IconData selectedIcon, String label}) destination;
  final bool selected;
  final VoidCallback onTap;
  const _NavItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? context.colors.primary
        : context.colors.textSecondary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? destination.selectedIcon : destination.icon,
              color: color,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              destination.label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAddButton extends StatelessWidget {
  final VoidCallback onTap;
  const _QuickAddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: colors.primary,
          shape: BoxShape.circle,
          boxShadow: AppEffects.glow(colors.glow, blur: 14, opacity: 0.45),
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 24),
      ),
    );
  }
}
