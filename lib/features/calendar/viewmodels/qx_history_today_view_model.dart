// QxHistoryToday 历史上的今天 ViewModel - 对齐 Android QxHistoryTodayViewModel.kt
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/qx_calendar_models.dart';
import '../repositories/qx_calendar_repository.dart';

class QxHistoryTodayViewModel extends Notifier<QxHistoryTodayUiState> {
  final QxCalendarRepository _repository = QxCalendarRepository();

  @override
  QxHistoryTodayUiState build() {
    return const QxHistoryTodayUiState();
  }

  /// 对齐 Android refresh(date)：loading → 加载 30 条 → 发布
  Future<void> refresh(DateTime date) async {
    state = state.copyWith(loading: true);
    List<QxHistoryEventUi> events;
    try {
      events = await _repository.loadHistoryToday(date, limit: 30);
    } catch (_) {
      events = const [];
    }
    state = QxHistoryTodayUiState(loading: false, events: events);
  }
}

/// QxHistoryToday 页面 Provider
final qxHistoryTodayViewModelProvider =
    NotifierProvider<QxHistoryTodayViewModel, QxHistoryTodayUiState>(
        QxHistoryTodayViewModel.new);
