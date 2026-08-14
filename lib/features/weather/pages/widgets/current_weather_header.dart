// 当前天气头部 - 对齐 Android WeatherChildFragment.CurrentWeatherHeader
// 336dp 高,含城市切换栏、天气卡片、天气大图标
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/utils/weather_icon_util.dart';
import '../../models/weather_model.dart';
import 'weather_metric.dart';

class CurrentWeatherHeader extends StatelessWidget {
  final String cityName;
  final DailyWeather? today;
  final AirQuality? airQuality;
  final VoidCallback onCityClick;

  const CurrentWeatherHeader({
    super.key,
    required this.cityName,
    required this.today,
    required this.airQuality,
    required this.onCityClick,
  });

  @override
  Widget build(BuildContext context) {
    final paddingTop = MediaQuery.of(context).padding.top;
    return SizedBox(
      height: 336,
      child: Stack(
        children: [
          // 城市切换栏
          Positioned(
            top: paddingTop + 11,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onCityClick();
                },
                child: Container(
                  height: 42,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0x3386D2FE),
                    borderRadius: BorderRadius.circular(21),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(AppAssets.weatherCitySwitch, width: 20, height: 20),
                      const SizedBox(width: 8),
                      Text(
                        cityName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // 天气卡片
          Positioned(
            top: 132,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 335,
                height: 186,
                child: Stack(
                  children: [
                    Image.asset(
                      AppAssets.homeWeatherCard,
                      width: 335,
                      height: 186,
                      fit: BoxFit.fill,
                    ),
                    // 温度行
                    Positioned(
                      left: 173,
                      top: 17,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${today?.tempMax ?? '--'}°',
                            style: const TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '/${today?.tempMin ?? '--'}°',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 天气文字 + 空气质量
                    Positioned(
                      left: 173,
                      top: 72,
                      child: Row(
                        children: [
                          Text(
                            today?.textDay ?? '--',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Text(
                            airQuality?.category ?? '优',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 底部三指标
                    Positioned(
                      left: 20,
                      right: 19,
                      bottom: 18,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          WeatherMetric(
                            label: '风速',
                            value: '${today?.windSpeedDay ?? '--'}km/h',
                            icon: AppAssets.weatherWind,
                          ),
                          WeatherMetric(
                            label: '气压',
                            value: '${today?.pressure ?? '--'}hPa',
                            icon: AppAssets.weatherPressure,
                          ),
                          WeatherMetric(
                            label: '湿度',
                            value: '${today?.humidity ?? '--'}%',
                            icon: AppAssets.weatherHumidity,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 天气大图标(128dp 圆形)
          Positioned(
            left: 36,
            top: 108,
            child: Container(
              width: 128,
              height: 128,
              decoration: const BoxDecoration(
                color: AppColors.weatherIconBg,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Image.asset(
                WeatherIconUtil.largeIcon(today?.textDay ?? '晴'),
                width: 100,
                height: 95,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
