import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:expense_tracker/core/network/network_info.dart';
import 'package:expense_tracker/core/theme/theme_cubit.dart';
import 'package:expense_tracker/features/authentication/domain/usecases/resend_verification_usecase.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Authentication
import 'package:expense_tracker/features/authentication/data/datasources/auth_remote_datasource.dart';
import 'package:expense_tracker/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:expense_tracker/features/authentication/domain/repositories/auth_repository.dart';
import 'package:expense_tracker/features/authentication/domain/usecases/get_current_user_usecase.dart';
import 'package:expense_tracker/features/authentication/domain/usecases/login_usecase.dart';
import 'package:expense_tracker/features/authentication/domain/usecases/logout_usecase.dart';
import 'package:expense_tracker/features/authentication/domain/usecases/register_usecase.dart';
import 'package:expense_tracker/features/authentication/domain/usecases/reset_password_usecase.dart';
import 'package:expense_tracker/features/authentication/presentation/bloc/auth_bloc.dart';

// Categories
import 'package:expense_tracker/features/categories/data/datasources/category_remote_datasource.dart';
import 'package:expense_tracker/features/categories/data/repositories/category_repository_impl.dart';
import 'package:expense_tracker/features/categories/domain/repositories/category_repository.dart';
import 'package:expense_tracker/features/categories/domain/usecases/category_usecases.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_bloc.dart';

// Transactions
import 'package:expense_tracker/features/transactions/data/datasources/transaction_remote_datasource.dart';
import 'package:expense_tracker/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:expense_tracker/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:expense_tracker/features/transactions/domain/usecases/transaction_usecases.dart';
import 'package:expense_tracker/features/transactions/presentation/bloc/transaction_bloc.dart';

// Lending
import 'package:expense_tracker/features/lending/data/datasources/lending_remote_datasource.dart';
import 'package:expense_tracker/features/lending/data/repositories/lending_repository_impl.dart';
import 'package:expense_tracker/features/lending/domain/repositories/lending_repository.dart';
import 'package:expense_tracker/features/lending/domain/usecases/add_lending_usecase.dart';
import 'package:expense_tracker/features/lending/domain/usecases/delete_lending_usecase.dart';
import 'package:expense_tracker/features/lending/domain/usecases/get_lendings_usecase.dart';
import 'package:expense_tracker/features/lending/domain/usecases/record_payment_usecase.dart';
import 'package:expense_tracker/features/lending/presentation/bloc/lending_bloc.dart';

// Dashboard
import 'package:expense_tracker/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:expense_tracker/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:expense_tracker/features/dashboard/domain/usecases/get_dashboard_summary_usecase.dart';
import 'package:expense_tracker/features/dashboard/presentation/bloc/dashboard_bloc.dart';

// Settings
import 'package:expense_tracker/features/settings/data/datasources/setting_local_datasource.dart';
import 'package:expense_tracker/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:expense_tracker/features/settings/domain/repositories/settings_repository.dart';
import 'package:expense_tracker/features/settings/domain/usecases/get_app_info_usecase.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_bloc.dart';

final sl = GetIt.instance;

/// Call once from main() before runApp(). Registers dependencies bottom-up:
/// datasources -> repositories -> use cases -> BLoCs, matching the Clean
/// Architecture dependency direction (Presentation -> Domain -> Data).
Future<void> initDependencies() async {
  // --- External ---
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => prefs);
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(Connectivity()));
  sl.registerLazySingleton<ThemeCubit>(() => ThemeCubit(sl()));

  // --- Authentication ---
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => SendPasswordResetUseCase(sl()));
  sl.registerLazySingleton(() => ResendVerificationEmailUseCase(sl()));
  sl.registerLazySingleton(
    () => AuthBloc(
      loginUseCase: sl(),
      registerUseCase: sl(),
      logoutUseCase: sl(),
      getCurrentUserUseCase: sl(),
      sendPasswordResetUseCase: sl(),
      resendVerificationEmailUseCase: sl(),
      authRepository: sl(),
    ),
  );

  // --- Categories ---
  sl.registerLazySingleton<CategoryRemoteDataSource>(
    () => CategoryRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton(() => GetCategoriesUseCase(sl()));
  sl.registerLazySingleton(() => AddCategoryUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCategoryUseCase(sl()));
  sl.registerLazySingleton(() => DeleteCategoryUseCase(sl()));
  sl.registerLazySingleton(
    () => CategoryBloc(
      getCategoriesUseCase: sl(),
      addCategoryUseCase: sl(),
      updateCategoryUseCase: sl(),
      deleteCategoryUseCase: sl(),
    ),
  );

  // --- Transactions ---
  sl.registerLazySingleton<TransactionRemoteDataSource>(
    () => TransactionRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton(() => GetTransactionsUseCase(sl()));
  sl.registerLazySingleton(() => AddTransactionUseCase(sl()));
  sl.registerLazySingleton(() => UpdateTransactionUseCase(sl()));
  sl.registerLazySingleton(() => DeleteTransactionUseCase(sl()));
  sl.registerLazySingleton(
    () => TransactionBloc(
      getTransactionsUseCase: sl(),
      addTransactionUseCase: sl(),
      updateTransactionUseCase: sl(),
      deleteTransactionUseCase: sl(),
    ),
  );

  // --- Lending ---
  sl.registerLazySingleton<LendingRemoteDataSource>(
    () => LendingRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<LendingRepository>(
    () => LendingRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton(() => GetLendingsUseCase(sl()));
  sl.registerLazySingleton(() => AddLendingUseCase(sl()));
  sl.registerLazySingleton(() => DeleteLendingUseCase(sl()));
  sl.registerLazySingleton(() => RecordPaymentUseCase(sl()));
  sl.registerLazySingleton(
    () => LendingBloc(
      getLendingsUseCase: sl(),
      addLendingUseCase: sl(),
      deleteLendingUseCase: sl(),
      recordPaymentUseCase: sl(),
      lendingRepository: sl(),
    ),
  );

  // --- Dashboard (data layer composes Transaction + Lending repositories) ---
  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(
      transactionRepository: sl(),
      lendingRepository: sl(),
    ),
  );
  sl.registerLazySingleton(() => GetDashboardSummaryUseCase(sl()));
  sl.registerFactory(() => DashboardBloc(getDashboardSummaryUseCase: sl()));

  // --- Settings ---
  sl.registerLazySingleton<SettingsLocalDataSource>(
    () => const SettingsLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetAppInfoUseCase(sl()));
  sl.registerFactory(() => SettingsBloc(getAppInfoUseCase: sl()));
}
