part of 'lending_bloc.dart';

sealed class LendingEvent extends Equatable {
  const LendingEvent();

  @override
  List<Object?> get props => [];
}

class LendingLoadRequested extends LendingEvent {
  const LendingLoadRequested();
}

class LendingFilterChanged extends LendingEvent {
  final LendingType? type;
  final LendingStatus? status;
  const LendingFilterChanged({this.type, this.status});
  @override
  List<Object?> get props => [type, status];
}

class LendingRecordAdded extends LendingEvent {
  final LendingEntity lending;
  const LendingRecordAdded(this.lending);
  @override
  List<Object?> get props => [lending];
}

class LendingRecordUpdated extends LendingEvent {
  final LendingEntity lending;
  const LendingRecordUpdated(this.lending);
  @override
  List<Object?> get props => [lending];
}

class LendingRecordDeleted extends LendingEvent {
  final String id;
  const LendingRecordDeleted(this.id);
  @override
  List<Object?> get props => [id];
}

class LendingPaymentRecorded extends LendingEvent {
  final String lendingId;
  final double remainingAmount;
  final double amount;
  final DateTime paymentDate;
  final String? note;
  const LendingPaymentRecorded({
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
