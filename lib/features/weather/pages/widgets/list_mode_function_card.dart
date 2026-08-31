// 七日周报单项 - 对齐 Android WeatherChildFragment.ListModeFunctionCard（行 708-762）
// Padding v 5 + Row fillMaxWidth + CenterVertically:
//   4 个 weight(1f) 元素全 14sp 白:
//     1. dayLabel 14sp Left  - DateUtil.getWeekDay(index, fxDate)
//     2. Image.asset 24x24  - WeatherIconUtil.dayIcon(weather.textDay)
//     3. condition 14sp Center - weather.textDay
//     4. temperatureRange 14sp Right - "${tempMax}°/${tempMin}°"
// 保真：Android onItemClick = {}（空实现，行 686），此处不加 GestureDetector，点击无反应
import 'package:flutter/material.dart';
import '../../../../core/utils/date_util.dart';
import '../../../../core/utils/weather_icon_util.dart';
import '../../models/weather_model.dart';

class ListModeFunctionCard extends StatelessWidget {
  /// 单日天气数据 - 对齐 Android TravelViewModel.WeeklyForecast
  final DailyWeather weather;

  /// 索引 - 用于 dayLabel 计算（对齐 Android populateForecasts 的 i）
  final int index;

  const ListModeFunctionCard({
    super.key,
    required this.weather,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    // dayLabel - 对齐 Android DateUtil.getWeekDay(i, fxDate) 14sp 白 Left
    final dayLabel = DateUtil.getWeekDay(index, weather.fxDate);
    // temperatureRange - 对齐 Android "${tempMax}°/${tempMin}°"（行 253）
    final tempRange = '${weather.tempMax}°/${weather.tempMin}°';

    // 对齐 Android Row(padding v 5, CenterVertically)
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. dayLabel 14sp 白 Left - 对齐 Android Text(14sp White Left, weight 1f)
          Expanded(
            child: Text(
              dayLabel,
              textAlign: TextAlign.left,
              style: const TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 14,
              ),
            ),
          ),
          // 2. 天气图标 24dp - 对齐 Android AsyncImage(function.icon, 24dp)
          // 注：icon 来自 populateForecasts → getWeatherDayIcon(textDay)，鸿蒙用 dayIcon 复用
          Image.asset(
            WeatherIconUtil.dayIcon(weather.textDay),
            width: 24,
            height: 24,
          ),
          // 3. condition 14sp 白 Center - 对齐 Android Text(14sp White Center, weight 1f)
          Expanded(
            child: Text(
              weather.textDay,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 14,
              ),
            ),
          ),
          // 4. temperatureRange 14sp 白 Right - 对齐 Android Text(14sp White Right, weight 1f)
          Expanded(
            child: Text(
              tempRange,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
