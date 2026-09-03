import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static const String currentSymbol = '₹';
  static const String currentCode = 'INR';

  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: currentSymbol,
    decimalDigits: 2,
  );

  static String format(num amount) => _formatter.format(amount);

  static String formatPlain(num amount) => amount.toStringAsFixed(2);

  static double parse(String input) {
    final cleaned = input.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(cleaned) ?? 0.0;
  }
}
