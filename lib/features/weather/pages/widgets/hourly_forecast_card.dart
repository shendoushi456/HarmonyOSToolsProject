// 逐小时预报卡 - 对齐 Android WeatherChildFragment.HourlyForecastCard
// 133dp 高，展示和风天气接口返回的真实24小时预报
import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/weather_icon_util.dart';
import '../../models/weather_model.dart';

class HourlyForecastCard extends StatelessWidget {
  final DailyWeather? today;
  final List<HourForecast> hourly;

  const HourlyForecastCard({
    super.key,
    required this.today,
    required this.hourly,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 133,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        children: [
          Image.asset(
            AppAssets.homeHourlyCard,
            width: double.infinity,
            height: 133,
            fit: BoxFit.fill,
          ),
          Positioned(
            top: 14,
            bottom: 13,
            left: 24,
            right: 24,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: hourly.length,
              separatorBuilder: (_, __) => const SizedBox(width: 20),
              itemBuilder: (context, index) {
                final item = hourly[index];
                return SizedBox(
                  width: 36,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.time,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.qmtqText,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Image.asset(
                        WeatherIconUtil.smallIcon(item.condition),
                        width: 28,
                        height: 28,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.temperature,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.qmtqText,
                        ),
                      ),
                      // 第4项显示天气前两字
                      if (index == 3) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.condition.length >= 2
                              ? item.condition.substring(0, 2)
                              : item.condition,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.qmtqText,
                          ),
                        ),
                      ],
                      // 第6项显示"日落"
                      if (index == 5) ...[
                        const SizedBox(height: 4),
                        const Text(
                          '日落',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.sunsetMark,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
