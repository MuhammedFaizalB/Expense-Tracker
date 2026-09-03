import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/network/network_info.dart';
import 'package:expense_tracker/features/transactions/data/datasources/transaction_remote_datasource.dart';
import 'package:expense_tracker/features/transactions/data/models/transaction_model.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction_entity.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction_filter.dart';
import 'package:expense_tracker/features/transactions/domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDataSource remote;
  final NetworkInfo networkInfo;
  const TransactionRepositoryImpl(this.remote, this.networkInfo);

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      return Right(await action());
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactions(
    TransactionFilter filter,
  ) => _guard(() => remote.getTransactions(filter));

  @override
  Future<Either<Failure, TransactionEntity>> getTransactionById(String id) =>
      _guard(() => remote.getTransactionById(id));

  @override
  Future<Either<Failure, TransactionEntity>> createTransaction(
    TransactionEntity transaction,
  ) => _guard(() => remote.createTransaction(_toModel(transaction)));

  @override
  Future<Either<Failure, TransactionEntity>> updateTransaction(
    TransactionEntity transaction,
  ) => _guard(() => remote.updateTransaction(_toModel(transaction)));

  @override
  Future<Either<Failure, void>> deleteTransaction(String id) =>
      _guard(() => remote.deleteTransaction(id));

  @override
  Future<Either<Failure, ({double income, double expense})>> getTotals({
    DateTime? start,
    DateTime? end,
  }) => _guard(() => remote.getTotals(start: start, end: end));

  TransactionModel _toModel(TransactionEntity e) => TransactionModel(
    id: e.id,
    userId: e.userId,
    type: e.type,
    amount: e.amount,
    categoryId: e.categoryId,
    title: e.title,
    description: e.description,
    transactionDate: e.transactionDate,
    createdAt: e.createdAt,
    updatedAt: e.updatedAt,
  );
}
