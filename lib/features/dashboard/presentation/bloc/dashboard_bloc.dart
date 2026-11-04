import 'package:equatable/equatable.dart';
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
  final DateTime? month;
  const DashboardLoadRequested({this.month});
  @override
  List<Object?> get props => [month];
}

// --- State ---
enum DashboardStatusUi { initial, loading, success, failure }

DateTime _firstOfThisMonth() {
  final n = DateTime.now();
  return DateTime(n.year, n.month, 1);
}

class DashboardState extends Equatable {
  final DashboardStatusUi status;
  final DashboardSummary summary;
  final DateTime selectedMonth;
  final String? errorMessage;

  DashboardState({
    this.status = DashboardStatusUi.initial,
    DashboardSummary? summary,
    DateTime? selectedMonth,
    this.errorMessage,
  }) : selectedMonth = selectedMonth ?? _firstOfThisMonth(),
       summary = summary ?? DashboardSummary.empty(selectedMonth);

  double get balance => summary.balance;

  DashboardState copyWith({
    DashboardStatusUi? status,
    DashboardSummary? summary,
    DateTime? selectedMonth,
    String? errorMessage,
  }) {
    return DashboardState(
      status: status ?? this.status,
      summary: summary ?? this.summary,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, summary, selectedMonth, errorMessage];
}

// --- Bloc ---
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardSummaryUseCase getDashboardSummaryUseCase;

  DashboardBloc({required this.getDashboardSummaryUseCase})
    : super(DashboardState()) {
    on<DashboardLoadRequested>(_onLoad);
  }

  Future<void> _onLoad(
    DashboardLoadRequested event,
    Emitter<DashboardState> emit,
  ) async {
    final month = event.month == null
        ? state.selectedMonth
        : DateTime(event.month!.year, event.month!.month, 1);
    emit(
      state.copyWith(status: DashboardStatusUi.loading, selectedMonth: month),
    );
    final result = await getDashboardSummaryUseCase(month);
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
