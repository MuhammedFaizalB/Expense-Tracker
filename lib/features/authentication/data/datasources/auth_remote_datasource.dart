import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/features/authentication/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});
  Future<UserModel> register({
    required String email,
    required String password,
    String? displayName,
  });
  Future<void> logout();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> resendVerificationEmail(String email);
  Future<void> updatePassword(String newPassword);
  UserModel? getCurrentUser();
  Stream<UserModel?> get authStateChanges;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final supa.SupabaseClient client;
  const AuthRemoteDataSourceImpl(this.client);

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = res.user;
      if (user == null) throw const AuthException('Invalid email or password.');
      return UserModel.fromSupabase(user);
    } on AuthException {
      rethrow;
    } on supa.AuthException catch (e) {
      throw AuthException(_friendlyMessage(e));
    } catch (_) {
      throw const AuthException('Could not sign in. Please try again.');
    }
  }

  @override
  Future<UserModel> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final res = await client.auth.signUp(
        email: email,
        password: password,
        data: displayName != null ? {'display_name': displayName} : null,
      );
      final user = res.user;
      if (user == null) {
        throw const AuthException('Registration failed. Please try again.');
      }

      if (res.session == null) {
        throw const EmailConfirmationRequiredException();
      }

      return UserModel.fromSupabase(user);
    } on EmailConfirmationRequiredException {
      rethrow;
    } on supa.AuthException catch (e) {
      throw AuthException(_friendlyMessage(e));
    } catch (_) {
      throw const AuthException(
        'Could not create your account. Please try again.',
      );
    }
  }

  @override
  Future<void> logout() async {
    try {
      await client.auth.signOut();
    } catch (_) {
      throw const AuthException('Could not sign out. Please try again.');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await client.auth.resetPasswordForEmail(email);
    } on supa.AuthException catch (e) {
      throw AuthException(_friendlyMessage(e));
    }
  }

  @override
  Future<void> resendVerificationEmail(String email) async {
    try {
      await client.auth.resend(type: supa.OtpType.signup, email: email);
    } on supa.AuthException catch (e) {
      throw AuthException(_friendlyMessage(e));
    } catch (_) {
      throw const AuthException(
        'Could not resend the verification email. Please try again.',
      );
    }
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    try {
      await client.auth.updateUser(supa.UserAttributes(password: newPassword));
    } on supa.AuthException catch (e) {
      throw AuthException(_friendlyMessage(e));
    }
  }

  @override
  UserModel? getCurrentUser() {
    final user = client.auth.currentSession?.user;
    return user != null ? UserModel.fromSupabase(user) : null;
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return client.auth.onAuthStateChange.map((data) {
      final user = data.session?.user;
      return user != null ? UserModel.fromSupabase(user) : null;
    });
  }

  String _friendlyMessage(supa.AuthException e) {
    final code = e is supa.AuthApiException ? e.code?.toLowerCase() : null;
    final lower = e.message.toLowerCase();

    if (code == 'email_not_confirmed' ||
        lower.contains('email not confirmed')) {
      return 'Please verify your email before logging in.';
    }
    if (code == 'invalid_credentials' ||
        lower.contains('invalid login credentials')) {
      return 'Incorrect email or password.';
    }
    if (code == 'user_already_exists' ||
        lower.contains('already registered') ||
        lower.contains('already exists')) {
      return 'An account with this email already exists.';
    }
    if (code == 'over_email_send_rate_limit' || lower.contains('rate limit')) {
      return 'Too many attempts. Please wait and try again.';
    }
    return 'Something went wrong. Please try again.';
  }
}
