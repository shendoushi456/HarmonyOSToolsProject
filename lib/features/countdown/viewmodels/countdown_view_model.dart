import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/countdown_models.dart';
import '../repositories/countdown_repository.dart';
import 'countdown_state.dart';

final countdownRepositoryProvider = Provider<CountdownRepository>(
  (ref) => CountdownRepository(),
);

final countdownViewModelProvider =
    NotifierProvider<CountdownViewModel, CountdownState>(
  CountdownViewModel.new,
);

/// 倒数日业务层 - 对齐 Android CountdownRepository 业务规则，
/// 刻意不包含 Widget 与 Dialog。
class CountdownViewModel extends Notifier<CountdownState> {
  late final CountdownRepository _repository;

  @override
  CountdownState build() {
    _repository = ref.read(countdownRepositoryProvider);
    Future.microtask(_load);
    return CountdownState.initial();
  }

  Future<void> _load() async {
    final items = await _repository.load();
    state = state.copyWith(loading: false, countdowns: items);
  }

  /// 保存倒数日 - 对齐 saveCountdown：置顶时颜色强制归零。
  Future<bool> saveCountdown({
    required String title,
    required DateTime targetDate,
    required bool isPinned,
    required bool isRepeatYearly,
    required int colorIndex,
  }) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return false;
    final now = DateTime.now().millisecondsSinceEpoch;
    final finalColorIndex = isPinned ? 0 : colorIndex.clamp(0, 2);
    final item = CountdownItem(
      id: now,
      title: trimmed,
      targetDate: _dateOnly(targetDate),
      isPinned: isPinned,
      isRepeatYearly: isRepeatYearly,
      colorIndex: finalColorIndex,
      createdAt: now,
      updatedAt: now,
    );
    final items = [...state.countdowns, item];
    state = state.copyWith(countdowns: _sorted(items));
    await _repository.save(state.countdowns);
    return true;
  }

  /// 删除倒数日 - 对齐 softDeleteCountdown：软删除保留记录。
  Future<void> deleteCountdown(CountdownItem countdown) async {
    final visible = state.countdowns
        .where((item) => item.id != countdown.id)
        .toList();
    state = state.copyWith(countdowns: visible);
    // 软删除：界面上移除，存储中保留记录并标记 isActive=false。
    final persisted = [
      ...visible,
      countdown.copyWith(
        isActive: false,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      ),
    ];
    await _repository.save(persisted);
  }

  /// 距离目标日剩余天数 - 对齐 calculateDaysLeft。
  /// 每年重复时取下个周年日期；today 与目标同日算 0 天。
  int calculateDaysLeft(CountdownItem countdown, [DateTime? now]) {
    final today = _dateOnly(now ?? DateTime.now());
    final target = _dateOnly(countdown.targetDate);
    final nextDate =
        countdown.isRepeatYearly ? _nextAnnualDate(target, today) : target;
    return nextDate.difference(today).inDays;
  }

  /// 展示用目标日 - 对齐 displayTargetDate。
  DateTime displayTargetDate(CountdownItem countdown, [DateTime? now]) {
    final today = _dateOnly(now ?? DateTime.now());
    final target = _dateOnly(countdown.targetDate);
    return countdown.isRepeatYearly ? _nextAnnualDate(target, today) : target;
  }

  /// 排序规则：isPinned DESC, createdAt ASC - 对齐 DAO 查询。
  List<CountdownItem> _sorted(List<CountdownItem> items) {
    final list = [...items];
    list.sort((a, b) {
      if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
      return a.createdAt.compareTo(b.createdAt);
    });
    return list;
  }

  DateTime _nextAnnualDate(DateTime targetDate, DateTime today) {
    var thisYearDate = DateTime(today.year, targetDate.month, targetDate.day);
    if (thisYearDate.isBefore(today)) {
      thisYearDate = DateTime(today.year + 1, targetDate.month, targetDate.day);
    }
    return thisYearDate;
  }

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}
