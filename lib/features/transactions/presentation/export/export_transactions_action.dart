import 'package:expense_tracker/core/export/export_range.dart';
import 'package:expense_tracker/core/export/pdf_kit.dart';
import 'package:expense_tracker/core/export/pdf_review_page.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction_entity.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction_filter.dart';
import 'package:expense_tracker/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:expense_tracker/features/transactions/presentation/export/transactions_pdf_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Supabase/PostgREST returns at most this many rows per request by default.
const _apiRowLimit = 1000;

/// Asks for a period, fetches that period's transactions straight from the
/// repository (so the export is independent of the on-screen tab/search),
/// builds the PDF and opens the preview.
Future<void> exportTransactionsPdf(BuildContext context) async {
  final range = await showExportRangeSheet(
    context,
    title: 'Export transactions',
  );
  if (range == null || !context.mounted) return;

  final repo = context.read<TransactionRepository>();
  final categoriesById = {
    for (final c in context.read<CategoryBloc>().state.categories) c.id: c,
  };
  final messenger = ScaffoldMessenger.of(context);

  try {
    final fetched = await runWithBlockingLoader(
      context,
      () => repo.getTransactions(
        TransactionFilter(
          startDate: range.range?.start,
          endDate: range.range?.end,
          sort: TransactionSort.dateDesc,
        ),
      ),
    );
    if (!context.mounted) return;

    final error = fetched.fold<String?>(
      (failure) => failure.message,
      (_) => null,
    );
    if (error != null) {
      messenger.showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    final List<TransactionEntity> transactions = fetched.getOrElse(
      () => const [],
    );
    if (transactions.isEmpty) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('No transactions found for ${range.periodText}.'),
        ),
      );
      return;
    }

    final bytes = await runWithBlockingLoader(context, () async {
      final kit = await PdfKit.load();
      return TransactionsPdfBuilder.build(
        transactions: transactions,
        categoriesById: categoriesById,
        range: range,
        kit: kit,
      );
    });
    if (!context.mounted) return;

    if (transactions.length >= _apiRowLimit) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Only the first 1,000 transactions are included. Pick a shorter period to export the rest.',
          ),
        ),
      );
    }

    await openPdfPreview(
      context,
      bytes: bytes,
      fileName: 'FinMonk transactions_${range.fileSuffix}.pdf',
      title: 'Transactions PDF',
    );
  } catch (e, st) {
    debugPrint('Transactions PDF export failed: $e\n$st');
    messenger.showSnackBar(
      SnackBar(content: Text('Could not create the PDF: ${_shortReason(e)}')),
    );
  }
}

String _shortReason(Object e) {
  final text = e.toString().split('\n').first.trim();
  return text.length > 140 ? '${text.substring(0, 140)}…' : text;
}
