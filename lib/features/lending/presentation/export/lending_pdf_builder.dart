import 'dart:typed_data';

import 'package:expense_tracker/core/export/export_range.dart';
import 'package:expense_tracker/core/export/pdf_kit.dart';
import 'package:expense_tracker/core/utils/date_formatter.dart';
import 'package:expense_tracker/features/lending/domain/entities/lending_entity.dart';
import 'package:expense_tracker/features/lending/domain/lending_calculator.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class LendingPdfBuilder {
  const LendingPdfBuilder._();

  static const _title = 'Lending Report';

  static Future<Uint8List> build({
    required List<LendingEntity> records,
    required Map<String, List<LendingPaymentEntity>> paymentsByLendingId,
    required ExportRange range,
    required PdfKit kit,
  }) async {
    final generatedOn = DateTime.now();

    final toReceive = LendingCalculator.totalToReceive(records);
    final toPay = LendingCalculator.totalToPay(records);
    final net = LendingCalculator.netBalance(records);
    final settled = net.abs() < 0.005;
    final totalLent = records
        .where((r) => r.type == LendingType.lent)
        .fold(0.0, (s, r) => s + r.amount);
    final totalBorrowed = records
        .where((r) => r.type == LendingType.borrowed)
        .fold(0.0, (s, r) => s + r.amount);

    final groups = <String, List<LendingEntity>>{};
    for (final r in records) {
      groups
          .putIfAbsent(
            r.contactId ?? 'name:${r.personName.trim().toLowerCase()}',
            () => [],
          )
          .add(r);
    }
    final people =
        groups.values.map((rs) {
          rs.sort((a, b) {
            final byDate = a.transactionDate.compareTo(b.transactionDate);
            return byDate != 0 ? byDate : a.createdAt.compareTo(b.createdAt);
          });
          return _Person(
            name: rs.last.personName,
            records: rs,
            net: LendingCalculator.netBalance(rs),
          );
        }).toList()..sort((a, b) {
          final byNet = b.net.abs().compareTo(a.net.abs());
          return byNet != 0
              ? byNet
              : a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });

    final doc = pw.Document(
      theme: kit.theme,
      title: _title,
      author: kit.appName,
      creator: kit.appName,
    );

    final body = <pw.Widget>[
      pw.SizedBox(height: 18),
      kit.cardRow([
        kit.balanceCard(
          label: 'Net balance',
          value:
              '${settled ? '' : (net > 0 ? '+' : '-')}${kit.money(net.abs())}',
          sub: settled
              ? 'All settled'
              : (net > 0 ? 'Owed to you overall' : 'You owe overall'),
        ),
        kit.statCard(
          label: 'You will receive',
          value: kit.money(settled ? 0 : toReceive),
          accent: PdfPalette.income,
          sub: 'Outstanding lent',
        ),
        kit.statCard(
          label: 'You need to pay',
          value: kit.money(settled ? 0 : toPay),
          accent: PdfPalette.expense,
          sub: 'Outstanding borrowed',
        ),
      ]),
      pw.SizedBox(height: 10),
      kit.cardRow([
        kit.statCard(
          label: 'Total lent',
          value: kit.money(totalLent),
          accent: PdfPalette.income,
          sub: 'In this period',
          flex: 1,
        ),
        kit.statCard(
          label: 'Total borrowed',
          value: kit.money(totalBorrowed),
          accent: PdfPalette.expense,
          sub: 'In this period',
          flex: 1,
        ),
        kit.statCard(
          label: 'Records',
          value: '${records.length}',
          accent: PdfPalette.warning,
          sub: '${people.length} ${people.length == 1 ? 'person' : 'people'}',
          flex: 1,
        ),
      ]),
      pw.SizedBox(height: 22),
      kit.sectionTitle('People ledger'),
      pw.SizedBox(height: 8),
    ];

    for (final person in people) {
      final first = person.records.first;
      body.add(
        pw.Column(
          children: [_personHeader(kit, person), _recordRow(kit, first)],
        ),
      );
      body.addAll(
        _paymentRows(kit, first, paymentsByLendingId[first.id] ?? const []),
      );
      for (final r in person.records.skip(1)) {
        body.add(_recordRow(kit, r));
        body.addAll(
          _paymentRows(kit, r, paymentsByLendingId[r.id] ?? const []),
        );
      }
      body.add(pw.SizedBox(height: 14));
    }

    body.add(
      kit.pad(
        pw.Text(
          'Balances show what is still outstanding as of ${DateFormatter.display(generatedOn)}. '
          'Records are listed by the date the money was lent or borrowed.',
          style: kit.ts(8, color: PdfPalette.textSecondary),
        ),
      ),
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
        build: (ctx) => body,
      ),
    );

    return doc.save();
  }

  static pw.Widget _personHeader(PdfKit kit, _Person p) {
    final settled = p.net.abs() < 0.005;
    final color = settled
        ? PdfPalette.textSecondary
        : (p.net > 0 ? PdfPalette.income : PdfPalette.expense);
    final label = settled
        ? 'Settled'
        : (p.net > 0 ? 'You will get' : 'You will give');

    return kit.pad(
      pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: const pw.BoxDecoration(
          color: PdfPalette.surfaceVariant,
          borderRadius: pw.BorderRadius.only(
            topLeft: pw.Radius.circular(10),
            topRight: pw.Radius.circular(10),
          ),
        ),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            kit.initialDot(p.name, PdfPalette.primary, size: 28),
            pw.SizedBox(width: 10),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    p.name,
                    maxLines: 1,
                    overflow: pw.TextOverflow.clip,
                    style: kit.ts(11.5, weight: PdfWeight.bold),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    '${p.records.length} transaction${p.records.length == 1 ? '' : 's'}',
                    style: kit.ts(8, color: PdfPalette.textSecondary),
                  ),
                ],
              ),
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  kit.money(p.net.abs()),
                  style: kit.ts(12, color: color, weight: PdfWeight.bold),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  label,
                  style: kit.ts(8, color: PdfPalette.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _recordRow(PdfKit kit, LendingEntity r) {
    final isLent = r.type == LendingType.lent;
    final status = r.effectiveStatus;
    final isPaid = status == LendingStatus.paid;
    final amountColor = isPaid
        ? PdfPalette.textSecondary
        : (isLent ? PdfPalette.income : PdfPalette.expense);
    final note = (r.description ?? '').trim();
    final title = note.isEmpty ? (isLent ? 'You lent' : 'You borrowed') : note;

    final subParts = <String>[
      isLent ? 'Lent' : 'Borrowed',
      if (r.dueDate != null && !isPaid)
        'Due ${DateFormatter.display(r.dueDate!)}',
    ];

    final (statusLabel, statusColor) = switch (status) {
      LendingStatus.paid => ('PAID', PdfPalette.income),
      LendingStatus.partiallyPaid => ('PARTIAL', PdfPalette.warning),
      LendingStatus.overdue => ('OVERDUE', PdfPalette.expense),
      LendingStatus.pending => ('PENDING', PdfPalette.textSecondary),
    };

    return kit.tableRow(
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 64,
            child: pw.Text(
              DateFormatter.display(r.transactionDate),
              style: kit.ts(8.5, color: PdfPalette.textSecondary),
            ),
          ),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  children: [
                    pw.Flexible(
                      child: pw.Text(
                        title,
                        maxLines: 1,
                        overflow: pw.TextOverflow.clip,
                        style: kit.ts(10, weight: PdfWeight.semiBold),
                      ),
                    ),
                    pw.SizedBox(width: 6),
                    kit.badge(statusLabel, statusColor),
                  ],
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  subParts.join('  ·  '),
                  style: kit.ts(8, color: PdfPalette.textSecondary),
                ),
              ],
            ),
          ),
          pw.SizedBox(
            width: 120,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  kit.money(r.amount),
                  style: kit.ts(
                    10.5,
                    color: amountColor,
                    weight: PdfWeight.bold,
                  ),
                ),
                if (!isPaid && r.amountPaid > 0.005) ...[
                  pw.SizedBox(height: 2),
                  pw.Text(
                    'Paid ${kit.money(r.amountPaid)}',
                    style: kit.ts(8, color: PdfPalette.textSecondary),
                  ),
                ],
                if (!isPaid) ...[
                  pw.SizedBox(height: 2),
                  pw.Text(
                    'Remaining ${kit.money(r.remainingAmount)}',
                    style: kit.ts(8, color: PdfPalette.textSecondary),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static List<pw.Widget> _paymentRows(
    PdfKit kit,
    LendingEntity r,
    List<LendingPaymentEntity> payments,
  ) {
    if (payments.isEmpty) return const [];
    final isLent = r.type == LendingType.lent;
    final sorted = [...payments]
      ..sort((a, b) => a.paymentDate.compareTo(b.paymentDate));

    return sorted.map((p) {
      final note = (p.note ?? '').trim();
      final label = isLent ? 'Received' : 'Paid';
      final text = note.isEmpty
          ? '$label  ·  ${DateFormatter.display(p.paymentDate)}'
          : '$label  ·  ${DateFormatter.display(p.paymentDate)}  ·  $note';
      return kit.tableRow(
        pw.Row(
          children: [
            pw.SizedBox(width: 64),
            pw.Container(
              width: 5,
              height: 5,
              decoration: const pw.BoxDecoration(
                color: PdfPalette.textSecondary,
                shape: pw.BoxShape.circle,
              ),
            ),
            pw.SizedBox(width: 7),
            pw.Expanded(
              child: pw.Text(
                text,
                maxLines: 1,
                overflow: pw.TextOverflow.clip,
                style: kit.ts(8, color: PdfPalette.textSecondary),
              ),
            ),
            pw.SizedBox(
              width: 120,
              child: pw.Text(
                kit.money(p.amount),
                textAlign: pw.TextAlign.right,
                style: kit.ts(
                  8.5,
                  color: PdfPalette.textSecondary,
                  weight: PdfWeight.medium,
                ),
              ),
            ),
          ],
        ),
        vPad: 5,
      );
    }).toList();
  }
}

class _Person {
  final String name;
  final List<LendingEntity> records;
  final double net;
  const _Person({required this.name, required this.records, required this.net});
}
