// 风速/气压/湿度三列卡片 - 对齐 Android WeatherShChildFragment.WeatherInfoCard + WeatherInfoItem
// Row(padding h 20, shadow 4dp, RoundedCorner 18dp, white, padding h 16 v 12, SpaceAround)
//   3 个 WeatherInfoItem(weight 1f): 图标 66dp(无 tint) + 数值 12sp Black Medium + label 12sp Black Normal
import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../weather/models/weather_model.dart' show DailyWeather;

class WeatherInfoCard extends StatelessWidget {
  /// 今日天气数据 - 对齐 Android now (Weather7D?)
  final DailyWeather? today;

  const WeatherInfoCard({super.key, this.today});

  @override
  Widget build(BuildContext context) {
    // 默认值对齐 Android: windSpeedDay="25", pressure="1000", humidity="0"
    final windSpeedDay =
        (today?.windSpeedDay.isNotEmpty == true) ? today!.windSpeedDay : '25';
    final pressure =
        (today?.pressure.isNotEmpty == true) ? today!.pressure : '1000';
    final humidity =
        (today?.humidity.isNotEmpty == true) ? today!.humidity : '0';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            // 对齐 Android shadow elevation 4dp
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        // 对齐 Android padding(horizontal 16, vertical 12)
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          // 对齐 Android horizontalArrangement = SpaceAround
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 风速 - icon ic_feng_main_2_1, value "${windSpeedDay}km/h", label "风速"
            Expanded(
              child: _WeatherInfoItem(
                icon: AppAssets.airWindSpeed,
                value: '${windSpeedDay}km/h',
                label: '风速',
              ),
            ),
            // 气压 - icon ic_feng_main_2_2, value "${pressure}hPa", label "气压"
            Expanded(
              child: _WeatherInfoItem(
                icon: AppAssets.airPressure,
                value: '${pressure}hPa',
                label: '气压',
              ),
            ),
            // 湿度 - icon ic_feng_main_2_3, value "${humidity}%", label "湿度"
            Expanded(
              child: _WeatherInfoItem(
                icon: AppAssets.airHumidity,
                value: '$humidity%',
                label: '湿度',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 单个指标项 - 对齐 Android WeatherShChildFragment.WeatherInfoItem
/// Column(weight, CenterHorizontally, CenterVertically):
///   图标 66dp(无 tint) + Spacer 8dp + 数值 12sp Black Medium + label 12sp Black Normal
class _WeatherInfoItem extends StatelessWidget {
  /// 图标路径 - 66dp
  final String icon;

  /// 数值 - 12sp Black Medium
  final String value;

  /// 标签 - 12sp Black Normal
  final String label;

  const _WeatherInfoItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 图标 66dp - 对齐 Android AsyncImage size 66dp (无 tint)
        Image.asset(icon, width: 66, height: 66),
        const SizedBox(height: 8), // Spacer 8dp
        // 数值 12sp Black Medium
        Text(
          value,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        // 标签 12sp Black Normal
        Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
