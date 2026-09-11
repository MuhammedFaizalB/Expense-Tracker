import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/usecase.dart';
import 'package:expense_tracker/features/authentication/domain/entities/user_entity.dart';
import 'package:expense_tracker/features/authentication/domain/repositories/auth_repository.dart';

class LoginParams extends Equatable {
  final String email;
  final String password;
  const LoginParams({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

class LoginUseCase implements UseCase<UserEntity, LoginParams> {
  final AuthRepository repository;
  const LoginUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(LoginParams params) {
    if (params.email.trim().isEmpty || !params.email.contains("@")) {
      return Future.value(
        const Left(ValidationFailure("Enter a valid email address.")),
      );
    }
    if (params.password.isEmpty) {
      return Future.value(
        const Left(ValidationFailure("Password cannot be empty.")),
      );
    }
    return repository.login(
      email: params.email.trim(),
      password: params.password,
    );
  }
}
