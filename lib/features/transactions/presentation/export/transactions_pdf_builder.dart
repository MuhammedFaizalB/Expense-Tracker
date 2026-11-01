import 'dart:typed_data';

import 'package:expense_tracker/core/export/export_range.dart';
import 'package:expense_tracker/core/export/pdf_kit.dart';
import 'package:expense_tracker/core/utils/date_formatter.dart';
import 'package:expense_tracker/features/categories/domain/entities/category_entity.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction_entity.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class TransactionsPdfBuilder {
  const TransactionsPdfBuilder._();

  static const _title = 'Transactions Report';

  static Future<Uint8List> build({
    required List<TransactionEntity> transactions,
    required Map<String, CategoryEntity> categoriesById,
    required ExportRange range,
    required PdfKit kit,
  }) async {
    final generatedOn = DateTime.now();

    final sorted = [...transactions]
      ..sort((a, b) {
        final byDate = b.transactionDate.compareTo(a.transactionDate);
        return byDate != 0 ? byDate : b.createdAt.compareTo(a.createdAt);
      });

    var income = 0.0;
    var expense = 0.0;
    var incomeCount = 0;
    var expenseCount = 0;
    final incomeByCategory = <String, double>{};
    final expenseByCategory = <String, double>{};
    for (final t in sorted) {
      if (t.type == TransactionType.income) {
        income += t.amount;
        incomeCount++;
        incomeByCategory.update(
          t.categoryId,
          (v) => v + t.amount,
          ifAbsent: () => t.amount,
        );
      } else {
        expense += t.amount;
        expenseCount++;
        expenseByCategory.update(
          t.categoryId,
          (v) => v + t.amount,
          ifAbsent: () => t.amount,
        );
      }
    }
    final net = income - expense;
    final settled = net.abs() < 0.005;

    PdfColor colorOf(String categoryId) {
      final c = categoriesById[categoryId];
      return c == null ? PdfPalette.textSecondary : PdfColor.fromInt(c.color);
    }

    String nameOf(String categoryId) =>
        categoriesById[categoryId]?.name ?? 'Uncategorised';

    List<PdfBreakdownEntry> entriesOf(Map<String, double> byCategory) =>
        byCategory.entries
            .map(
              (e) => PdfBreakdownEntry(
                name: nameOf(e.key),
                color: colorOf(e.key),
                amount: e.value,
              ),
            )
            .toList();

    final doc = pw.Document(
      theme: kit.theme,
      title: _title,
      author: kit.appName,
      creator: kit.appName,
    );

    doc.addPage(
      pw.MultiPage(
        maxPages: 2000,
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.only(bottom: 24),
          buildBackground: (_) => pw.FullPage(
            ignoreMargins: true,
            child: pw.Container(color: PdfPalette.background),
          ),
        ),
        header: (ctx) => ctx.pageNumber == 1
            ? kit.heroHeader(
                title: _title,
                period: range.periodText,
                generatedOn: generatedOn,
              )
            : kit.slimHeader(title: _title, period: range.periodText),
        footer: (ctx) =>
            kit.footer(ctx.pageNumber, ctx.pagesCount, generatedOn),
        build: (ctx) => [
          pw.SizedBox(height: 18),
          kit.cardRow([
            kit.balanceCard(
              label: 'Net balance',
              value:
                  '${settled ? '' : (net > 0 ? '+' : '-')}${kit.money(net.abs())}',
              sub:
                  '${sorted.length} transaction${sorted.length == 1 ? '' : 's'}',
            ),
            kit.statCard(
              label: 'Income',
              value: kit.money(income),
              accent: PdfPalette.income,
              sub: '$incomeCount transaction${incomeCount == 1 ? '' : 's'}',
            ),
            kit.statCard(
              label: 'Expenses',
              value: kit.money(expense),
              accent: PdfPalette.expense,
              sub: '$expenseCount transaction${expenseCount == 1 ? '' : 's'}',
            ),
          ]),
          if (expenseByCategory.isNotEmpty) ...[
            pw.SizedBox(height: 22),
            ...kit.breakdownSection(
              title: 'Spending by category',
              entries: entriesOf(expenseByCategory),
              total: expense,
            ),
          ],
          if (incomeByCategory.isNotEmpty) ...[
            pw.SizedBox(height: 22),
            ...kit.breakdownSection(
              title: 'Income by category',
              entries: entriesOf(incomeByCategory),
              total: income,
            ),
          ],
          pw.SizedBox(height: 22),
          kit.sectionTitle('All transactions'),
          pw.SizedBox(height: 8),
          kit.tableHeader([
            pw.SizedBox(width: 34),
            kit.headerCell('Transaction'),
            kit.headerCell('Date', width: 70, alignRight: true),
            kit.headerCell('Amount', width: 90, alignRight: true),
          ]),
          ...sorted.map(
            (t) => _transactionRow(
              kit,
              t,
              nameOf(t.categoryId),
              colorOf(t.categoryId),
            ),
          ),
          pw.SizedBox(height: 14),
          kit.pad(
            pw.Center(
              child: pw.Text(
                'End of report  ·  ${sorted.length} transaction${sorted.length == 1 ? '' : 's'}',
                style: kit.ts(8, color: PdfPalette.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );

    return doc.save();
  }

  static pw.Widget _transactionRow(
    PdfKit kit,
    TransactionEntity t,
    String categoryName,
    PdfColor categoryColor,
  ) {
    final isIncome = t.type == TransactionType.income;
    final note = (t.description ?? '').trim();
    final subtitle = note.isEmpty ? categoryName : '$categoryName  ·  $note';

    return kit.tableRow(
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          kit.initialDot(categoryName, categoryColor),
          pw.SizedBox(width: 10),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  t.title,
                  maxLines: 1,
                  overflow: pw.TextOverflow.clip,
                  style: kit.ts(10, weight: PdfWeight.semiBold),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  subtitle,
                  maxLines: 1,
                  overflow: pw.TextOverflow.clip,
                  style: kit.ts(8, color: PdfPalette.textSecondary),
                ),
              ],
            ),
          ),
          pw.SizedBox(
            width: 70,
            child: pw.Text(
              DateFormatter.display(t.transactionDate),
              textAlign: pw.TextAlign.right,
              style: kit.ts(8.5, color: PdfPalette.textSecondary),
            ),
          ),
          pw.SizedBox(
            width: 90,
            child: pw.Text(
              '${isIncome ? '+' : '-'}${kit.money(t.amount)}',
              textAlign: pw.TextAlign.right,
              style: kit.ts(
                10.5,
                color: isIncome ? PdfPalette.income : PdfPalette.expense,
                weight: PdfWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
