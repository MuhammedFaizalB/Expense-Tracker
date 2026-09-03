import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/usecase.dart';
import 'package:expense_tracker/features/lending/domain/entities/lending_entity.dart';
import 'package:expense_tracker/features/lending/domain/repositories/lending_repository.dart';

class AddLendingUseCase implements UseCase<LendingEntity, LendingEntity> {
  final LendingRepository repository;
  const AddLendingUseCase(this.repository);

  @override
  Future<Either<Failure, LendingEntity>> call(LendingEntity params) {
    if (params.personName.trim().isEmpty) {
      return Future.value(
        const Left(ValidationFailure('Enter the person\'s name.')),
      );
    }
    if (params.amount <= 0) {
      return Future.value(
        const Left(ValidationFailure('Amount must be greater than zero.')),
      );
    }
    return repository.createLending(params);
  }
}
