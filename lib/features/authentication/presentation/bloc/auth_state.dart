part of 'auth_bloc.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, failure }

class AuthState extends Equatable {
  final AuthStatus status;
  final UserEntity? user;
  final String? errorMessage;

  final bool passwordResetEmailSent;

  final bool needsEmailConfirmation;

  final String? pendingVerificationEmail;

  final bool resendVerificationEmailSent;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.passwordResetEmailSent = false,
    this.needsEmailConfirmation = false,
    this.pendingVerificationEmail,
    this.resendVerificationEmailSent = false,
  });

  bool get isAuthenticated =>
      status == AuthStatus.authenticated && user != null;

  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    String? errorMessage,
    bool? passwordResetEmailSent,
    bool? needsEmailConfirmation,
    String? pendingVerificationEmail,
    bool? resendVerificationEmailSent,
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
      needsEmailConfirmation: needsEmailConfirmation ?? false,
      pendingVerificationEmail:
          pendingVerificationEmail ?? this.pendingVerificationEmail,
      resendVerificationEmailSent: resendVerificationEmailSent ?? false,
    );
  }

  @override
  List<Object?> get props => [
    status,
    user,
    errorMessage,
    passwordResetEmailSent,
    needsEmailConfirmation,
    pendingVerificationEmail,
    resendVerificationEmailSent,
  ];
}
