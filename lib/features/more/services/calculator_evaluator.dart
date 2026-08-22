import 'dart:math' as math;

/// 无第三方依赖的四则运算解析器，支持括号、平方、开方和百分比。
class CalculatorEvaluator {
  const CalculatorEvaluator();

  double evaluate(String expression) {
    final parser = _ExpressionParser(expression);
    final value = parser.parseExpression();
    parser.ensureEnd();
    if (!value.isFinite) throw const FormatException('结果无效');
    return value;
  }
}

class _ExpressionParser {
  final String _input;
  int _position = 0;
  _ExpressionParser(this._input);

  double parseExpression() {
    var value = _parseTerm();
    while (true) {
      if (_match('+')) {
        value += _parseTerm();
      } else if (_match('-')) {
        value -= _parseTerm();
      } else {
        return value;
      }
    }
  }

  double _parseTerm() {
    var value = _parsePower();
    while (true) {
      if (_match('*')) {
        value *= _parsePower();
      } else if (_match('/')) {
        final divisor = _parsePower();
        if (divisor == 0) throw const FormatException('除数不能为0');
        value /= divisor;
      } else {
        return value;
      }
    }
  }

  double _parsePower() {
    var value = _parseUnary();
    while (_match('^')) {
      value = math.pow(value, _parseUnary()).toDouble();
    }
    return value;
  }

  double _parseUnary() {
    if (_match('-')) return -_parseUnary();
    if (_consumeWord('sqrt')) {
      _expect('(');
      final value = parseExpression();
      _expect(')');
      if (value < 0) throw const FormatException('不能对负数开方');
      return math.sqrt(value);
    }
    return _parsePrimary();
  }

  double _parsePrimary() {
    if (_match('(')) {
      final value = parseExpression();
      _expect(')');
      return value;
    }
    final start = _position;
    var hasDot = false;
    while (_position < _input.length) {
      final char = _input[_position];
      if (_isDigit(char)) {
        _position++;
      } else if (char == '.' && !hasDot) {
        hasDot = true;
        _position++;
      } else {
        break;
      }
    }
    if (start == _position) throw const FormatException('表达式不完整');
    return double.parse(_input.substring(start, _position));
  }

  bool _match(String char) {
    _skipWhitespace();
    if (_position < _input.length && _input[_position] == char) {
      _position++;
      return true;
    }
    return false;
  }

  bool _consumeWord(String word) {
    _skipWhitespace();
    if (_input.startsWith(word, _position)) {
      _position += word.length;
      return true;
    }
    return false;
  }

  void _expect(String char) {
    if (!_match(char)) throw const FormatException('括号不匹配');
  }

  void ensureEnd() {
    _skipWhitespace();
    if (_position != _input.length) throw const FormatException('表达式格式错误');
  }

  void _skipWhitespace() {
    while (_position < _input.length && _input[_position] == ' ') {
      _position++;
    }
  }

  bool _isDigit(String value) =>
      value.codeUnitAt(0) >= 48 && value.codeUnitAt(0) <= 57;
}
