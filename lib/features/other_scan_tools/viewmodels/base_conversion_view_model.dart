import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/base_conversion_service.dart';

class BaseConversionState {
  const BaseConversionState(
      {this.values = const {10: '', 2: '', 8: '', 16: ''}});

  final Map<int, String> values;
}

class BaseConversionViewModel extends Notifier<BaseConversionState> {
  static const _service = BaseConversionService();

  @override
  BaseConversionState build() => const BaseConversionState();

  void update(String value, int sourceBase) {
    state = BaseConversionState(values: _service.convert(value, sourceBase));
  }
}

final baseConversionViewModelProvider =
    NotifierProvider<BaseConversionViewModel, BaseConversionState>(
  BaseConversionViewModel.new,
);
