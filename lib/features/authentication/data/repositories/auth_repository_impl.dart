import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/network/network_info.dart';
import 'package:expense_tracker/features/authentication/data/datasources/auth_remote_datasource.dart';
import 'package:expense_tracker/features/authentication/domain/entities/user_entity.dart';
import 'package:expense_tracker/features/authentication/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  const AuthRepositoryImpl(this.remoteDataSource, this.networkInfo);

  Future<Either<Failure, T>> _requireConnection<T>(
    Future<Either<Failure, T>> Function() action,
  ) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    return action();
  }

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) {
    return _requireConnection(() async {
      try {
        final user = await remoteDataSource.login(
          email: email,
          password: password,
        );
        return Right(user);
      } on EmailConfirmationRequiredException catch (e) {
        return Left(EmailConfirmationRequiredFailure(e.message));
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      } catch (_) {
        return const Left(UnknownFailure());
      }
    });
  }

  @override
  Future<Either<Failure, UserEntity>> register({
    required String email,
    required String password,
    String? displayName,
  }) {
    return _requireConnection(() async {
      try {
        final user = await remoteDataSource.register(
          email: email,
          password: password,
          displayName: displayName,
        );
        return Right(user);
      } on EmailConfirmationRequiredException catch (e) {
        return Left(EmailConfirmationRequiredFailure(e.message));
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      } catch (_) {
        return const Left(UnknownFailure());
      }
    });
  }

  @override
  Future<Either<Failure, void>> logout() {
    return _requireConnection(() async {
      try {
        await remoteDataSource.logout();
        return const Right(null);
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      } catch (_) {
        return const Left(UnknownFailure());
      }
    });
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) {
    return _requireConnection(() async {
      try {
        await remoteDataSource.sendPasswordResetEmail(email);
        return const Right(null);
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      } catch (_) {
        return const Left(UnknownFailure());
      }
    });
  }

  @override
  Future<Either<Failure, void>> resendVerificationEmail(String email) {
    return _requireConnection(() async {
      try {
        await remoteDataSource.resendVerificationEmail(email);
        return const Right(null);
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      } catch (_) {
        return const Left(UnknownFailure());
      }
    });
  }

  @override
  Future<Either<Failure, void>> updatePassword(String newPassword) {
    return _requireConnection(() async {
      try {
        await remoteDataSource.updatePassword(newPassword);
        return const Right(null);
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message));
      } catch (_) {
        return const Left(UnknownFailure());
      }
    });
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      return Right(remoteDataSource.getCurrentUser());
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges => remoteDataSource.authStateChanges;
}
