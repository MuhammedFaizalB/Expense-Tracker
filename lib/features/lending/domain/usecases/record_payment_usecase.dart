import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/usecase.dart';
import 'package:expense_tracker/features/lending/domain/entities/lending_entity.dart';
import 'package:expense_tracker/features/lending/domain/lending_calculator.dart';
import 'package:expense_tracker/features/lending/domain/repositories/lending_repository.dart';

class RecordPaymentParams extends Equatable {
  final String lendingId;
  final double remainingAmount;
  final double amount;
  final DateTime paymentDate;
  final String? note;

  const RecordPaymentParams({
    required this.lendingId,
    required this.remainingAmount,
    required this.amount,
    required this.paymentDate,
    this.note,
  });

  @override
  List<Object?> get props => [
    lendingId,
    remainingAmount,
    amount,
    paymentDate,
    note,
  ];
}

class RecordPaymentUseCase
    implements UseCase<LendingEntity, RecordPaymentParams> {
  final LendingRepository repository;
  const RecordPaymentUseCase(this.repository);

  @override
  Future<Either<Failure, LendingEntity>> call(
    RecordPaymentParams params,
  ) async {
    final validationError = LendingCalculator.validatePayment(
      remainingAmount: params.remainingAmount,
      paymentAmount: params.amount,
    );
    if (validationError != null) return Left(validationError);

    return repository.recordPayment(
      lendingId: params.lendingId,
      amount: params.amount,
      paymentDate: params.paymentDate,
      note: params.note,
    );
  }
}
