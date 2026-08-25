/// 对齐 Android StandardFragment 支持的四则运算、括号、平方和开方。
class CalculatorEngine {
  static double evaluate(String expression) {
    final parser = _ExpressionParser(expression);
    final value = parser.parseExpression();
    if (!parser.isAtEnd) throw const FormatException('表达式不完整');
    if (value.isInfinite || value.isNaN) throw const FormatException('无法计算');
    return value;
  }

  static String format(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value
        .toStringAsPrecision(12)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }
}

class _ExpressionParser {
  _ExpressionParser(this._input);

  final String _input;
  int _position = 0;

  bool get isAtEnd => _position >= _input.length;

  double parseExpression() {
    var value = _parseTerm();
    while (true) {
      if (_consume('+')) {
        value += _parseTerm();
      } else if (_consume('-')) {
        value -= _parseTerm();
      } else {
        return value;
      }
    }
  }

  double _parseTerm() {
    var value = _parsePower();
    while (true) {
      if (_consume('*')) {
        value *= _parsePower();
      } else if (_consume('/')) {
        final divisor = _parsePower();
        if (divisor == 0) throw const FormatException('除数不能为 0');
        value /= divisor;
      } else {
        return value;
      }
    }
  }

  double _parsePower() {
    var value = _parseUnary();
    if (_consume('^')) {
      value = _pow(value, _parsePower());
    }
    return value;
  }

  double _parseUnary() {
    if (_consume('-')) return -_parseUnary();
    if (_consumeWord('sqrt')) {
      _expect('(');
      final value = parseExpression();
      _expect(')');
      if (value < 0) throw const FormatException('负数不能开方');
      return _sqrt(value);
    }
    if (_consume('(')) {
      final value = parseExpression();
      _expect(')');
      return value;
    }
    return _parseNumber();
  }

  double _parseNumber() {
    final start = _position;
    while (!isAtEnd && (RegExp(r'[0-9.]').hasMatch(_input[_position]))) {
      _position++;
    }
    if (start == _position) throw const FormatException('请输入数字');
    return double.parse(_input.substring(start, _position));
  }

  bool _consume(String token) {
    if (!isAtEnd && _input.startsWith(token, _position)) {
      _position += token.length;
      return true;
    }
    return false;
  }

  bool _consumeWord(String word) => _consume(word);

  void _expect(String token) {
    if (!_consume(token)) throw const FormatException('括号不匹配');
  }

  double _sqrt(double value) => value == 0 ? 0 : _pow(value, 0.5);

  double _pow(double base, double exponent) {
    if (base == 0 && exponent < 0) throw const FormatException('无法计算');
    // Dart 核心库没有 pow，指数运算沿用整数快速幂并处理常用平方根。
    if (exponent == 0.5) {
      var guess = base / 2;
      if (guess == 0) return 0;
      for (var i = 0; i < 20; i++) {
        guess = (guess + base / guess) / 2;
      }
      return guess;
    }
    if (exponent != exponent.roundToDouble()) {
      throw const FormatException('暂不支持该指数');
    }
    var count = exponent.abs().toInt();
    var factor = base;
    var result = 1.0;
    while (count > 0) {
      if (count.isOdd) result *= factor;
      factor *= factor;
      count ~/= 2;
    }
    return exponent < 0 ? 1 / result : result;
  }
}
