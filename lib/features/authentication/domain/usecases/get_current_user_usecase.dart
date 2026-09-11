import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/usecase.dart';
import 'package:expense_tracker/features/authentication/domain/entities/user_entity.dart';
import 'package:expense_tracker/features/authentication/domain/repositories/auth_repository.dart';

class GetCurrentUserUseCase implements UseCase<UserEntity?, NoParams> {
  final AuthRepository repository;
  const GetCurrentUserUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity?>> call(NoParams params) =>
      repository.getCurrentUser();
}
