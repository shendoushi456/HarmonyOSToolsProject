// 预报内容区容器 - 对齐 Android WeatherChildFragment.ForecastContent
// 顶部圆角 32dp,含逐小时卡、15日标题、趋势/列表切换
import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/weather_model.dart';
import 'hourly_forecast_card.dart';
import 'forecast_mode_switch.dart';
import 'trend_forecast_card.dart';
import 'list_forecast_card.dart';

class ForecastContent extends StatefulWidget {
  final DailyWeather? today;
  final List<HomeForecast> forecasts;
  final List<HourForecast> hourly;

  const ForecastContent({
    super.key,
    required this.today,
    required this.forecasts,
    required this.hourly,
  });

  @override
  State<ForecastContent> createState() => _ForecastContentState();
}

class _ForecastContentState extends State<ForecastContent> {
  bool _showTrend = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 逐小时预报卡
          HourlyForecastCard(today: widget.today, hourly: widget.hourly),
          // "15日天气"标题
          Container(
            height: 28,
            margin: const EdgeInsets.only(top: 23),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(AppAssets.weatherForecastTitle, width: 20, height: 20),
                const SizedBox(width: 8),
                const Text(
                  '15日天气',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: AppColors.qmtqBlue,
                  ),
                ),
              ],
            ),
          ),
          // 趋势/列表切换
          Container(
            margin: const EdgeInsets.only(top: 28),
            child: ForecastModeSwitch(
              showTrend: _showTrend,
              onChanged: (v) => setState(() => _showTrend = v),
            ),
          ),
          const SizedBox(height: 3),
          // 趋势卡 或 列表卡
          if (_showTrend)
            TrendForecastCard(forecasts: widget.forecasts)
          else
            ListForecastCard(forecasts: widget.forecasts),
          const SizedBox(height: 18),
        ],
      ),
    );
  }
}
