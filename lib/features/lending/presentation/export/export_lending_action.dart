import 'package:expense_tracker/core/export/export_range.dart';
import 'package:expense_tracker/core/export/pdf_kit.dart';
import 'package:expense_tracker/core/export/pdf_review_page.dart';
import 'package:expense_tracker/features/lending/domain/entities/lending_entity.dart';
import 'package:expense_tracker/features/lending/domain/repositories/lending_repository.dart';
import 'package:expense_tracker/features/lending/presentation/bloc/lending_bloc.dart';
import 'package:expense_tracker/features/lending/presentation/export/lending_pdf_builder.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> exportLendingPdf(BuildContext context) async {
  final range = await showExportRangeSheet(context, title: 'Export lending');
  if (range == null || !context.mounted) return;

  final records = context
      .read<LendingBloc>()
      .state
      .records
      .where((r) => range.contains(r.transactionDate))
      .toList();
  final repo = context.read<LendingRepository>();
  final messenger = ScaffoldMessenger.of(context);

  if (records.isEmpty) {
    messenger.showSnackBar(
      SnackBar(
        content: Text('No lending records found for ${range.periodText}.'),
      ),
    );
    return;
  }

  try {
    final bytes = await runWithBlockingLoader(context, () async {
      final paymentsByLendingId = <String, List<LendingPaymentEntity>>{};
      await Future.wait(
        records.where((r) => r.amountPaid > 0.005).map((r) async {
          final result = await repo.getPaymentHistory(r.id);
          paymentsByLendingId[r.id] = result.getOrElse(() => const []);
        }),
      );

      final kit = await PdfKit.load();
      return LendingPdfBuilder.build(
        records: records,
        paymentsByLendingId: paymentsByLendingId,
        range: range,
        kit: kit,
      );
    });
    if (!context.mounted) return;

    await openPdfPreview(
      context,
      bytes: bytes,
      fileName: 'FinMonk lending_${range.fileSuffix}.pdf',
      title: 'Lending PDF',
    );
  } catch (e, st) {
    debugPrint('Transactions PDF export failed: $e\n$st');
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          kDebugMode
              ? 'PDF export failed: $e'
              : 'Could not create the PDF. Please try again.',
        ),
      ),
    );
  }
}
