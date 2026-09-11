import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/usecase.dart';
import 'package:expense_tracker/features/authentication/domain/repositories/auth_repository.dart';

class LogoutUseCase implements UseCase<void, NoParams> {
  final AuthRepository repository;
  const LogoutUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) => repository.logout();
}
