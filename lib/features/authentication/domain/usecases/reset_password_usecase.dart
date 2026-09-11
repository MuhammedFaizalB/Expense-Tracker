import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/usecase.dart';
import 'package:expense_tracker/features/authentication/domain/repositories/auth_repository.dart';

class ResetPasswordParams extends Equatable {
  final String email;
  const ResetPasswordParams(this.email);
  @override
  List<Object?> get props => [email];
}

class SendPasswordResetUseCase implements UseCase<void, ResetPasswordParams> {
  final AuthRepository repository;
  const SendPasswordResetUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(ResetPasswordParams params) {
    if (params.email.trim().isEmpty || !params.email.contains("@")) {
      return Future.value(
        const Left(ValidationFailure("Enter a valid email address.")),
      );
    }
    return repository.sendPasswordResetEmail(params.email.trim());
  }
}
