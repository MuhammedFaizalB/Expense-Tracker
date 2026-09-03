import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/network/network_info.dart';
import 'package:expense_tracker/features/lending/data/datasources/lending_remote_datasource.dart';
import 'package:expense_tracker/features/lending/data/models/lending_model.dart';
import 'package:expense_tracker/features/lending/domain/entities/lending_entity.dart';
import 'package:expense_tracker/features/lending/domain/repositories/lending_repository.dart';

class LendingRepositoryImpl implements LendingRepository {
  final LendingRemoteDataSource remote;
  final NetworkInfo networkInfo;
  const LendingRepositoryImpl(this.remote, this.networkInfo);

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
  Future<Either<Failure, List<LendingEntity>>> getLendings({
    LendingType? type,
    LendingStatus? status,
  }) => _guard(() => remote.getLendings(type: type, status: status));

  @override
  Future<Either<Failure, LendingEntity>> getLendingById(String id) =>
      _guard(() => remote.getLendingById(id));

  @override
  Future<Either<Failure, LendingEntity>> createLending(LendingEntity lending) =>
      _guard(() => remote.createLending(_toModel(lending)));

  @override
  Future<Either<Failure, LendingEntity>> updateLending(LendingEntity lending) =>
      _guard(() => remote.updateLending(_toModel(lending)));

  @override
  Future<Either<Failure, void>> deleteLending(String id) =>
      _guard(() => remote.deleteLending(id));

  @override
  Future<Either<Failure, List<LendingPaymentEntity>>> getPaymentHistory(
    String lendingId,
  ) => _guard(() => remote.getPaymentHistory(lendingId));

  @override
  Future<Either<Failure, LendingEntity>> recordPayment({
    required String lendingId,
    required double amount,
    required DateTime paymentDate,
    String? note,
  }) => _guard(
    () => remote.recordPayment(
      lendingId: lendingId,
      amount: amount,
      paymentDate: paymentDate,
      note: note,
    ),
  );

  LendingModel _toModel(LendingEntity e) => LendingModel(
    id: e.id,
    userId: e.userId,
    personName: e.personName,
    type: e.type,
    amount: e.amount,
    remainingAmount: e.remainingAmount,
    description: e.description,
    transactionDate: e.transactionDate,
    dueDate: e.dueDate,
    status: e.status,
    createdAt: e.createdAt,
    updatedAt: e.updatedAt,
  );
}
