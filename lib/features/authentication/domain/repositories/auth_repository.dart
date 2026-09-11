import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/features/authentication/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> register({
    required String email,
    required String password,
    String? displayName,
  });

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, void>> sendPasswordResetEmail(String email);

  Future<Either<Failure, void>> updatePassword(String newPassword);

  Future<Either<Failure, UserEntity?>> getCurrentUser();

  Stream<UserEntity?> get authStateChanges;
}
