import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/usecase.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction_entity.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction_filter.dart';
import 'package:expense_tracker/features/transactions/domain/repositories/transaction_repository.dart';

class GetTransactionsUseCase
    implements UseCase<List<TransactionEntity>, TransactionFilter> {
  final TransactionRepository repository;
  const GetTransactionsUseCase(this.repository);
  @override
  Future<Either<Failure, List<TransactionEntity>>> call(
    TransactionFilter params,
  ) => repository.getTransactions(params);
}

class AddTransactionUseCase
    implements UseCase<TransactionEntity, TransactionEntity> {
  final TransactionRepository repository;
  const AddTransactionUseCase(this.repository);

  @override
  Future<Either<Failure, TransactionEntity>> call(TransactionEntity params) {
    if (params.amount <= 0) {
      return Future.value(
        const Left(ValidationFailure('Amount must be greater than zero.')),
      );
    }
    if (params.title.trim().isEmpty) {
      return Future.value(
        const Left(ValidationFailure('Title cannot be empty.')),
      );
    }
    if (params.categoryId.trim().isEmpty) {
      return Future.value(
        const Left(ValidationFailure('Please select a category.')),
      );
    }
    return repository.createTransaction(params);
  }
}

class UpdateTransactionUseCase
    implements UseCase<TransactionEntity, TransactionEntity> {
  final TransactionRepository repository;
  const UpdateTransactionUseCase(this.repository);

  @override
  Future<Either<Failure, TransactionEntity>> call(TransactionEntity params) {
    if (params.amount <= 0) {
      return Future.value(
        const Left(ValidationFailure('Amount must be greater than zero.')),
      );
    }
    return repository.updateTransaction(params);
  }
}

class DeleteTransactionUseCase implements UseCase<void, String> {
  final TransactionRepository repository;
  const DeleteTransactionUseCase(this.repository);
  @override
  Future<Either<Failure, void>> call(String id) =>
      repository.deleteTransaction(id);
}
