import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/usecase.dart';
import 'package:expense_tracker/features/authentication/domain/entities/user_entity.dart';
import 'package:expense_tracker/features/authentication/domain/repositories/auth_repository.dart';

class RegisterParams extends Equatable {
  final String email;
  final String password;
  final String? displayName;
  const RegisterParams({
    required this.email,
    required this.password,
    this.displayName,
  });
  @override
  List<Object?> get props => [email, password, displayName];
}

class RegisterUseCase implements UseCase<UserEntity, RegisterParams> {
  final AuthRepository repository;
  const RegisterUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(RegisterParams params) {
    if (params.email.trim().isEmpty || !params.email.contains("@")) {
      return Future.value(
        const Left(ValidationFailure("Enter a valid email address.")),
      );
    }
    if (params.password.length < 8) {
      return Future.value(
        const Left(
          ValidationFailure("Password must be at least 8 characters."),
        ),
      );
    }
    return repository.register(
      email: params.email.trim(),
      password: params.password,
      displayName: params.displayName,
    );
  }
}
