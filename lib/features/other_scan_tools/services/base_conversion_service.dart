/// Pure conversion logic matching Android ConversionActivity's four fields.
class BaseConversionService {
  const BaseConversionService();

  Map<int, String> convert(String value, int sourceBase) {
    if (value.trim().isEmpty) {
      return const {10: '', 2: '', 8: '', 16: ''};
    }
    final number = _parse(value.trim(), sourceBase);
    if (number == null) {
      return const {10: '', 2: '', 8: '', 16: ''};
    }
    return {
      10: _format(number, 10),
      2: _format(number, 2),
      8: _format(number, 8),
      16: _format(number, 16).toUpperCase(),
    };
  }

  double? _parse(String value, int radix) {
    final parts = value.split('.');
    if (parts.length > 2 || parts.first.isEmpty && parts.length == 1) {
      return null;
    }
    final sign = parts.first.startsWith('-') ? -1 : 1;
    final integer = parts.first.replaceFirst('-', '');
    if (integer.isEmpty && (parts.length == 1 || parts[1].isEmpty)) {
      return null;
    }
    final whole = int.tryParse(integer.isEmpty ? '0' : integer, radix: radix);
    if (whole == null) {
      return null;
    }
    var fraction = 0.0;
    if (parts.length == 2) {
      for (var index = 0; index < parts[1].length; index++) {
        final digit = int.tryParse(parts[1][index], radix: radix);
        if (digit == null) {
          return null;
        }
        fraction += digit / _pow(radix, index + 1);
      }
    }
    return sign * (whole + fraction);
  }

  String _format(double value, int radix) {
    final negative = value < 0;
    final absolute = value.abs();
    final whole = absolute.truncate();
    var result = whole.toRadixString(radix);
    var fractional = absolute - whole;
    if (fractional > 0) {
      final digits = StringBuffer();
      for (var index = 0; index < 16 && fractional > 0.000000001; index++) {
        fractional *= radix;
        final digit = fractional.truncate();
        digits.write(digit.toRadixString(radix));
        fractional -= digit;
      }
      result = '$result.$digits';
    }
    return negative ? '-$result' : result;
  }

  double _pow(int base, int exponent) {
    var result = 1.0;
    for (var index = 0; index < exponent; index++) {
      result *= base;
    }
    return result;
  }
}
