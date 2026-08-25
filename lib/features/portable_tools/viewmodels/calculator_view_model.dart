import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/calculator_state.dart';
import '../services/calculator_engine.dart';

final calculatorViewModelProvider =
    NotifierProvider<CalculatorViewModel, CalculatorState>(
        CalculatorViewModel.new);

/// 普通计算器业务状态，对齐 Android StandardFragment 的按键规则。
class CalculatorViewModel extends Notifier<CalculatorState> {
  @override
  CalculatorState build() => const CalculatorState();

  void input(String value) {
    final current = state.hasResult ? '' : state.expression;
    state = CalculatorState(
        expression: '$current$value',
        display: '$current$value'.isEmpty ? '0' : '$current$value');
  }

  void operator(String value) {
    var expression = state.hasResult ? state.display : state.expression;
    if (expression.isEmpty && value == '-') {
      state = const CalculatorState(expression: '-', display: '-');
      return;
    }
    if (expression.isEmpty) return;
    if (RegExp(r'[+\-*/]$').hasMatch(expression)) {
      expression = expression.substring(0, expression.length - 1);
    }
    expression += value;
    state = CalculatorState(expression: expression, display: expression);
  }

  void decimal() {
    final current = state.hasResult ? '' : state.expression;
    final lastNumber = current.split(RegExp(r'[+\-*/()]')).last;
    if (lastNumber.contains('.')) return;
    final next = lastNumber.isEmpty ? '${current}0.' : '$current.';
    state = CalculatorState(expression: next, display: next);
  }

  void square() {
    final value = state.hasResult ? state.display : state.expression;
    if (value.isEmpty) return;
    final next = '($value)^2';
    state = CalculatorState(expression: next, display: next);
  }

  void squareRoot() {
    final value = state.hasResult ? state.display : state.expression;
    if (value.isEmpty) return;
    final next = 'sqrt($value)';
    state = CalculatorState(expression: next, display: next);
  }

  void percent() {
    final value = state.hasResult ? state.display : state.expression;
    if (value.isEmpty) return;
    final next = '($value)/100';
    state = CalculatorState(expression: next, display: next);
    calculate();
  }

  void backspace() {
    if (state.hasResult || state.expression.isEmpty) {
      clear();
      return;
    }
    final next = state.expression.substring(0, state.expression.length - 1);
    state =
        CalculatorState(expression: next, display: next.isEmpty ? '0' : next);
  }

  void clear() => state = const CalculatorState();

  void calculate() {
    final expression = state.expression;
    if (expression.isEmpty) return;
    try {
      final result =
          CalculatorEngine.format(CalculatorEngine.evaluate(expression));
      state =
          CalculatorState(expression: result, display: result, hasResult: true);
    } on FormatException {
      state = const CalculatorState(display: '错误', hasResult: true);
    }
  }
}
