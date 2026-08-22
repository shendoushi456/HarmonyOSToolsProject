import 'package:flutter/foundation.dart';

@immutable
class CalculatorState {
  final String expression;
  final String display;
  final bool hasError;
  const CalculatorState(
      {required this.expression,
      required this.display,
      required this.hasError});

  const CalculatorState.initial()
      : expression = '',
        display = '0',
        hasError = false;

  CalculatorState copyWith(
          {String? expression, String? display, bool? hasError}) =>
      CalculatorState(
          expression: expression ?? this.expression,
          display: display ?? this.display,
          hasError: hasError ?? this.hasError);
}
