import 'package:expense_tracker/features/lending/domain/entities/lending_entity.dart';

class LendingModel extends LendingEntity {
  const LendingModel({
    required super.id,
    required super.userId,
    required super.personName,
    required super.type,
    required super.amount,
    required super.remainingAmount,
    required super.transactionDate,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
    super.description,
    super.dueDate,
  });

  factory LendingModel.fromJson(Map<String, dynamic> json) {
    return LendingModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      personName: json['person_name'] as String,
      type: json['type'] == 'lent' ? LendingType.lent : LendingType.borrowed,
      amount: (json['amount'] as num).toDouble(),
      remainingAmount: (json['remaining_amount'] as num).toDouble(),
      description: json['description'] as String?,
      transactionDate: DateTime.parse(json['lent_or_borrowed_date'] as String),
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      status: _statusFromJson(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  static LendingStatus _statusFromJson(String value) {
    switch (value) {
      case 'partially_paid':
        return LendingStatus.partiallyPaid;
      case 'paid':
        return LendingStatus.paid;
      case 'overdue':
        return LendingStatus.overdue;
      default:
        return LendingStatus.pending;
    }
  }

  static String typeToJson(LendingType type) =>
      type == LendingType.lent ? 'lent' : 'borrowed';

  static String statusToJson(LendingStatus status) => switch (status) {
    LendingStatus.pending => 'pending',
    LendingStatus.partiallyPaid => 'partially_paid',
    LendingStatus.paid => 'paid',
    LendingStatus.overdue => 'overdue',
  };

  Map<String, dynamic> toInsertJson() => {
    'person_name': personName,
    'type': LendingModel.typeToJson(type),
    'amount': amount,
    'remaining_amount': remainingAmount,
    'description': description,
    'lent_or_borrowed_date': transactionDate.toIso8601String().split('T').first,
    'due_date': dueDate?.toIso8601String().split('T').first,
    'status': LendingModel.statusToJson(status),
  };
}

class LendingPaymentModel extends LendingPaymentEntity {
  const LendingPaymentModel({
    required super.id,
    required super.lendingId,
    required super.amount,
    required super.paymentDate,
    required super.createdAt,
    super.note,
  });

  factory LendingPaymentModel.fromJson(Map<String, dynamic> json) {
    return LendingPaymentModel(
      id: json['id'] as String,
      lendingId: json['lending_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      paymentDate: DateTime.parse(json['payment_date'] as String),
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
