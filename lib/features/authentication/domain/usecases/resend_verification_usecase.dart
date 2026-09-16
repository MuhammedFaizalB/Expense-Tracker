import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/usecase.dart';
import 'package:expense_tracker/features/authentication/domain/repositories/auth_repository.dart';

class ResendVerificationParams extends Equatable {
  final String email;
  const ResendVerificationParams(this.email);
  @override
  List<Object?> get props => [email];
}

class ResendVerificationEmailUseCase
    implements UseCase<void, ResendVerificationParams> {
  final AuthRepository repository;
  const ResendVerificationEmailUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(ResendVerificationParams params) {
    if (params.email.trim().isEmpty || !params.email.contains('@')) {
      return Future.value(
        const Left(ValidationFailure('Enter a valid email address.')),
      );
    }
    return repository.resendVerificationEmail(params.email.trim());
  }
}
