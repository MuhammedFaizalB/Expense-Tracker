import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/usecase.dart';
import 'package:expense_tracker/features/lending/domain/entities/lending_contact_entity.dart';
import 'package:expense_tracker/features/lending/domain/repositories/lending_repository.dart';

class GetLendingContactsUseCase
    implements UseCase<List<LendingContactEntity>, NoParams> {
  final LendingRepository repository;
  const GetLendingContactsUseCase(this.repository);

  @override
  Future<Either<Failure, List<LendingContactEntity>>> call(NoParams params) =>
      repository.getContacts();
}
