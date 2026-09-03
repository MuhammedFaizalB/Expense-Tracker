import 'package:expense_tracker/features/transactions/domain/entities/transaction_entity.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.userId,
    required super.type,
    required super.amount,
    required super.categoryId,
    required super.title,
    required super.transactionDate,
    required super.createdAt,
    required super.updatedAt,
    super.description,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: json['type'] == 'income'
          ? TransactionType.income
          : TransactionType.expense,
      amount: (json['amount'] as num).toDouble(),
      categoryId: json['category_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      transactionDate: DateTime.parse(json['transaction_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toInsertJson() => {
    'type': type == TransactionType.income ? 'income' : 'expense',
    'amount': amount,
    'category_id': categoryId,
    'title': title,
    'description': description,
    'transaction_date': transactionDate.toIso8601String().split('T').first,
  };
}
