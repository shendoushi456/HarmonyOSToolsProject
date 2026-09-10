// QxHome 首页天气 ViewModel - 对齐 Android QxHomeViewModel
// 迁移自 toolbox_c toolsbox_moduel weather/home/QxHomeViewModel.kt
// init 即刷新 + onResume 触发 refresh，状态由 StateFlow → Riverpod Notifier 承接
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/qx_home_ui_state.dart';
import '../repositories/qx_home_repository.dart';

class QxHomeViewModel extends Notifier<QxHomeUiState> {
  final QxHomeRepository _repository = QxHomeRepository();

  @override
  QxHomeUiState build() {
    // 对齐 Android ViewModel init { refresh() }
    Future.microtask(refresh);
    return const QxHomeUiState();
  }

  /// 刷新首页天气（对齐 Android QxHomeViewModel.refresh）
  Future<void> refresh() async {
    state = state.copyWith(loading: true);
    state = await _repository.loadHome();
  }
}

/// QxHome 页面 Provider
final qxHomeViewModelProvider =
    NotifierProvider<QxHomeViewModel, QxHomeUiState>(QxHomeViewModel.new);
