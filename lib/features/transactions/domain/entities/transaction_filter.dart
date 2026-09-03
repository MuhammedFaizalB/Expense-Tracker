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
