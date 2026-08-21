// 大温度展示区 - 对齐 Android WeatherChildFragment.TemperatureDisplay
// Box(horizontal padding 20dp) + Image weather_lbg(matchParentSize) + Column(bottom 20, start 30, top 10)
// 第一行 SpaceBetween: 大温度60sp + 天气文字15sp + 天气图标140dp
// 第二行 Row(padding top 12): 温度范围15sp + 风向15sp + 风力15sp
import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/utils/weather_icon_util.dart';
import '../../models/weather_model.dart';

class TemperatureDisplay extends StatelessWidget {
  /// 今日天气数据 - 对齐 Android WeatherChildFragment.now (Weather7D?)
  final DailyWeather? today;

  const TemperatureDisplay({super.key, this.today});

  @override
  Widget build(BuildContext context) {
    // 默认值对齐 Android: tempMax="26", textDay="多云", windDirDay="东风", windScaleDay="10", tempMin="2"
    final tempMax = today?.tempMax.isNotEmpty == true ? today!.tempMax : '26';
    final tempMin = today?.tempMin.isNotEmpty == true ? today!.tempMin : '2';
    final textDay = today?.textDay.isNotEmpty == true ? today!.textDay : '多云';
    final windDirDay = today?.windDirDay.isNotEmpty == true
        ? today!.windDirDay
        : '东风';
    final windScaleDay = today?.windScaleDay.isNotEmpty == true
        ? today!.windScaleDay
        : '10';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        children: [
          // 背景图 matchParentSize - 对齐 Android Image(painterResource = R.mipmap.weather_lbg)
          Positioned.fill(
            child: Image.asset(AppAssets.weatherCardBg, fit: BoxFit.fill),
          ),
          // 内容层 - 对齐 Android Column(padding bottom 20, start 30, top 10)
          Padding(
            padding: const EdgeInsets.only(bottom: 20, left: 30, top: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 第一行 SpaceBetween: 大温度 + 天气文字 + 天气图标
                // 对齐 Android Row(SpaceBetween, CenterVertically)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 左侧: 大温度 60sp SemiBold 0xFF2A78A7 (align Bottom)
                    Text(
                      '$tempMax°',
                      style: const TextStyle(
                        color: Color(0xFF2A78A7),
                        fontSize: 60,
                        fontWeight: FontWeight.w600,
                        height: 62 / 60,
                      ),
                    ),
                    // 中间: 天气文字 15sp 0xFF2A78A7 (align Bottom, padding bottom 10)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        textDay,
                        style: const TextStyle(
                          color: Color(0xFF2A78A7),
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    // 右侧: 天气图标 140dp
                    Image.asset(
                      WeatherIconUtil.dayIcon(textDay),
                      width: 140,
                      height: 140,
                    ),
                  ],
                ),
                // 第二行 Row(padding top 12): 温度范围 + 风向 + 风力
                // 对齐 Android Row(padding top 12, CenterVertically)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 温度范围 15sp - 对齐 Android "${now?.tempMax}°/${now?.tempMin}°"
                      Text(
                        '$tempMax°/$tempMin°',
                        style: const TextStyle(
                          color: Color(0xFF2A78A7),
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      // 风向+风力 Row(padding horizontal 12)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            // 风向 15sp
                            Text(
                              windDirDay,
                              style: const TextStyle(
                                color: Color(0xFF2A78A7),
                                fontSize: 15,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            // 风力 15sp (padding start 8)
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Text(
                                '$windScaleDay级',
                                style: const TextStyle(
                                  color: Color(0xFF2A78A7),
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
