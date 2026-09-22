import 'dart:async';
import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/core/theme/theme_extensions.dart';
import 'package:expense_tracker/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

const _resendCooldownSeconds = 30;

class VerifyEmailPage extends StatefulWidget {
  final String? email;
  const VerifyEmailPage({super.key, this.email});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  Timer? _cooldownTimer;
  int _secondsRemaining = 0;

  String? get _email =>
      widget.email ?? context.read<AuthBloc>().state.pendingVerificationEmail;

  void _startCooldown() {
    setState(() => _secondsRemaining = _resendCooldownSeconds);
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining <= 1) {
        timer.cancel();
        setState(() => _secondsRemaining = 0);
      } else {
        setState(() => _secondsRemaining -= 1);
      }
    });
  }

  void _resend() {
    final email = _email;
    if (email == null) return;
    _startCooldown();
    context.read<AuthBloc>().add(AuthResendVerificationRequested(email));
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final email = _email;
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.heroHeader,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listenWhen: (prev, curr) =>
            (curr.resendVerificationEmailSent &&
                !prev.resendVerificationEmailSent) ||
            (curr.errorMessage != null &&
                curr.errorMessage != prev.errorMessage &&
                !curr.needsEmailConfirmation),
        listener: (context, state) {
          if (state.resendVerificationEmailSent) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Verification email sent.')),
            );
          } else if (state.errorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    shape: BoxShape.circle,
                    boxShadow: AppEffects.glow(
                      colors.glow,
                      blur: 28,
                      opacity: 0.45,
                    ),
                  ),
                  child: const Icon(
                    Icons.mark_email_unread_rounded,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                const Text(
                  'Verify your email',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  email != null
                      ? "We've sent a verification link to $email. Click the link, then come back and log in."
                      : "We've sent a verification link to your email. Click the link, then come back and log in.",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final onCooldown = _secondsRemaining > 0;
                    return ElevatedButton(
                      onPressed: (onCooldown || email == null) ? null : _resend,
                      child: Text(
                        onCooldown
                            ? 'Resend link (${_secondsRemaining}s)'
                            : 'Resend verification link',
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                TextButton(
                  onPressed: () => context.go('/login'),
                  style: TextButton.styleFrom(foregroundColor: Colors.white),
                  child: const Text('Back to Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
