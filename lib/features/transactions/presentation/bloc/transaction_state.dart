part of 'transaction_bloc.dart';

enum TransactionStatusUi { initial, loading, success, failure }

class TransactionState extends Equatable {
  final TransactionStatusUi status;
  final List<TransactionEntity> transactions;
  final TransactionFilter filter;
  final String? errorMessage;

  final int actionId;

  const TransactionState({
    this.status = TransactionStatusUi.initial,
    this.transactions = const [],
    this.filter = const TransactionFilter(),
    this.errorMessage,
    this.actionId = 0,
  });

  bool get isEmpty =>
      status == TransactionStatusUi.success && transactions.isEmpty;

  TransactionState copyWith({
    TransactionStatusUi? status,
    List<TransactionEntity>? transactions,
    TransactionFilter? filter,
    String? errorMessage,
    int? actionId,
  }) {
    return TransactionState(
      status: status ?? this.status,
      transactions: transactions ?? this.transactions,
      filter: filter ?? this.filter,
      errorMessage: errorMessage,
      actionId: actionId ?? this.actionId,
    );
  }

  @override
  List<Object?> get props => [
    status,
    transactions,
    filter,
    errorMessage,
    actionId,
  ];
}
