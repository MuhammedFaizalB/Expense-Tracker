part of 'transaction_bloc.dart';

sealed class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

class TransactionLoadRequested extends TransactionEvent {
  const TransactionLoadRequested();
}

class TransactionFilterChanged extends TransactionEvent {
  final TransactionFilter filter;
  const TransactionFilterChanged(this.filter);
  @override
  List<Object?> get props => [filter];
}

class TransactionAdded extends TransactionEvent {
  final TransactionEntity transaction;
  const TransactionAdded(this.transaction);
  @override
  List<Object?> get props => [transaction];
}

class TransactionUpdated extends TransactionEvent {
  final TransactionEntity transaction;
  const TransactionUpdated(this.transaction);
  @override
  List<Object?> get props => [transaction];
}

class TransactionDeleted extends TransactionEvent {
  final String id;
  const TransactionDeleted(this.id);
  @override
  List<Object?> get props => [id];
}
