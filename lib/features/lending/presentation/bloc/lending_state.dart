part of 'lending_bloc.dart';

enum LendingStatusUi { initial, loading, success, failure }

class LendingState extends Equatable {
  final LendingStatusUi status;
  final List<LendingEntity> records;
  final LendingType? filterType;
  final LendingStatus? filterStatus;
  final String? errorMessage;

  const LendingState({
    this.status = LendingStatusUi.initial,
    this.records = const [],
    this.filterType,
    this.filterStatus,
    this.errorMessage,
  });

  List<LendingEntity> get filteredRecords => records.where((r) {
    final matchesType = filterType == null || r.type == filterType;
    final matchesStatus =
        filterStatus == null || r.effectiveStatus == filterStatus;
    return matchesType && matchesStatus;
  }).toList();

  double get totalToReceive => LendingCalculator.totalToReceive(records);
  double get totalToPay => LendingCalculator.totalToPay(records);

  bool get isEmpty => status == LendingStatusUi.success && records.isEmpty;

  LendingState copyWith({
    LendingStatusUi? status,
    List<LendingEntity>? records,
    LendingType? filterType,
    LendingStatus? filterStatus,
    String? errorMessage,
    bool clearFilterType = false,
    bool clearFilterStatus = false,
  }) {
    return LendingState(
      status: status ?? this.status,
      records: records ?? this.records,
      filterType: clearFilterType ? null : (filterType ?? this.filterType),
      filterStatus: clearFilterStatus
          ? null
          : (filterStatus ?? this.filterStatus),
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    records,
    filterType,
    filterStatus,
    errorMessage,
  ];
}
