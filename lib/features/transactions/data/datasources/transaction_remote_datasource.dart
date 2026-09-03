import 'package:expense_tracker/core/constants/app_constants.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/features/transactions/data/models/transaction_model.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction_entity.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction_filter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class TransactionRemoteDataSource {
  Future<List<TransactionModel>> getTransactions(TransactionFilter filter);
  Future<TransactionModel> getTransactionById(String id);
  Future<TransactionModel> createTransaction(TransactionModel transaction);
  Future<TransactionModel> updateTransaction(TransactionModel transaction);
  Future<void> deleteTransaction(String id);
  Future<({double income, double expense})> getTotals({
    DateTime? start,
    DateTime? end,
  });
}

class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  final SupabaseClient client;
  const TransactionRemoteDataSourceImpl(this.client);

  @override
  Future<List<TransactionModel>> getTransactions(
    TransactionFilter filter,
  ) async {
    try {
      var query = client.from(SupabaseTables.transactions).select();
      if (filter.type != null) {
        query = query.eq(
          'type',
          filter.type == TransactionType.income ? 'income' : 'expense',
        );
      }
      if (filter.categoryId != null) {
        query = query.eq('category_id', filter.categoryId!);
      }
      if (filter.startDate != null) {
        query = query.gte(
          'transaction_date',
          filter.startDate!.toIso8601String().split('T').first,
        );
      }
      if (filter.endDate != null) {
        query = query.lte(
          'transaction_date',
          filter.endDate!.toIso8601String().split('T').first,
        );
      }
      if (filter.searchQuery != null && filter.searchQuery!.trim().isNotEmpty) {
        query = query.ilike('title', '%${filter.searchQuery!.trim()}%');
      }

      final (column, ascending) = switch (filter.sort) {
        TransactionSort.dateDesc => ('transaction_date', false),
        TransactionSort.dateAsc => ('transaction_date', true),
        TransactionSort.amountDesc => ('amount', false),
        TransactionSort.amountAsc => ('amount', true),
      };

      final rows = await query.order(column, ascending: ascending);
      return (rows as List)
          .map((r) => TransactionModel.fromJson(r as Map<String, dynamic>))
          .toList();
    } catch (_) {
      throw const ServerException('Could not load transactions.');
    }
  }

  @override
  Future<TransactionModel> getTransactionById(String id) async {
    try {
      final row = await client
          .from(SupabaseTables.transactions)
          .select()
          .eq('id', id)
          .single();
      return TransactionModel.fromJson(row);
    } catch (_) {
      throw const NotFoundException('Transaction not found.');
    }
  }

  @override
  Future<TransactionModel> createTransaction(
    TransactionModel transaction,
  ) async {
    try {
      final row = await client
          .from(SupabaseTables.transactions)
          .insert(transaction.toInsertJson())
          .select()
          .single();
      return TransactionModel.fromJson(row);
    } catch (_) {
      throw const ServerException('Could not save the transaction.');
    }
  }

  @override
  Future<TransactionModel> updateTransaction(
    TransactionModel transaction,
  ) async {
    try {
      final row = await client
          .from(SupabaseTables.transactions)
          .update(transaction.toInsertJson())
          .eq('id', transaction.id)
          .select()
          .single();
      return TransactionModel.fromJson(row);
    } catch (_) {
      throw const ServerException('Could not update the transaction.');
    }
  }

  @override
  Future<void> deleteTransaction(String id) async {
    try {
      await client.from(SupabaseTables.transactions).delete().eq('id', id);
    } catch (_) {
      throw const ServerException('Could not delete the transaction.');
    }
  }

  @override
  Future<({double income, double expense})> getTotals({
    DateTime? start,
    DateTime? end,
  }) async {
    try {
      var query = client
          .from(SupabaseTables.transactions)
          .select('type, amount');
      if (start != null) {
        query = query.gte(
          'transaction_date',
          start.toIso8601String().split('T').first,
        );
      }
      if (end != null) {
        query = query.lte(
          'transaction_date',
          end.toIso8601String().split('T').first,
        );
      }
      final rows = await query as List;

      double income = 0, expense = 0;
      for (final r in rows) {
        final amount = (r['amount'] as num).toDouble();
        if (r['type'] == 'income') {
          income += amount;
        } else {
          expense += amount;
        }
      }
      return (income: income, expense: expense);
    } catch (_) {
      throw const ServerException('Could not calculate totals.');
    }
  }
}
