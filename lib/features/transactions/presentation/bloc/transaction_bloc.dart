import 'package:equatable/equatable.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction_entity.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction_filter.dart';
import 'package:expense_tracker/features/transactions/domain/usecases/transaction_usecases.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final GetTransactionsUseCase getTransactionsUseCase;
  final AddTransactionUseCase addTransactionUseCase;
  final UpdateTransactionUseCase updateTransactionUseCase;
  final DeleteTransactionUseCase deleteTransactionUseCase;

  TransactionBloc({
    required this.getTransactionsUseCase,
    required this.addTransactionUseCase,
    required this.updateTransactionUseCase,
    required this.deleteTransactionUseCase,
  }) : super(const TransactionState()) {
    on<TransactionLoadRequested>(_onLoad);
    on<TransactionFilterChanged>(_onFilterChanged);
    on<TransactionAdded>(_onAdded);
    on<TransactionUpdated>(_onUpdated);
    on<TransactionDeleted>(_onDeleted);
  }

  Future<void> _onLoad(
    TransactionLoadRequested event,
    Emitter<TransactionState> emit,
  ) async {
    emit(state.copyWith(status: TransactionStatusUi.loading));
    final result = await getTransactionsUseCase(state.filter);
    result.fold(
      (f) => emit(
        state.copyWith(
          status: TransactionStatusUi.failure,
          errorMessage: f.message,
        ),
      ),
      (list) => emit(
        state.copyWith(
          status: TransactionStatusUi.success,
          transactions: list,
          errorMessage: null,
        ),
      ),
    );
  }

  Future<void> _onFilterChanged(
    TransactionFilterChanged event,
    Emitter<TransactionState> emit,
  ) async {
    emit(
      state.copyWith(filter: event.filter, status: TransactionStatusUi.loading),
    );
    final result = await getTransactionsUseCase(event.filter);
    result.fold(
      (f) => emit(
        state.copyWith(
          status: TransactionStatusUi.failure,
          errorMessage: f.message,
        ),
      ),
      (list) => emit(
        state.copyWith(
          status: TransactionStatusUi.success,
          transactions: list,
          errorMessage: null,
        ),
      ),
    );
  }

  Future<void> _onAdded(
    TransactionAdded event,
    Emitter<TransactionState> emit,
  ) async {
    final result = await addTransactionUseCase(event.transaction);
    result.fold(
      (f) => emit(state.copyWith(errorMessage: f.message)),
      (created) => emit(
        state.copyWith(
          transactions: [created, ...state.transactions],
          errorMessage: null,
          actionId: state.actionId + 1,
        ),
      ),
    );
  }

  Future<void> _onUpdated(
    TransactionUpdated event,
    Emitter<TransactionState> emit,
  ) async {
    final result = await updateTransactionUseCase(event.transaction);
    result.fold(
      (f) => emit(state.copyWith(errorMessage: f.message)),
      (updated) => emit(
        state.copyWith(
          transactions: state.transactions
              .map((t) => t.id == updated.id ? updated : t)
              .toList(),
          errorMessage: null,
          actionId: state.actionId + 1,
        ),
      ),
    );
  }

  Future<void> _onDeleted(
    TransactionDeleted event,
    Emitter<TransactionState> emit,
  ) async {
    final result = await deleteTransactionUseCase(event.id);
    result.fold(
      (f) => emit(state.copyWith(errorMessage: f.message)),
      (_) => emit(
        state.copyWith(
          transactions: state.transactions
              .where((t) => t.id != event.id)
              .toList(),
          errorMessage: null,
        ),
      ),
    );
  }
}
