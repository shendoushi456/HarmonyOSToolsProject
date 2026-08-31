// 风速/气压/湿度/温度 4 列指标卡 - 对齐 Android WeatherChildFragment.WeatherInfoCard（行 286-432）
// Container padding h 20 → Column:
//   图标行 Row SpaceBetween padding h 20: 4 个 Image 22x22（顺序 _2_1/_2_2/_2_3/_2_4）
//   数据行 Row SpaceBetween: 4 个 SizedBox width 65 Column center [ 标签 14sp 白 Normal, 值 14sp 白 Medium ]
// 顺序：温(tempMax°C 默认"0")/湿(humidity% 默认"0")/风(windSpeedDay km/h 默认"25")/压(pressure hPa 默认"1000")
// 注：图标复用 air_quality 模块历史命名（airWindSpeed=_2_1/airPressure=_2_2/airHumidity=_2_3），
//     第 4 列气压用新增的 weatherInfoPressure(_2_4)。命名错位是历史遗留，路径正确。
import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../models/weather_model.dart';

class WeatherMetricsCard extends StatelessWidget {
  /// 今日天气数据 - 对齐 Android WeatherChildFragment.now (Weather7D?)
  final DailyWeather? today;

  const WeatherMetricsCard({super.key, this.today});

  @override
  Widget build(BuildContext context) {
    // 保真默认值对齐 Android：
    // 温度列 tempMax 默认"0"（行 345），湿度默认"0"（行 369），风速默认"25"（行 393），气压默认"1000"（行 419）
    final tempMax = (today?.tempMax.isNotEmpty == true) ? today!.tempMax : '0';
    final humidity = (today?.humidity.isNotEmpty == true) ? today!.humidity : '0';
    final windSpeedDay =
        (today?.windSpeedDay.isNotEmpty == true) ? today!.windSpeedDay : '25';
    final pressure =
        (today?.pressure.isNotEmpty == true) ? today!.pressure : '1000';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 图标行 - 对齐 Android Row SpaceBetween padding h 20, 4 个 AsyncImage 22dp
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(AppAssets.airHumidity, width: 22, height: 22),
                Image.asset(AppAssets.airPressure, width: 22, height: 22),
                Image.asset(AppAssets.airWindSpeed, width: 22, height: 22),
                Image.asset(AppAssets.weatherInfoPressure, width: 22, height: 22),
              ],
            ),
          ),
          // 数据行 - 对齐 Android Row SpaceBetween, 4 个 Column(width 65dp, CenterHorizontally)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _MetricItem(label: '温度', value: '$tempMax°C'),
              _MetricItem(label: '湿度', value: '$humidity%'),
              _MetricItem(label: '风速', value: '${windSpeedDay}km/h'),
              _MetricItem(label: '气压', value: '${pressure}hPa'),
            ],
          ),
        ],
      ),
    );
  }
}

/// 单个指标项 - 对齐 Android Column(width 65dp, CenterHorizontally)
/// 标签 14sp 白 Normal padding top 2 + 值 14sp 白 Medium padding top 2
class _MetricItem extends StatelessWidget {
  final String label;
  final String value;

  const _MetricItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 65,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 标签 14sp 白 Normal - 对齐 Android Text(14sp Normal, padding top 2)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          // 值 14sp 白 Medium - 对齐 Android Text(14sp Medium, padding top 2)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
