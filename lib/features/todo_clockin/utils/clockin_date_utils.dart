// 日期工具 - 对齐 Android com.p.a_b.utils.DateUtils + Fragment 内日期解析逻辑
// 统一使用"yyyy年MM月dd日"格式(与安卓 SimpleDateFormat 一致，月/日补零)

/// 格式化为 "%d年%02d月%02d日"(对齐 DateUtils.formatCalendarToString)
String formatYMD(DateTime date) {
  return '${date.year}年${date.month.toString().padLeft(2, '0')}月'
      '${date.day.toString().padLeft(2, '0')}日';
}

/// 解析 "yyyy年MM月dd日" - 对齐 DateUtils.parseDateString
DateTime? parseYMD(String dateStr) {
  final match =
      RegExp(r'(\d+)年(\d+)月(\d+)日').firstMatch(dateStr.trim());
  if (match == null) return null;
  try {
    return DateTime(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
    );
  } catch (_) {
    return null;
  }
}

/// 比较两个日期字符串(对齐 DateUtils.compareDateStrings)
/// 返回 1: date1 > date2, 0: 相等或无法解析, -1: date1 < date2
int compareDateStrings(String dateStr1, String dateStr2) {
  final date1 = parseYMD(dateStr1);
  final date2 = parseYMD(dateStr2);
  if (date1 == null || date2 == null) return 0;
  if (date1.isBefore(date2)) return -1;
  if (date1.isAfter(date2)) return 1;
  return 0;
}

/// 结束日期是否晚于开始日期(对齐 DateUtils.isEndDateAfterStartDate)
bool isEndDateAfterStartDate(String startDateStr, String endDateStr) {
  return compareDateStrings(endDateStr, startDateStr) > 0;
}

/// 判断所选时刻是否已过期(对齐 Fragment/Repository 的 isDateExpired)
/// 秒级清零后，选中时刻早于当前时刻即过期
bool isDateTimeExpired(DateTime selected) {
  final now = DateTime.now();
  final current =
      DateTime(now.year, now.month, now.day, now.hour, now.minute);
  final target =
      DateTime(selected.year, selected.month, selected.day, selected.hour, selected.minute);
  return target.isBefore(current);
}

/// 解析 "yyyy-MM-dd HH:mm" 提醒时间 - 对齐 parseReminderTime
DateTime? parseReminderTime(String reminderTime) {
  if (reminderTime.isEmpty) return null;
  try {
    final match = RegExp(r'(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2})')
        .firstMatch(reminderTime);
    if (match != null) {
      return DateTime(
        int.parse(match.group(1)!),
        int.parse(match.group(2)!),
        int.parse(match.group(3)!),
        int.parse(match.group(4)!),
        int.parse(match.group(5)!),
      );
    }
    return null;
  } catch (_) {
    return null;
  }
}

/// 格式化 "yyyy-MM-dd HH:mm"(对齐 String.format("%04d-%02d-%02d %02d:%02d"))
String formatReminderTime(int year, int month, int day, int hour, int minute) {
  final y = year.toString().padLeft(4, '0');
  final m = month.toString().padLeft(2, '0');
  final d = day.toString().padLeft(2, '0');
  final h = hour.toString().padLeft(2, '0');
  final min = minute.toString().padLeft(2, '0');
  return '$y-$m-$d $h:$min';
}

/// 当前时间 "HH:mm"(对齐 ClockInRepository.getCurrentTime)
String currentTimeHHmm() {
  final now = DateTime.now();
  return '${now.hour.toString().padLeft(2, '0')}:'
      '${now.minute.toString().padLeft(2, '0')}';
}
