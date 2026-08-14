// 逐小时温度正弦插值工具 - 迁移自 Android WeatherChildFragment.hourlyTemperature
// 根据当日最高/最低温,按时间段插值生成 24 小时温度
class HourlyTempUtil {
  HourlyTempUtil._();

  /// 计算指定小时的温度
  /// 以 5 点为基准: 5-14 点升温, 14-5 点降温
  static int hourlyTemperature(int hour, int minT, int maxT) {
    final hoursAfterFive = (hour - 5 + 24) % 24;
    final double warmth;
    if (hoursAfterFive <= 9) {
      warmth = hoursAfterFive / 9.0;
    } else {
      warmth = (24 - hoursAfterFive) / 15.0;
    }
    final clamped = warmth.clamp(0.0, 1.0);
    return (minT + (maxT - minT) * clamped).round();
  }

  /// 生成 24 小时温度列表
  /// 返回长度 24 的列表,索引 0 为当前小时
  static List<int> build24HourTemps(int minT, int maxT) {
    final nowHour = DateTime.now().hour;
    return List.generate(24, (i) => hourlyTemperature((nowHour + i) % 24, minT, maxT));
  }
}
