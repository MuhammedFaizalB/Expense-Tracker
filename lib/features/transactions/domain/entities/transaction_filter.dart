import 'package:equatable/equatable.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction_entity.dart';

enum TransactionSort { dateDesc, dateAsc, amountDesc, amountAsc }

class TransactionFilter extends Equatable {
  final TransactionType? type;
  final String? categoryId;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? searchQuery;
  final TransactionSort sort;

  const TransactionFilter({
    this.type,
    this.categoryId,
    this.startDate,
    this.endDate,
    this.searchQuery,
    this.sort = TransactionSort.dateDesc,
  });

  factory TransactionFilter.currentMonth() =>
      TransactionFilter.forMonth(DateTime.now());

  factory TransactionFilter.forMonth(DateTime month) => TransactionFilter(
    startDate: DateTime(month.year, month.month, 1),
    endDate: DateTime(month.year, month.month + 1, 0),
  );

  bool matches(TransactionEntity t) {
    if (type != null && t.type != type) return false;
    if (categoryId != null && t.categoryId != categoryId) return false;
    final day = DateTime(
      t.transactionDate.year,
      t.transactionDate.month,
      t.transactionDate.day,
    );
    if (startDate != null &&
        day.isBefore(
          DateTime(startDate!.year, startDate!.month, startDate!.day),
        )) {
      return false;
    }
    if (endDate != null &&
        day.isAfter(DateTime(endDate!.year, endDate!.month, endDate!.day))) {
      return false;
    }
    final q = searchQuery?.trim().toLowerCase() ?? '';
    if (q.isNotEmpty && !t.title.toLowerCase().contains(q)) return false;
    return true;
  }

  TransactionFilter copyWith({
    TransactionType? type,
    String? categoryId,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    TransactionSort? sort,
    bool clearType = false,
    bool clearCategory = false,
    bool clearDates = false,
    bool clearSearch = false,
  }) {
    return TransactionFilter(
      type: clearType ? null : (type ?? this.type),
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      startDate: clearDates ? null : (startDate ?? this.startDate),
      endDate: clearDates ? null : (endDate ?? this.endDate),
      searchQuery: clearSearch ? null : (searchQuery ?? this.searchQuery),
      sort: sort ?? this.sort,
    );
  }

  @override
  List<Object?> get props => [
    type,
    categoryId,
    startDate,
    endDate,
    searchQuery,
    sort,
  ];
}
