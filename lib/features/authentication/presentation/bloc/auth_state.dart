part of 'auth_bloc.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, failure }

class AuthState extends Equatable {
  final AuthStatus status;
  final UserEntity? user;
  final String? errorMessage;

  /// Set briefly after a password-reset email is sent, so the UI can show a
  /// one-time confirmation without it persisting across rebuilds.
  final bool passwordResetEmailSent;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.passwordResetEmailSent = false,
  });

  bool get isAuthenticated =>
      status == AuthStatus.authenticated && user != null;

  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    String? errorMessage,
    bool? passwordResetEmailSent,
    bool clearUser = false,
    bool clearError = true,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      errorMessage: clearError
          ? errorMessage
          : (errorMessage ?? this.errorMessage),
      passwordResetEmailSent: passwordResetEmailSent ?? false,
    );
  }

  @override
  List<Object?> get props => [
    status,
    user,
    errorMessage,
    passwordResetEmailSent,
  ];
}
