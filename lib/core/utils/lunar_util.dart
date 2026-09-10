// 农历转换工具 - 对齐 Android com.p.a_b.common.Lunar.java
// 仅移植核心农历算法,剔除原版中插入的二分查找/冒泡/插入排序等 junkcode
// 原版 junkcode 不影响返回值,只是无效计算,移植时直接丢弃
import 'package:flutter/foundation.dart';

/// 农历数据类 - 对齐 Lunar.java 实例字段
@immutable
class Lunar {
  /// 农历年(如 2024)
  final int year;

  /// 农历月(1-12)
  final int month;

  /// 农历日(1-30)
  final int day;

  /// 是否闰月
  final bool leap;

  const Lunar._({
    required this.year,
    required this.month,
    required this.day,
    required this.leap,
  });

  /// 1900-2050 农历信息表 - 原样移植自 Lunar.java 行 22
  /// 每个元素编码对应年份的农历信息(月份天数/闰月等位图)
  static const List<int> _lunarInfo = [
    0x04bd8, 0x04ae0, 0x0a570, 0x054d5, 0x0d260, 0x0d950, 0x16554, 0x056a0,
    0x09ad0, 0x055d2, 0x04ae0, 0x0a5b6, 0x0a4d0, 0x0d250, 0x1d255, 0x0b540,
    0x0d6a0, 0x0ada2, 0x095b0, 0x14977, 0x04970, 0x0a4b0, 0x0b4b5, 0x06a50,
    0x06d40, 0x1ab54, 0x02b60, 0x09570, 0x052f2, 0x04970, 0x06566, 0x0d4a0,
    0x0ea50, 0x06e95, 0x05ad0, 0x02b60, 0x186e3, 0x092e0, 0x1c8d7, 0x0c950,
    0x0d4a0, 0x1d8a6, 0x0b550, 0x056a0, 0x1a5b4, 0x025d0, 0x092d0, 0x0d2b2,
    0x0a950, 0x0b557, 0x06ca0, 0x0b550, 0x15355, 0x04da0, 0x0a5d0, 0x14573,
    0x052d0, 0x0a9a8, 0x0e950, 0x06aa0, 0x0aea6, 0x0ab50, 0x04b60, 0x0aae4,
    0x0a570, 0x05260, 0x0f263, 0x0d950, 0x05b57, 0x056a0, 0x096d0, 0x04dd5,
    0x04ad0, 0x0a4d0, 0x0d4d4, 0x0d250, 0x0d558, 0x0b540, 0x0b5a0, 0x195a6,
    0x095b0, 0x049b0, 0x0a974, 0x0a4b0, 0x0b27a, 0x06a50, 0x06d40, 0x0af46,
    0x0ab60, 0x09570, 0x04af5, 0x04970, 0x064b0, 0x074a3, 0x0ea50, 0x06b58,
    0x055c0, 0x0ab60, 0x096d5, 0x092e0, 0x0c960, 0x0d954, 0x0d4a0, 0x0da50,
    0x07552, 0x056a0, 0x0abb7, 0x025d0, 0x092d0, 0x0cab5, 0x0a950, 0x0b4a0,
    0x0baa4, 0x0ad50, 0x055d9, 0x04ba0, 0x0a5b0, 0x15176, 0x052b0, 0x0a930,
    0x07954, 0x06aa0, 0x0ad50, 0x05b52, 0x04b60, 0x0a6e6, 0x0a4e0, 0x0d260,
    0x0ea65, 0x0d530, 0x05aa0, 0x076a3, 0x096d0, 0x04bd7, 0x04ad0, 0x0a4d0,
    0x1d0b6, 0x0d250, 0x0d520, 0x0dd45, 0x0b5a0, 0x056d0, 0x055b2, 0x049b0,
    0x0a577, 0x0a4b0, 0x0aa50, 0x1b255, 0x06d20, 0x0ada0,
  ];

  /// 中文月名数字 - 对齐 Lunar.java chineseNumber
  static const List<String> _chineseNumber = [
    '一', '二', '三', '四', '五', '六', '七', '八', '九', '十', '十一', '十二',
  ];

  /// 农历年 y 的总天数 - 对齐 Lunar.java yearDays
  /// 算法:基础 348 天 + lunarInfo 位图中每位 +1 + 闰月天数
  static int _yearDays(int y) {
    int sum = 348;
    for (int i = 0x8000; i > 0x8; i >>= 1) {
      if ((_lunarInfo[y - 1900] & i) != 0) {
        sum += 1;
      }
    }
    return sum + _leapDays(y);
  }

  /// 农历年 y 的闰月天数 - 对齐 Lunar.java leapDays
  static int _leapDays(int y) {
    if (_leapMonth(y) != 0) {
      return (_lunarInfo[y - 1900] & 0x10000) != 0 ? 30 : 29;
    }
    return 0;
  }

  /// 农历年 y 闰哪个月(1-12),没闰返回 0 - 对齐 Lunar.java leapMonth
  static int _leapMonth(int y) {
    return _lunarInfo[y - 1900] & 0xf;
  }

  /// 农历年 y 月 m 的总天数 - 对齐 Lunar.java monthDays
  static int _monthDays(int y, int m) {
    return (_lunarInfo[y - 1900] & (0x10000 >> m)) == 0 ? 29 : 30;
  }

  /// 从公历 DateTime 构造农历 - 对齐 Lunar.java 构造函数(行 195-269)
  factory Lunar.fromDateTime(DateTime cal) {
    // 基准:1900年1月31日(农历 1900 正月初一)
    final baseDate = DateTime(1900, 1, 31);
    // 与基准相差天数
    int offset = cal.difference(baseDate).inDays;

    int iYear;
    int daysOfYear = 0;
    // 逐年减去农历年天数,得到农历年份和当年第几天
    for (iYear = 1900; iYear < 2050 && offset > 0; iYear++) {
      daysOfYear = _yearDays(iYear);
      offset -= daysOfYear;
    }
    if (offset < 0) {
      offset += daysOfYear;
      iYear--;
    }
    final year = iYear;

    // 闰哪个月
    int leapMonth = _leapMonth(year);
    bool leap = false;

    // 逐月减去农历月天数,得到农历月日
    int iMonth;
    int daysOfMonth = 0;
    for (iMonth = 1; iMonth < 13 && offset > 0; iMonth++) {
      if (leapMonth > 0 && iMonth == (leapMonth + 1) && !leap) {
        // 闰月处理
        iMonth--;
        leap = true;
        daysOfMonth = _leapDays(year);
      } else {
        daysOfMonth = _monthDays(year, iMonth);
      }
      offset -= daysOfMonth;
      // 解除闰月标记
      if (leap && iMonth == (leapMonth + 1)) {
        leap = false;
      }
    }
    // offset 为 0 且刚算闰月时校正
    if (offset == 0 && leapMonth > 0 && iMonth == leapMonth + 1) {
      if (leap) {
        leap = false;
      } else {
        leap = true;
        iMonth--;
      }
    }
    // offset 小于 0 校正
    if (offset < 0) {
      offset += daysOfMonth;
      iMonth--;
    }
    return Lunar._(
      year: year,
      month: iMonth,
      day: offset + 1,
      leap: leap,
    );
  }

  /// 中文农历日字符串 - 对齐 Lunar.java getChinaDayString
  /// day=10 返回"初十",其余返回"初/十/廿/三" + "一...九"
  static String _getChinaDayString(int day) {
    const chineseTen = ['初', '十', '廿', '三'];
    final n = day % 10 == 0 ? 9 : day % 10 - 1;
    if (day > 30) return '';
    if (day == 10) return '初十';
    return chineseTen[day ~/ 10] + _chineseNumber[n];
  }

  /// 农历完整字符串 - 对齐 Lunar.java toString
  /// 格式: "[闰]X月Y日" 如 "二月初一" / "闰五月十五"
  @override
  String toString() {
    final leapPrefix = leap ? '闰' : '';
    return '$leapPrefix${_chineseNumber[month - 1]}月${_getChinaDayString(day)}';
  }

  /// 干支年字符串 - 对齐 Lunar.java cyclical()（如"癸卯"）
  /// 传入 offset 传回干支, 0=甲子；原版 junkcode 不影响返回值，直接丢弃
  String cyclical() {
    const gan = ['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'];
    const zhi = ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'];
    final num = year - 1900 + 36;
    return gan[num % 10] + zhi[num % 12];
  }
}

/// 农历工具类 - 对齐 Android CalendarFragment.lunarLabel
/// 用于日历格子下方显示农历标签
class LunarUtil {
  LunarUtil._();

  /// 获取日期对应的农历标签
  /// 初一显示月份名(如"二月"),其他日子显示日名(如"十五")
  ///
  /// 注意:原版 Android CalendarFragment.lunarLabel(行 953-962)有 bug:
  /// 初一返回 "${lunar.substringBefore("月")}月" 会产生 "二月月"
  /// 此处修正为返回 "二月"(修正用户确认的 bug)
  static String lunarLabel(DateTime date) {
    final lunar = Lunar.fromDateTime(date).toString();
    final monthIdx = lunar.indexOf('月');
    if (monthIdx < 0) return lunar;
    final monthPart = lunar.substring(0, monthIdx); // 如 "二月" / "闰五月"
    final dayPart = lunar.substring(monthIdx + 1); // 如 "初一" / "十五"
    // 修正:初一显示月份名(如"二月"),原版 bug 会显示"二月月"
    if (dayPart == '初一') {
      return monthPart;
    }
    return dayPart;
  }
}
