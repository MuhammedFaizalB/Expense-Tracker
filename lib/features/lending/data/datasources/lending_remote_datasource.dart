import 'package:expense_tracker/core/constants/app_constants.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/features/lending/data/models/lending_model.dart';
import 'package:expense_tracker/features/lending/domain/entities/lending_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class LendingRemoteDataSource {
  Future<List<LendingModel>> getLendings({
    LendingType? type,
    LendingStatus? status,
  });
  Future<LendingModel> getLendingById(String id);
  Future<LendingModel> createLending(LendingModel lending);
  Future<LendingModel> updateLending(LendingModel lending);
  Future<void> deleteLending(String id);
  Future<List<LendingPaymentModel>> getPaymentHistory(String lendingId);
  Future<LendingModel> recordPayment({
    required String lendingId,
    required double amount,
    required DateTime paymentDate,
    String? note,
  });
}

class LendingRemoteDataSourceImpl implements LendingRemoteDataSource {
  final SupabaseClient client;
  const LendingRemoteDataSourceImpl(this.client);

  @override
  Future<List<LendingModel>> getLendings({
    LendingType? type,
    LendingStatus? status,
  }) async {
    try {
      var query = client.from(SupabaseTables.lendings).select();
      if (type != null) query = query.eq('type', LendingModel.typeToJson(type));
      if (status != null) {
        query = query.eq('status', LendingModel.statusToJson(status));
      }
      final rows = await query.order('due_date', ascending: true);
      return (rows as List)
          .map((r) => LendingModel.fromJson(r as Map<String, dynamic>))
          .toList();
    } catch (_) {
      throw const ServerException('Could not load lending records.');
    }
  }

  @override
  Future<LendingModel> getLendingById(String id) async {
    try {
      final row = await client
          .from(SupabaseTables.lendings)
          .select()
          .eq('id', id)
          .single();
      return LendingModel.fromJson(row);
    } catch (_) {
      throw const NotFoundException('Lending record not found.');
    }
  }

  @override
  Future<LendingModel> createLending(LendingModel lending) async {
    try {
      final row = await client
          .from(SupabaseTables.lendings)
          .insert(lending.toInsertJson())
          .select()
          .single();
      return LendingModel.fromJson(row);
    } catch (_) {
      throw const ServerException('Could not save the record.');
    }
  }

  @override
  Future<LendingModel> updateLending(LendingModel lending) async {
    try {
      final row = await client
          .from(SupabaseTables.lendings)
          .update(lending.toInsertJson())
          .eq('id', lending.id)
          .select()
          .single();
      return LendingModel.fromJson(row);
    } catch (_) {
      throw const ServerException('Could not update the record.');
    }
  }

  @override
  Future<void> deleteLending(String id) async {
    try {
      await client.from(SupabaseTables.lendings).delete().eq('id', id);
    } catch (_) {
      throw const ServerException('Could not delete the record.');
    }
  }

  @override
  Future<List<LendingPaymentModel>> getPaymentHistory(String lendingId) async {
    try {
      final rows = await client
          .from(SupabaseTables.lendingPayments)
          .select()
          .eq('lending_id', lendingId)
          .order('payment_date', ascending: false);
      return (rows as List)
          .map((r) => LendingPaymentModel.fromJson(r as Map<String, dynamic>))
          .toList();
    } catch (_) {
      throw const ServerException('Could not load payment history.');
    }
  }

  @override
  Future<LendingModel> recordPayment({
    required String lendingId,
    required double amount,
    required DateTime paymentDate,
    String? note,
  }) async {
    try {
      final row = await client.rpc(
        'record_lending_payment',
        params: {
          'p_lending_id': lendingId,
          'p_amount': amount,
          'p_payment_date': paymentDate.toIso8601String().split('T').first,
          'p_note': note,
        },
      );
      final updatedLending = (row as List).first as Map<String, dynamic>;
      return LendingModel.fromJson(updatedLending);
    } on PostgrestException catch (e) {
      if (e.message.contains('exceeds remaining')) {
        throw const ServerException(
          'Payment amount exceeds the remaining balance.',
        );
      }
      throw const ServerException('Could not record the payment.');
    } catch (_) {
      throw const ServerException('Could not record the payment.');
    }
  }
}
