import 'package:intl/intl.dart';

class CurrencyUtils {
  const CurrencyUtils._();

  static String formatCurrency(
    double amount,
    String localeCode,
    String currencyLabel,
  ) {
    final decimalDigits = amount.truncateToDouble() == amount ? 0 : 2;
    final formatter = NumberFormat.currency(
      locale: localeCode,
      symbol: '',
      decimalDigits: decimalDigits,
    );
    return '${formatter.format(amount).trim()} $currencyLabel';
  }

  static String formatNumber(double value, String localeCode) {
    final decimalDigits = value.truncateToDouble() == value ? 0 : 2;
    final formatter = NumberFormat.decimalPattern(localeCode)
      ..minimumFractionDigits = decimalDigits
      ..maximumFractionDigits = decimalDigits;
    return formatter.format(value);
  }

  static String formatPercent(double value, String localeCode) {
    final formatter = NumberFormat.decimalPattern(localeCode)
      ..minimumFractionDigits = 1
      ..maximumFractionDigits = 1;
    return formatter.format(value);
  }
}
