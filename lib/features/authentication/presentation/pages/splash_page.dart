import 'package:expense_tracker/core/theme/theme_extensions.dart';
import 'package:expense_tracker/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // go_router's redirect (see app_router.dart) reacts to AuthBloc state
    // changes, so simply kicking off the session check is enough — no
    // manual navigation call needed here.
    context.read<AuthBloc>().add(const AuthCheckRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 56,
              color: context.colors.onPrimary,
            ),
            const SizedBox(height: 16),
            Text(
              'Money Manager',
              style: TextStyle(
                color: context.colors.onPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            CircularProgressIndicator(color: context.colors.onPrimary),
          ],
        ),
      ),
    );
  }
}
