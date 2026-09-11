import 'package:expense_tracker/features/authentication/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});
  Future<UserModel> register({
    required String email,
    required String password,
    String? displayName,
  });
  Future<void> logout();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> updatePassword(String newPassword);
  UserModel? getCurrentUser();
  Stream<UserModel?> get authStateChanges;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient client;
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
    } on AuthApiException catch (e) {
      throw AuthException(_friendlyMessage(e.message));
    } on AuthException {
      rethrow;
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
      return UserModel.fromSupabase(user);
    } on AuthApiException catch (e) {
      throw AuthException(_friendlyMessage(e.message));
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
    } on AuthApiException catch (e) {
      throw AuthException(_friendlyMessage(e.message));
    }
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    try {
      await client.auth.updateUser(UserAttributes(password: newPassword));
    } on AuthApiException catch (e) {
      throw AuthException(_friendlyMessage(e.message));
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

  /// Supabase error strings are technically accurate but not user-friendly.
  /// Translate the common ones; fall back to a generic message otherwise
  /// so we never leak raw backend text to the UI.
  String _friendlyMessage(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('invalid login credentials')) {
      return 'Incorrect email or password.';
    }
    if (lower.contains('already registered') ||
        lower.contains('already exists')) {
      return 'An account with this email already exists.';
    }
    if (lower.contains('email not confirmed')) {
      return 'Please verify your email before logging in.';
    }
    if (lower.contains('rate limit')) {
      return 'Too many attempts. Please wait and try again.';
    }
    return 'Something went wrong. Please try again.';
  }
}
