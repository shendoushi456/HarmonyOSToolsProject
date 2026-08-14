// 日期工具 - 迁移自 Android DateUtil.kt
import 'package:intl/intl.dart';

class DateUtil {
  DateUtil._();

  static const List<String> _weeks = [
    '周日',
    '周一',
    '周二',
    '周三',
    '周四',
    '周五',
    '周六',
  ];

  /// 获取当前小时
  static int getNowHour() => DateTime.now().hour;

  /// 获取当前时间字符串 "HH:mm"
  static String getNowTime() => DateFormat('HH:mm').format(DateTime.now());

  /// 获取当前日期 "yyyy/M"
  static String getNowDate() {
    final now = DateTime.now();
    return '${now.year}/${now.month}';
  }

  /// 获取当前日
  static String getNowDay() => DateTime.now().day.toString();

  /// 根据位置和日期获取星期标签
  /// position: 0→今天, 1→明天, 2→后天, 其他→周X
  /// date: "yyyy-MM-dd" 格式
  static String getWeekDay(int position, String date) {
    switch (position) {
      case 0:
        return '今天';
      case 1:
        return '明天';
      case 2:
        return '后天';
      default:
        final parsed = DateTime.tryParse(date);
        if (parsed == null) return _weeks[0];
        return _weeks[parsed.weekday % 7];
    }
  }

  /// 格式化日期为 "MM/dd"
  static String formatDateMMdd(String date) {
    final parsed = DateTime.tryParse(date);
    if (parsed == null) return '';
    return DateFormat('MM/dd').format(parsed);
  }

  /// 摄氏度转华氏度
  static int celsiusToFahrenheit(int celsius) => (celsius * 1.8 + 32).round();
}
