import 'dart:async';

import 'package:expense_tracker/core/router/app_shell.dart';
import 'package:expense_tracker/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/authentication/presentation/pages/forgot_password_page.dart';
import 'package:expense_tracker/features/authentication/presentation/pages/login_page.dart';
import 'package:expense_tracker/features/authentication/presentation/pages/register_page.dart';
import 'package:expense_tracker/features/authentication/presentation/pages/splash_page.dart';
import 'package:expense_tracker/features/categories/presentation/pages/categories_page.dart';
import 'package:expense_tracker/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:expense_tracker/features/lending/presentation/pages/lending_details_page.dart';
import 'package:expense_tracker/features/lending/presentation/pages/lending_form_page.dart';
import 'package:expense_tracker/features/lending/presentation/pages/lending_page.dart';
import 'package:expense_tracker/features/settings/presentation/pages/settings_page.dart';
import 'package:expense_tracker/features/transactions/presentation/pages/transaction_detail_page.dart';
import 'package:expense_tracker/features/transactions/presentation/pages/transaction_form_page.dart';
import 'package:expense_tracker/features/transactions/presentation/pages/transactions_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

GoRouter buildRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: _AuthBlocListenable(authBloc),
    redirect: (context, state) {
      final status = authBloc.state.status;
      final loggingIn =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/forgot-password';
      final onSplash = state.matchedLocation == '/splash';

      if (status == AuthStatus.initial || status == AuthStatus.loading) {
        return onSplash ? null : '/splash';
      }
      if (status != AuthStatus.authenticated) {
        return loggingIn ? null : '/login';
      }
      if (loggingIn || onSplash) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashPage()),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/transactions',
                builder: (context, state) => const TransactionsPage(),
                routes: [
                  GoRoute(
                    path: 'add',
                    builder: (context, state) => const TransactionFormPage(),
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (context, state) => TransactionDetailPage(
                      transactionId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/lending',
                builder: (context, state) => const LendingPage(),
                routes: [
                  GoRoute(
                    path: 'add',
                    builder: (context, state) => const LendingFormPage(),
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (context, state) => LendingDetailPage(
                      recordId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/categories',
                builder: (context, state) => const CategoriesPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

class _AuthBlocListenable extends ChangeNotifier {
  final AuthBloc _bloc;
  late final StreamSubscription _sub;

  _AuthBlocListenable(this._bloc) {
    _sub = _bloc.stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
