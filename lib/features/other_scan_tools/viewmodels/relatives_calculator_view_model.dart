import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/relationship_calculator.dart';

class RelativesCalculatorState {
  const RelativesCalculatorState({
    this.calls = const ['我'],
    this.isWoman = false,
    this.showingReverse = false,
    this.result = '',
  });

  final List<String> calls;
  final bool isWoman;
  final bool showingReverse;
  final String result;

  String get input => showingReverse ? 'TA称呼我' : calls.join('的');
  bool get canReverse =>
      calls.length > 1 && !showingReverse && result.isNotEmpty;
}

class RelativesCalculatorViewModel extends Notifier<RelativesCalculatorState> {
  static const _calculator = RelationshipCalculator();

  @override
  RelativesCalculatorState build() => const RelativesCalculatorState();

  void setWoman(bool value) => state = RelativesCalculatorState(isWoman: value);

  void append(String relation) {
    final calls = [...state.calls, relation];
    state = RelativesCalculatorState(
      calls: calls,
      isWoman: state.isWoman,
      result: _calculator.calculate(calls, isWoman: state.isWoman),
    );
  }

  void delete() {
    if (state.calls.length == 1) return;
    final calls = state.calls.sublist(0, state.calls.length - 1);
    state = RelativesCalculatorState(
      calls: calls,
      isWoman: state.isWoman,
      result: _calculator.calculate(calls, isWoman: state.isWoman),
    );
  }

  void clear() => state = RelativesCalculatorState(isWoman: state.isWoman);

  void calculate() {
    state = RelativesCalculatorState(
      calls: state.calls,
      isWoman: state.isWoman,
      result: _calculator.calculate(state.calls, isWoman: state.isWoman),
    );
  }

  void toggleReverse() {
    if (state.showingReverse) {
      calculate();
      return;
    }
    final reversed =
        _calculator.reverse(state.calls, initialWoman: state.isWoman);
    final last = state.calls.last;
    state = RelativesCalculatorState(
      calls: state.calls,
      isWoman: _calculator.isMale(last),
      showingReverse: true,
      result:
          _calculator.calculate(reversed, isWoman: _calculator.isMale(last)),
    );
  }
}

final relativesCalculatorViewModelProvider =
    NotifierProvider<RelativesCalculatorViewModel, RelativesCalculatorState>(
  RelativesCalculatorViewModel.new,
);
