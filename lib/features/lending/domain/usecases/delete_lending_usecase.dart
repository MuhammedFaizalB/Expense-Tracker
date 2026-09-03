import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/usecase.dart';
import 'package:expense_tracker/features/lending/domain/repositories/lending_repository.dart';

class DeleteLendingUseCase implements UseCase<void, String> {
  final LendingRepository repository;
  const DeleteLendingUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String lendingId) =>
      repository.deleteLending(lendingId);
}
