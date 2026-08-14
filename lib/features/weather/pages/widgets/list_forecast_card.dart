// 列表预报卡 - 对齐 Android WeatherChildFragment.ListForecastCard
// 486dp 高,15 日列表
import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/weather_icon_util.dart';
import '../../models/weather_model.dart';

class ListForecastCard extends StatelessWidget {
  final List<HomeForecast> forecasts;

  const ListForecastCard({
    super.key,
    required this.forecasts,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 486,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        children: [
          Image.asset(
            AppAssets.homeListCard,
            width: double.infinity,
            height: 486,
            fit: BoxFit.fill,
          ),
          Positioned(
            top: 58,
            bottom: 10,
            left: 8,
            right: 8,
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: forecasts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 0),
              itemBuilder: (context, index) {
                final f = forecasts[index];
                final isToday = index == 0;
                final textColor =
                    isToday ? AppColors.qmtqOrange : AppColors.qmtqText;
                return SizedBox(
                  height: 56,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 48,
                        child: Text(
                          f.dayLabel,
                          style: TextStyle(
                            fontSize: 16,
                            color: textColor,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 66,
                        child: Text(
                          f.dateLabel,
                          style: TextStyle(
                            fontSize: 16,
                            color: textColor,
                          ),
                        ),
                      ),
                      Image.asset(
                        WeatherIconUtil.smallIcon(f.condition),
                        width: 30,
                        height: 30,
                      ),
                      const SizedBox(width: 27),
                      Expanded(
                        child: Text(
                          f.condition,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: textColor,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 76,
                        child: Text(
                          '${f.tempMin}°~${f.tempMax}°',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: textColor,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
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
