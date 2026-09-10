// QxAir 空气质量 ViewModel - 对齐 Android QxAirViewModel.kt
// init 即刷新 + onResume/onHiddenChanged 触发 refresh
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/qx_air_ui_state.dart';
import '../repositories/qx_air_repository.dart';

class QxAirViewModel extends Notifier<QxAirUiState> {
  final QxAirRepository _repository = QxAirRepository();

  @override
  QxAirUiState build() {
    // 对齐 Android ViewModel init { refresh() }
    Future.microtask(refresh);
    return const QxAirUiState();
  }

  /// 刷新空气质量数据（对齐 Android QxAirViewModel.refresh）
  Future<void> refresh() async {
    state = state.copyWith(loading: true);
    state = await _repository.loadAir();
  }
}

/// QxAir 页面 Provider
final qxAirViewModelProvider =
    NotifierProvider<QxAirViewModel, QxAirUiState>(QxAirViewModel.new);
