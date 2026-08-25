/// 普通计算器页面状态，页面只消费显示值和待计算表达式。
class CalculatorState {
  const CalculatorState({
    this.expression = '',
    this.display = '0',
    this.hasResult = false,
  });

  final String expression;
  final String display;
  final bool hasResult;

  CalculatorState copyWith({
    String? expression,
    String? display,
    bool? hasResult,
  }) {
    return CalculatorState(
      expression: expression ?? this.expression,
      display: display ?? this.display,
      hasResult: hasResult ?? this.hasResult,
    );
  }
}
