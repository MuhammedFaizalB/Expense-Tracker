import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/features/lending/domain/entities/lending_entity.dart';

class LendingCalculator {
  const LendingCalculator._();

  static const _epsilon = 0.005;

  static ({double newRemainingAmount, LendingStatus newStatus})? applyPayment({
    required double remainingAmount,
    required double paymentAmount,
  }) {
    if (paymentAmount <= 0) return null;
    if (paymentAmount - remainingAmount > _epsilon) return null;

    final newRemaining = (remainingAmount - paymentAmount).clamp(
      0.0,
      double.infinity,
    );
    final isPaidOff = newRemaining <= _epsilon;

    return (
      newRemainingAmount: isPaidOff ? 0.0 : newRemaining,
      newStatus: isPaidOff ? LendingStatus.paid : LendingStatus.partiallyPaid,
    );
  }

  static Failure? validatePayment({
    required double remainingAmount,
    required double paymentAmount,
  }) {
    if (paymentAmount <= 0) {
      return const ValidationFailure(
        'Payment amount must be greater than zero.',
      );
    }
    if (paymentAmount - remainingAmount > _epsilon) {
      return const InvalidPaymentFailure();
    }
    return null;
  }

  static double totalToReceive(List<LendingEntity> records) {
    return records
        .where(
          (r) => r.type == LendingType.lent && r.status != LendingStatus.paid,
        )
        .fold(0.0, (sum, r) => sum + r.remainingAmount);
  }

  static double totalToPay(List<LendingEntity> records) {
    return records
        .where(
          (r) =>
              r.type == LendingType.borrowed && r.status != LendingStatus.paid,
        )
        .fold(0.0, (sum, r) => sum + r.remainingAmount);
  }
}
