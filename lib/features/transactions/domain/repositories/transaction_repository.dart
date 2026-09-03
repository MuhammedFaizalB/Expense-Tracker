import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction_entity.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction_filter.dart';

abstract class TransactionRepository {
  Future<Either<Failure, List<TransactionEntity>>> getTransactions(
    TransactionFilter filter,
  );
  Future<Either<Failure, TransactionEntity>> getTransactionById(String id);
  Future<Either<Failure, TransactionEntity>> createTransaction(
    TransactionEntity transaction,
  );
  Future<Either<Failure, TransactionEntity>> updateTransaction(
    TransactionEntity transaction,
  );
  Future<Either<Failure, void>> deleteTransaction(String id);
  Future<Either<Failure, ({double income, double expense})>> getTotals({
    DateTime? start,
    DateTime? end,
  });
}
