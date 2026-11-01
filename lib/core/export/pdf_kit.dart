import 'package:expense_tracker/core/constants/app_constants.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/core/utils/date_formatter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfPalette {
  PdfPalette._();
  static const navy = PdfColor.fromInt(0xFF0E1B26);
  static const onNavyMuted = PdfColor.fromInt(0xFF9AA5AD);
  static const primary = PdfColor.fromInt(0xFF22C55E);
  static const gradientStart = PdfColor.fromInt(0xFF1FE0A0);
  static const gradientEnd = PdfColor.fromInt(0xFF0BA968);
  static const background = PdfColor.fromInt(0xFFF6F9F8);
  static const surface = PdfColor.fromInt(0xFFFFFFFF);
  static const surfaceVariant = PdfColor.fromInt(0xFFF0F4F3);
  static const border = PdfColor.fromInt(0xFFE7ECEA);
  static const text = PdfColor.fromInt(0xFF15211E);
  static const textSecondary = PdfColor.fromInt(0xFF77897F);
  static const income = PdfColor.fromInt(0xFF22C55E);
  static const expense = PdfColor.fromInt(0xFFE0435C);
  static const warning = PdfColor.fromInt(0xFFF59E0B);
}

enum PdfWeight { regular, medium, semiBold, bold }

class PdfBreakdownEntry {
  final String name;
  final PdfColor color;
  final double amount;
  const PdfBreakdownEntry({
    required this.name,
    required this.color,
    required this.amount,
  });
}

class PdfKit {
  static const double hPad = 28;
  static const double _cardHeight = 90;
  final pw.Font _regular;
  final pw.Font _medium;
  final pw.Font _semiBold;
  final pw.Font _bold;

  final bool hasRupeeGlyph;

  const PdfKit._(
    this._regular,
    this._medium,
    this._semiBold,
    this._bold,
    this.hasRupeeGlyph,
  );

  static Future<PdfKit> load() async {
    try {
      final fonts = await Future.wait([
        PdfGoogleFonts.interRegular(),
        PdfGoogleFonts.interMedium(),
        PdfGoogleFonts.interSemiBold(),
        PdfGoogleFonts.interBold(),
      ]);
      return PdfKit._(fonts[0], fonts[1], fonts[2], fonts[3], true);
    } catch (_) {
      final regular = pw.Font.helvetica();
      final bold = pw.Font.helveticaBold();
      return PdfKit._(regular, regular, bold, bold, false);
    }
  }

  String get appName => AppConstants.appName;

  pw.ThemeData get theme => pw.ThemeData.withFont(base: _regular, bold: _bold);

  pw.TextStyle ts(
    double size, {
    PdfColor color = PdfPalette.text,
    PdfWeight weight = PdfWeight.regular,
    double? letterSpacing,
  }) {
    final font = switch (weight) {
      PdfWeight.regular => _regular,
      PdfWeight.medium => _medium,
      PdfWeight.semiBold => _semiBold,
      PdfWeight.bold => _bold,
    };
    return pw.TextStyle(
      font: font,
      fontSize: size,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  String money(num value) {
    final formatted = CurrencyFormatter.format(value);
    return hasRupeeGlyph
        ? formatted
        : formatted.replaceAll(CurrencyFormatter.currentSymbol, 'Rs. ');
  }

  static PdfColor tint(PdfColor c, double amount) => PdfColor(
    1 - (1 - c.red) * amount,
    1 - (1 - c.green) * amount,
    1 - (1 - c.blue) * amount,
  );

  pw.Widget pad(pw.Widget child) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: hPad),
    child: child,
  );

  pw.Widget heroHeader({
    required String title,
    required String period,
    required DateTime generatedOn,
  }) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.fromLTRB(hPad, 26, hPad, 24),
      decoration: const pw.BoxDecoration(
        color: PdfPalette.navy,
        borderRadius: pw.BorderRadius.only(
          bottomLeft: pw.Radius.circular(24),
          bottomRight: pw.Radius.circular(24),
        ),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                children: [
                  pw.Container(
                    width: 8,
                    height: 8,
                    decoration: const pw.BoxDecoration(
                      color: PdfPalette.primary,
                      shape: pw.BoxShape.circle,
                    ),
                  ),
                  pw.SizedBox(width: 6),
                  pw.Text(
                    appName.toUpperCase(),
                    style: ts(
                      8,
                      color: PdfPalette.primary,
                      weight: PdfWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Text(
                title,
                style: ts(22, color: PdfColors.white, weight: PdfWeight.bold),
              ),
              pw.SizedBox(height: 4),
              pw.Text(period, style: ts(11, color: PdfPalette.onNavyMuted)),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'Generated on',
                style: ts(8, color: PdfPalette.onNavyMuted),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                DateFormatter.display(generatedOn),
                style: ts(10, color: PdfColors.white, weight: PdfWeight.medium),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget slimHeader({required String title, required String period}) {
    return pw.Container(
      width: double.infinity,
      color: PdfPalette.navy,
      padding: const pw.EdgeInsets.symmetric(horizontal: hPad, vertical: 12),
      margin: const pw.EdgeInsets.only(bottom: 12),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            title,
            style: ts(10, color: PdfColors.white, weight: PdfWeight.bold),
          ),
          pw.Text(period, style: ts(9, color: PdfPalette.onNavyMuted)),
        ],
      ),
    );
  }

  pw.Widget footer(int page, int pages, DateTime generatedOn) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: hPad, vertical: 10),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            '$appName  ·  Exported ${DateFormatter.display(generatedOn)}',
            style: ts(8, color: PdfPalette.textSecondary),
          ),
          pw.Text(
            'Page $page of $pages',
            style: ts(8, color: PdfPalette.textSecondary),
          ),
        ],
      ),
    );
  }

  pw.Widget balanceCard({
    required String label,
    required String value,
    String? sub,
    int flex = 5,
  }) {
    return pw.Expanded(
      flex: flex,
      child: pw.Container(
        height: _cardHeight,
        padding: const pw.EdgeInsets.all(16),
        decoration: pw.BoxDecoration(
          borderRadius: pw.BorderRadius.circular(16),
          gradient: const pw.LinearGradient(
            begin: pw.Alignment.topLeft,
            end: pw.Alignment.bottomRight,
            colors: [PdfPalette.gradientStart, PdfPalette.gradientEnd],
          ),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              label,
              style: ts(9, color: PdfColors.white, weight: PdfWeight.medium),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              value,
              style: ts(20, color: PdfColors.white, weight: PdfWeight.bold),
            ),
            if (sub != null) ...[
              pw.SizedBox(height: 4),
              pw.Text(sub, style: ts(8, color: PdfColors.white)),
            ],
          ],
        ),
      ),
    );
  }

  pw.Widget statCard({
    required String label,
    required String value,
    required PdfColor accent,
    String? sub,
    int flex = 4,
  }) {
    return pw.Expanded(
      flex: flex,
      child: pw.Container(
        height: _cardHeight,
        padding: const pw.EdgeInsets.all(14),
        decoration: pw.BoxDecoration(
          color: PdfPalette.surface,
          border: pw.Border.all(color: PdfPalette.border, width: 0.8),
          borderRadius: pw.BorderRadius.circular(16),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              children: [
                pw.Container(
                  width: 6,
                  height: 6,
                  decoration: pw.BoxDecoration(
                    color: accent,
                    shape: pw.BoxShape.circle,
                  ),
                ),
                pw.SizedBox(width: 5),
                pw.Text(
                  label,
                  style: ts(
                    8.5,
                    color: PdfPalette.textSecondary,
                    weight: PdfWeight.medium,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 8),
            pw.Text(value, style: ts(14, weight: PdfWeight.bold)),
            if (sub != null) ...[
              pw.SizedBox(height: 3),
              pw.Text(sub, style: ts(8, color: PdfPalette.textSecondary)),
            ],
          ],
        ),
      ),
    );
  }

  pw.Widget cardRow(List<pw.Widget> cards) {
    final children = <pw.Widget>[];
    for (var i = 0; i < cards.length; i++) {
      if (i > 0) children.add(pw.SizedBox(width: 10));
      children.add(cards[i]);
    }
    return pad(pw.Row(children: children));
  }

  pw.Widget sectionTitle(String text) {
    return pad(
      pw.Row(
        children: [
          pw.Container(
            width: 3,
            height: 12,
            decoration: pw.BoxDecoration(
              color: PdfPalette.primary,
              borderRadius: pw.BorderRadius.circular(2),
            ),
          ),
          pw.SizedBox(width: 7),
          pw.Text(text, style: ts(12, weight: PdfWeight.bold)),
        ],
      ),
    );
  }

  pw.Widget initialDot(String name, PdfColor color, {double size = 24}) {
    final trimmed = name.trim();
    final letter = trimmed.isEmpty
        ? '?'
        : String.fromCharCode(trimmed.runes.first).toUpperCase();
    return pw.Container(
      width: size,
      height: size,
      alignment: pw.Alignment.center,
      decoration: pw.BoxDecoration(
        color: tint(color, 0.16),
        shape: pw.BoxShape.circle,
      ),
      child: pw.Text(
        letter,
        style: ts(size * 0.42, color: color, weight: PdfWeight.bold),
      ),
    );
  }

  pw.Widget badge(String label, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: pw.BoxDecoration(
        color: tint(color, 0.14),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Text(
        label,
        style: ts(7, color: color, weight: PdfWeight.bold),
      ),
    );
  }

  pw.Widget tableRow(pw.Widget child, {double vPad = 8}) {
    return pad(
      pw.Container(
        padding: pw.EdgeInsets.symmetric(horizontal: 12, vertical: vPad),
        decoration: const pw.BoxDecoration(
          color: PdfPalette.surface,
          border: pw.Border(
            bottom: pw.BorderSide(color: PdfPalette.border, width: 0.6),
          ),
        ),
        child: child,
      ),
    );
  }

  pw.Widget tableHeader(List<pw.Widget> cells) {
    return pad(
      pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: const pw.BoxDecoration(
          color: PdfPalette.surfaceVariant,
          borderRadius: pw.BorderRadius.only(
            topLeft: pw.Radius.circular(8),
            topRight: pw.Radius.circular(8),
          ),
        ),
        child: pw.Row(children: cells),
      ),
    );
  }

  pw.Widget headerCell(String text, {double? width, bool alignRight = false}) {
    final label = pw.Text(
      text.toUpperCase(),
      textAlign: alignRight ? pw.TextAlign.right : pw.TextAlign.left,
      style: ts(
        7,
        color: PdfPalette.textSecondary,
        weight: PdfWeight.bold,
        letterSpacing: 0.6,
      ),
    );
    return width == null
        ? pw.Expanded(child: label)
        : pw.SizedBox(width: width, child: label);
  }

  List<pw.Widget> breakdownSection({
    required String title,
    required List<PdfBreakdownEntry> entries,
    required double total,
  }) {
    if (entries.isEmpty) return const [];
    final sorted = [...entries]..sort((a, b) => b.amount.compareTo(a.amount));
    final maxAmount = sorted.first.amount <= 0 ? 1.0 : sorted.first.amount;

    return [
      sectionTitle(title),
      pw.SizedBox(height: 8),
      ...sorted.map((e) {
        final pct = total <= 0 ? 0 : (e.amount / total * 100).round();
        final filled = (e.amount / maxAmount * 100).round().clamp(2, 100);
        return tableRow(
          pw.Row(
            children: [
              initialDot(e.name, e.color, size: 18),
              pw.SizedBox(width: 8),
              pw.SizedBox(
                width: 105,
                child: pw.Text(
                  e.name,
                  maxLines: 1,
                  overflow: pw.TextOverflow.clip,
                  style: ts(9.5, weight: PdfWeight.medium),
                ),
              ),
              pw.Expanded(
                child: pw.Container(
                  height: 6,
                  decoration: pw.BoxDecoration(
                    color: PdfPalette.surfaceVariant,
                    borderRadius: pw.BorderRadius.circular(3),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Expanded(
                        flex: filled,
                        child: pw.Container(
                          decoration: pw.BoxDecoration(
                            color: e.color,
                            borderRadius: pw.BorderRadius.circular(3),
                          ),
                        ),
                      ),
                      if (filled < 100)
                        pw.Expanded(flex: 100 - filled, child: pw.SizedBox()),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(width: 10),
              pw.SizedBox(
                width: 30,
                child: pw.Text(
                  '$pct%',
                  textAlign: pw.TextAlign.right,
                  style: ts(8.5, color: PdfPalette.textSecondary),
                ),
              ),
              pw.SizedBox(
                width: 80,
                child: pw.Text(
                  money(e.amount),
                  textAlign: pw.TextAlign.right,
                  style: ts(9.5, weight: PdfWeight.semiBold),
                ),
              ),
            ],
          ),
          vPad: 7,
        );
      }),
    ];
  }
}
