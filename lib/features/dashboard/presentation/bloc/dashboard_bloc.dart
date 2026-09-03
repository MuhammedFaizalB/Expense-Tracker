import 'package:equatable/equatable.dart';
import 'package:expense_tracker/core/usecase.dart';
import 'package:expense_tracker/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:expense_tracker/features/dashboard/domain/usecases/get_dashboard_summary_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// --- Events ---

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();
  @override
  List<Object?> get props => [];
}

class DashboardLoadRequested extends DashboardEvent {
  const DashboardLoadRequested();
}

// --- State ---
enum DashboardStatusUi { initial, loading, success, failure }

class DashboardState extends Equatable {
  final DashboardStatusUi status;
  final DashboardSummary summary;
  final String? errorMessage;

  const DashboardState({
    this.status = DashboardStatusUi.initial,
    this.summary = const DashboardSummary.empty(),
    this.errorMessage,
  });

  double get balance => summary.balance;

  DashboardState copyWith({
    DashboardStatusUi? status,
    DashboardSummary? summary,
    String? errorMessage,
  }) {
    return DashboardState(
      status: status ?? this.status,
      summary: summary ?? this.summary,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, summary, errorMessage];
}

// --- Bloc ---
/// Goes through GetDashboardSummaryUseCase -> DashboardRepository, same as
/// every other feature — it does not read TransactionRepository/
/// LendingRepository directly (that composition lives in
/// DashboardRepositoryImpl, in the data layer where it belongs).
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardSummaryUseCase getDashboardSummaryUseCase;

  DashboardBloc({required this.getDashboardSummaryUseCase})
    : super(const DashboardState()) {
    on<DashboardLoadRequested>(_onLoad);
  }

  Future<void> _onLoad(
    DashboardLoadRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(status: DashboardStatusUi.loading));
    final result = await getDashboardSummaryUseCase(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: DashboardStatusUi.failure,
          errorMessage: failure.message,
        ),
      ),
      (summary) => emit(
        state.copyWith(
          status: DashboardStatusUi.success,
          summary: summary,
          errorMessage: null,
        ),
      ),
    );
  }
}
