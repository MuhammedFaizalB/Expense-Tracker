import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/features/lending/domain/entities/lending_entity.dart';

abstract class LendingRepository {
  Future<Either<Failure, List<LendingEntity>>> getLendings({
    LendingType? type,
    LendingStatus? status,
  });
  Future<Either<Failure, LendingEntity>> getLendingById(String id);
  Future<Either<Failure, LendingEntity>> createLending(LendingEntity lending);
  Future<Either<Failure, LendingEntity>> updateLending(LendingEntity lending);
  Future<Either<Failure, void>> deleteLending(String id);

  Future<Either<Failure, List<LendingPaymentEntity>>> getPaymentHistory(
    String lendingId,
  );

  Future<Either<Failure, LendingEntity>> recordPayment({
    required String lendingId,
    required double amount,
    required DateTime paymentDate,
    String? note,
  });
}
