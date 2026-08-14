// 日历页 Tab 枚举 - 对齐 Android CalendarFragment.CalendarTab
/// 历史上的今天 / 花费记账 二选一
enum CalendarTab {
  /// 历史上的今天
  history('历史上的今天');

  /// 花费记账
  // expense('花费记账');

  final String title;
  const CalendarTab(this.title);
}
