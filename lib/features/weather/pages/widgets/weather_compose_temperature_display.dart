// 大温度展示区 - 对齐 Android WeatherChildFragment.TemperatureDisplay（行 237-281）
// 简洁版（区别于旧版 temperature_display.dart 的 60sp+140dp 布局）
// Box 宽 138dp 居中 + 透明背景 + Column padding h/v 20dp:
//   主温度 44sp 白 Medium lineHeight 62/44 + 天气图标 24dp + 温度范围 10sp 白 padding top 4
// 保真默认值：tempMax="26" / tempMin="15"（对齐 Android 行 256/272）
import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/utils/weather_icon_util.dart';
import '../../models/weather_model.dart';

class WeatherComposeTemperatureDisplay extends StatelessWidget {
  /// 今日天气数据 - 对齐 Android WeatherChildFragment.now (Weather7D?)
  final DailyWeather? today;

  const WeatherComposeTemperatureDisplay({super.key, this.today});

  @override
  Widget build(BuildContext context) {
    // 保真默认值对齐 Android：tempMax="26", tempMin="15"
    final tempMax = (today?.tempMax.isNotEmpty == true) ? today!.tempMax : '26';
    final tempMin = (today?.tempMin.isNotEmpty == true) ? today!.tempMin : '15';
    final textDay = today?.textDay ?? '';

    return Container(
      width: 138,
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 主温度 - 对齐 Android Text("${now?.tempMax ?: "26"}°", 44sp Medium 白, lineHeight 62)
            Text(
              '$tempMax°',
              style: const TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 44,
                fontWeight: FontWeight.w500,
                height: 62 / 44,
              ),
            ),
            // 天气图标 24dp - 对齐 Android Image(painterResource = getWeatherDayIcon(textDay) ?: ic_six_7day_sun, size 24dp)
            Image.asset(
              WeatherIconUtil.dayIcon(textDay),
              width: 24,
              height: 24,
              // 空字符串 fallback 由 WeatherIconUtil.dayIcon 内部返回 weatherDaySun
              errorBuilder: (context, error, stackTrace) =>
                  Image.asset(AppAssets.weatherDaySun, width: 24, height: 24),
            ),
            // 温度范围 - 对齐 Android Text("${now?.tempMin ?: "15"}°C ~ ${now?.tempMax ?: "28"}°C", 10sp 白, padding top 4, lineHeight 14)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '$tempMin°C ~ $tempMax°C',
                style: const TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontSize: 10,
                  fontWeight: FontWeight.normal,
                  height: 14 / 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
