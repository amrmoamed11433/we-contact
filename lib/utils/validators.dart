class Validators {
  const Validators._();

  static String? requiredText(String? value, String message) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  static String? positiveNumber(
    String? value,
    String requiredMessage,
    String invalidMessage,
    String positiveMessage,
  ) {
    final requiredError = requiredText(value, requiredMessage);
    if (requiredError != null) {
      return requiredError;
    }
    final parsed = parseLocalizedDouble(value!);
    if (parsed == null) {
      return invalidMessage;
    }
    if (parsed <= 0) {
      return positiveMessage;
    }
    return null;
  }

  static String? nonNegativeNumber(
    String? value,
    String requiredMessage,
    String invalidMessage,
    String nonNegativeMessage,
  ) {
    final requiredError = requiredText(value, requiredMessage);
    if (requiredError != null) {
      return requiredError;
    }
    final parsed = parseLocalizedDouble(value!);
    if (parsed == null) {
      return invalidMessage;
    }
    if (parsed < 0) {
      return nonNegativeMessage;
    }
    return null;
  }

  static double? parseLocalizedDouble(String value) {
    final normalized = _normalizeDigits(value)
        .replaceAll('٫', '.')
        .replaceAll(',', '.')
        .replaceAll(' ', '');
    return double.tryParse(normalized);
  }

  static String _normalizeDigits(String value) {
    const arabic = '٠١٢٣٤٥٦٧٨٩';
    const easternArabic = '۰۱۲۳۴۵۶۷۸۹';
    final buffer = StringBuffer();

    for (final codeUnit in value.runes) {
      final char = String.fromCharCode(codeUnit);
      final arabicIndex = arabic.indexOf(char);
      final easternIndex = easternArabic.indexOf(char);
      if (arabicIndex != -1) {
        buffer.write(arabicIndex);
      } else if (easternIndex != -1) {
        buffer.write(easternIndex);
      } else {
        buffer.write(char);
      }
    }

    return buffer.toString();
  }
}
