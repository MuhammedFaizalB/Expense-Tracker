import 'package:equatable/equatable.dart';

enum TransactionType { income, expense }

class TransactionEntity extends Equatable {
  final String id;
  final String userId;
  final TransactionType type;
  final double amount;
  final String categoryId;
  final String title;
  final String? description;
  final DateTime transactionDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TransactionEntity({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.categoryId,
    required this.title,
    required this.transactionDate,
    required this.createdAt,
    required this.updatedAt,
    this.description,
  });

  double get signedAmount => type == TransactionType.income ? amount : -amount;

  TransactionEntity copyWith({
    TransactionType? type,
    double? amount,
    String? categoryId,
    String? title,
    String? description,
    DateTime? transactionDate,
    DateTime? updatedAt,
  }) {
    return TransactionEntity(
      id: id,
      userId: userId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      description: description ?? this.description,
      transactionDate: transactionDate ?? this.transactionDate,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    type,
    amount,
    categoryId,
    title,
    description,
    transactionDate,
    createdAt,
    updatedAt,
  ];
}
