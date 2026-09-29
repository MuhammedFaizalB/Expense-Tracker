import 'package:equatable/equatable.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/usecase.dart';
import 'package:expense_tracker/features/lending/domain/entities/lending_contact_entity.dart';
import 'package:expense_tracker/features/lending/domain/entities/lending_entity.dart';
import 'package:expense_tracker/features/lending/domain/lending_calculator.dart';
import 'package:expense_tracker/features/lending/domain/repositories/lending_repository.dart';
import 'package:expense_tracker/features/lending/domain/usecases/add_lending_usecase.dart';
import 'package:expense_tracker/features/lending/domain/usecases/delete_lending_usecase.dart';
import 'package:expense_tracker/features/lending/domain/usecases/get_lending_contacts_usecase.dart';
import 'package:expense_tracker/features/lending/domain/usecases/get_lendings_usecase.dart';
import 'package:expense_tracker/features/lending/domain/usecases/record_payment_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'lending_event.dart';
part 'lending_state.dart';

class LendingBloc extends Bloc<LendingEvent, LendingState> {
  final GetLendingsUseCase getLendingsUseCase;
  final GetLendingContactsUseCase getLendingContactsUseCase;
  final AddLendingUseCase addLendingUseCase;
  final DeleteLendingUseCase deleteLendingUseCase;
  final RecordPaymentUseCase recordPaymentUseCase;
  final LendingRepository lendingRepository;

  LendingBloc({
    required this.getLendingsUseCase,
    required this.getLendingContactsUseCase,
    required this.addLendingUseCase,
    required this.deleteLendingUseCase,
    required this.recordPaymentUseCase,
    required this.lendingRepository,
  }) : super(const LendingState()) {
    on<LendingLoadRequested>(_onLoadRequested);
    on<LendingContactsLoadRequested>(_onContactsLoadRequested);
    on<LendingFilterChanged>(_onFilterChanged);
    on<LendingRecordAdded>(_onRecordAdded);
    on<LendingRecordUpdated>(_onRecordUpdated);
    on<LendingRecordDeleted>(_onRecordDeleted);
    on<LendingPaymentRecorded>(_onPaymentRecorded);
  }

  Future<void> _onLoadRequested(
    LendingLoadRequested event,
    Emitter<LendingState> emit,
  ) async {
    emit(state.copyWith(status: LendingStatusUi.loading));
    final result = await getLendingsUseCase(const GetLendingsParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: LendingStatusUi.failure,
          errorMessage: failure.message,
        ),
      ),
      (records) => emit(
        state.copyWith(
          status: LendingStatusUi.success,
          records: records,
          errorMessage: null,
        ),
      ),
    );
  }

  Future<void> _onContactsLoadRequested(
    LendingContactsLoadRequested event,
    Emitter<LendingState> emit,
  ) async {
    final result = await getLendingContactsUseCase(const NoParams());
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (contacts) =>
          emit(state.copyWith(contacts: contacts, errorMessage: null)),
    );
  }

  void _onFilterChanged(
    LendingFilterChanged event,
    Emitter<LendingState> emit,
  ) {
    emit(
      state.copyWith(
        filterType: event.type,
        filterStatus: event.status,
        clearFilterType: event.type == null,
        clearFilterStatus: event.status == null,
      ),
    );
  }

  Future<void> _onRecordAdded(
    LendingRecordAdded event,
    Emitter<LendingState> emit,
  ) async {
    final result = await addLendingUseCase(event.lending);
    final created = result.fold<LendingEntity?>(
      (failure) {
        emit(state.copyWith(errorMessage: failure.message));
        return null;
      },
      (created) {
        emit(
          state.copyWith(
            records: [...state.records, created],
            errorMessage: null,
            actionId: state.actionId + 1,
          ),
        );
        return created;
      },
    );
    if (created != null) await _autoSettle(created.contactId, emit);
  }

  Future<void> _onRecordUpdated(
    LendingRecordUpdated event,
    Emitter<LendingState> emit,
  ) async {
    final result = await lendingRepository.updateLending(event.lending);
    final updated = result.fold<LendingEntity?>(
      (failure) {
        emit(state.copyWith(errorMessage: failure.message));
        return null;
      },
      (updated) {
        emit(
          state.copyWith(
            records: state.records
                .map((r) => r.id == updated.id ? updated : r)
                .toList(),
            errorMessage: null,
            actionId: state.actionId + 1,
          ),
        );
        return updated;
      },
    );
    if (updated != null) await _autoSettle(updated.contactId, emit);
  }

  Future<void> _onRecordDeleted(
    LendingRecordDeleted event,
    Emitter<LendingState> emit,
  ) async {
    final result = await deleteLendingUseCase(event.id);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (_) => emit(
        state.copyWith(
          records: state.records.where((r) => r.id != event.id).toList(),
          errorMessage: null,
        ),
      ),
    );
  }

  Future<void> _onPaymentRecorded(
    LendingPaymentRecorded event,
    Emitter<LendingState> emit,
  ) async {
    final result = await recordPaymentUseCase(
      RecordPaymentParams(
        lendingId: event.lendingId,
        remainingAmount: event.remainingAmount,
        amount: event.amount,
        paymentDate: event.paymentDate,
        note: event.note,
      ),
    );
    final updated = result.fold<LendingEntity?>(
      (failure) {
        emit(state.copyWith(errorMessage: failure.message));
        return null;
      },
      (updated) {
        emit(
          state.copyWith(
            records: state.records
                .map((r) => r.id == updated.id ? updated : r)
                .toList(),
            errorMessage: null,
            actionId: state.actionId + 1,
          ),
        );
        return updated;
      },
    );
    if (updated != null) await _autoSettle(updated.contactId, emit);
  }

  Future<void> _autoSettle(
    String? contactId,
    Emitter<LendingState> emit,
  ) async {
    if (contactId == null) return;
    final personRecords = state.records
        .where((r) => r.contactId == contactId)
        .toList();
    if (!LendingCalculator.canAutoSettle(personRecords)) return;

    final now = DateTime.now();
    final open = personRecords
        .where((r) => r.status != LendingStatus.paid)
        .toList();
    for (final r in open) {
      final result = await recordPaymentUseCase(
        RecordPaymentParams(
          lendingId: r.id,
          remainingAmount: r.remainingAmount,
          amount: r.remainingAmount,
          paymentDate: now,
          note: 'Settled against other transactions',
        ),
      );
      final Failure? failure = result.fold((f) => f, (_) => null);
      if (failure != null) {
        emit(state.copyWith(errorMessage: failure.message));
        return;
      }
      final updated = result.fold<LendingEntity?>((_) => null, (u) => u)!;
      emit(
        state.copyWith(
          records: state.records
              .map((x) => x.id == updated.id ? updated : x)
              .toList(),
          errorMessage: null,
        ),
      );
    }
  }
}
