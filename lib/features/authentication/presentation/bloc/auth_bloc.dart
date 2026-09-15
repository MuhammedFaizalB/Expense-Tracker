import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/usecase.dart';
import 'package:expense_tracker/features/authentication/domain/entities/user_entity.dart';
import 'package:expense_tracker/features/authentication/domain/repositories/auth_repository.dart';
import 'package:expense_tracker/features/authentication/domain/usecases/get_current_user_usecase.dart';
import 'package:expense_tracker/features/authentication/domain/usecases/login_usecase.dart';
import 'package:expense_tracker/features/authentication/domain/usecases/logout_usecase.dart';
import 'package:expense_tracker/features/authentication/domain/usecases/register_usecase.dart';
import 'package:expense_tracker/features/authentication/domain/usecases/reset_password_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final SendPasswordResetUseCase sendPasswordResetUseCase;
  final AuthRepository authRepository;

  StreamSubscription<UserEntity?>? _authSubscription;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
    required this.sendPasswordResetUseCase,
    required this.authRepository,
  }) : super(const AuthState()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthPasswordResetRequested>(_onPasswordResetRequested);
    on<AuthUserChanged>(_onUserChanged);

    _authSubscription = authRepository.authStateChanges.listen((user) {
      add(AuthUserChanged(user));
    });
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final result = await getCurrentUserUseCase(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(status: AuthStatus.unauthenticated, clearUser: true),
      ),
      (user) => emit(
        user != null
            ? state.copyWith(status: AuthStatus.authenticated, user: user)
            : state.copyWith(
                status: AuthStatus.unauthenticated,
                clearUser: true,
              ),
      ),
    );
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(status: AuthStatus.loading, needsEmailConfirmation: false),
    );
    final result = await loginUseCase(
      LoginParams(email: event.email, password: event.password),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: failure.message,
          clearError: false,
        ),
      ),
      (user) =>
          emit(state.copyWith(status: AuthStatus.authenticated, user: user)),
    );
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(status: AuthStatus.loading, needsEmailConfirmation: false),
    );
    final result = await registerUseCase(
      RegisterParams(
        email: event.email,
        password: event.password,
        displayName: event.displayName,
      ),
    );
    result.fold(
      (failure) {
        if (failure is EmailConfirmationRequiredFailure) {
          emit(
            state.copyWith(
              status: AuthStatus.unauthenticated,
              errorMessage: failure.message,
              clearError: false,
              needsEmailConfirmation: true,
              clearUser: true,
            ),
          );
        } else {
          emit(
            state.copyWith(
              status: AuthStatus.failure,
              errorMessage: failure.message,
              clearError: false,
            ),
          );
        }
      },
      (user) =>
          emit(state.copyWith(status: AuthStatus.authenticated, user: user)),
    );
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final result = await logoutUseCase(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: failure.message,
          clearError: false,
        ),
      ),
      (_) => emit(
        state.copyWith(status: AuthStatus.unauthenticated, clearUser: true),
      ),
    );
  }

  Future<void> _onPasswordResetRequested(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    final result = await sendPasswordResetUseCase(
      ResetPasswordParams(event.email),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          errorMessage: failure.message,
          clearError: false,
          passwordResetEmailSent: false,
        ),
      ),
      (_) => emit(state.copyWith(passwordResetEmailSent: true)),
    );
  }

  void _onUserChanged(AuthUserChanged event, Emitter<AuthState> emit) {
    emit(
      event.user != null
          ? state.copyWith(
              status: AuthStatus.authenticated,
              user: event.user,
              needsEmailConfirmation: false,
            )
          : state.copyWith(
              status: AuthStatus.unauthenticated,
              clearUser: true,
              needsEmailConfirmation: state.needsEmailConfirmation,
            ),
    );
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
