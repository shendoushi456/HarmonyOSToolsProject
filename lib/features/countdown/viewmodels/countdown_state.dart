import 'package:flutter/foundation.dart';

import '../models/countdown_models.dart';

@immutable
class CountdownState {
  final bool loading;
  final List<CountdownItem> countdowns;

  const CountdownState({
    required this.loading,
    required this.countdowns,
  });

  factory CountdownState.initial() =>
      const CountdownState(loading: true, countdowns: []);

  CountdownState copyWith({
    bool? loading,
    List<CountdownItem>? countdowns,
  }) =>
      CountdownState(
        loading: loading ?? this.loading,
        countdowns: countdowns ?? this.countdowns,
      );
}
