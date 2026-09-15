import 'package:expense_tracker/core/di/injection_container.dart';
import 'package:expense_tracker/core/router/app_router.dart';
import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/core/theme/theme_cubit.dart';
import 'package:expense_tracker/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:expense_tracker/features/lending/domain/repositories/lending_repository.dart';
import 'package:expense_tracker/features/lending/presentation/bloc/lending_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:expense_tracker/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  await initDependencies();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router = buildRouter(sl<AuthBloc>());
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(
          value: sl<AuthBloc>()..add(const AuthCheckRequested()),
        ),
        BlocProvider<ThemeCubit>.value(value: sl<ThemeCubit>()),
        BlocProvider<CategoryBloc>.value(
          value: sl<CategoryBloc>()..add(const CategoryLoadRequested()),
        ),
        BlocProvider<TransactionBloc>.value(value: sl<TransactionBloc>()),
        BlocProvider<LendingBloc>.value(value: sl<LendingBloc>()),
        BlocProvider<DashboardBloc>.value(value: sl<DashboardBloc>()),
        BlocProvider<SettingsBloc>.value(value: sl<SettingsBloc>()),
        RepositoryProvider<LendingRepository>(
          create: (_) => sl<LendingRepository>(),
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<TransactionBloc, TransactionState>(
            listenWhen: (prev, curr) => prev.transactions != curr.transactions,
            listener: (context, state) => context.read<DashboardBloc>().add(
              const DashboardLoadRequested(),
            ),
          ),
          BlocListener<LendingBloc, LendingState>(
            listenWhen: (prev, curr) => prev.records != curr.records,
            listener: (context, state) => context.read<DashboardBloc>().add(
              const DashboardLoadRequested(),
            ),
          ),
        ],
        child: BlocBuilder<ThemeCubit, AppThemeMode>(
          builder: (context, themeMode) {
            return MaterialApp.router(
              title: 'FinMonk',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light(),
              darkTheme: AppTheme.dark(),
              themeMode: themeMode.toFlutterThemeMode,
              routerConfig: _router,
            );
          },
        ),
      ),
    );
  }
}
