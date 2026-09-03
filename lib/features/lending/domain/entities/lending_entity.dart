import 'package:equatable/equatable.dart';

enum LendingType { lent, borrowed }

enum LendingStatus { pending, partiallyPaid, paid, overdue }

class LendingEntity extends Equatable {
  final String id;
  final String userId;
  final String personName;
  final LendingType type;
  final double amount;
  final double remainingAmount;
  final String? description;
  final DateTime transactionDate;
  final DateTime? dueDate;
  final LendingStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LendingEntity({
    required this.id,
    required this.userId,
    required this.personName,
    required this.type,
    required this.amount,
    required this.remainingAmount,
    required this.transactionDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.dueDate,
  });

  double get amountPaid => amount - remainingAmount;

  LendingStatus get effectiveStatus {
    if (status == LendingStatus.paid) return LendingStatus.paid;
    if (dueDate != null &&
        dueDate!.isBefore(
          DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
          ),
        )) {
      return LendingStatus.overdue;
    }
    return status;
  }

  LendingEntity copyWith({
    String? personName,
    double? amount,
    double? remainingAmount,
    String? description,
    DateTime? transactionDate,
    DateTime? dueDate,
    LendingStatus? status,
    DateTime? updatedAt,
  }) {
    return LendingEntity(
      id: id,
      userId: userId,
      personName: personName ?? this.personName,
      type: type,
      amount: amount ?? this.amount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      description: description ?? this.description,
      transactionDate: transactionDate ?? this.transactionDate,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    personName,
    type,
    amount,
    remainingAmount,
    description,
    transactionDate,
    dueDate,
    status,
    createdAt,
    updatedAt,
  ];
}

class LendingPaymentEntity extends Equatable {
  final String id;
  final String lendingId;
  final double amount;
  final DateTime paymentDate;
  final String? note;
  final DateTime createdAt;

  const LendingPaymentEntity({
    required this.id,
    required this.lendingId,
    required this.amount,
    required this.paymentDate,
    required this.createdAt,
    this.note,
  });

  @override
  List<Object?> get props => [
    id,
    lendingId,
    amount,
    paymentDate,
    note,
    createdAt,
  ];
}
