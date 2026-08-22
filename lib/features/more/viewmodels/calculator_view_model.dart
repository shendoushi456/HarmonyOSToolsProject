import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/calculator_evaluator.dart';
import 'calculator_state.dart';

final calculatorViewModelProvider =
    NotifierProvider<CalculatorViewModel, CalculatorState>(
        CalculatorViewModel.new);

class CalculatorViewModel extends Notifier<CalculatorState> {
  static const _operators = '+-*/^';
  final CalculatorEvaluator _evaluator = const CalculatorEvaluator();

  @override
  CalculatorState build() => const CalculatorState.initial();

  void input(String value) {
    var expression = state.hasError ? '' : state.expression;
    if (_operators.contains(value)) {
      if (expression.isEmpty && value != '-') return;
      if (expression.isNotEmpty &&
          _operators.contains(expression[expression.length - 1])) {
        expression = expression.substring(0, expression.length - 1);
      }
    }
    if (value == '.' && _currentNumberHasDot(expression)) return;
    expression += value;
    state = CalculatorState(
        expression: expression, display: expression, hasError: false);
  }

  void clear() => state = const CalculatorState.initial();

  void backspace() {
    if (state.hasError || state.expression.isEmpty) {
      clear();
      return;
    }
    final expression =
        state.expression.substring(0, state.expression.length - 1);
    state = CalculatorState(
        expression: expression,
        display: expression.isEmpty ? '0' : expression,
        hasError: false);
  }

  void square() {
    if (state.expression.isEmpty || state.hasError) return;
    input('^2');
  }

  void squareRoot() {
    if (state.expression.isEmpty || state.hasError) return;
    final expression = 'sqrt(${state.expression})';
    state = CalculatorState(
        expression: expression, display: expression, hasError: false);
  }

  void percent() {
    if (state.expression.isEmpty || state.hasError) return;
    final expression = '(${state.expression})/100';
    state = CalculatorState(
        expression: expression, display: expression, hasError: false);
  }

  void evaluate() {
    if (state.expression.isEmpty) return;
    try {
      final result = _evaluator.evaluate(state.expression);
      final display = _format(result);
      state = CalculatorState(
          expression: display, display: display, hasError: false);
    } on FormatException {
      state =
          const CalculatorState(expression: '', display: '错误', hasError: true);
    }
  }

  bool _currentNumberHasDot(String expression) {
    final lastOperator = expression.lastIndexOf(RegExp(r'[+\-*/^()]'));
    return expression.substring(lastOperator + 1).contains('.');
  }

  String _format(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value
        .toStringAsFixed(10)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }
}
