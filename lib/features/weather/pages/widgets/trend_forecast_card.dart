// 趋势预报卡 - 对齐 Android WeatherChildFragment.TrendForecastCard
// 476dp 高,横向滚动 15 日,叠加 CustomPaint 温度折线
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/weather_icon_util.dart';
import '../../models/weather_model.dart';

class TrendForecastCard extends StatelessWidget {
  final List<HomeForecast> forecasts;

  const TrendForecastCard({
    super.key,
    required this.forecasts,
  });

  @override
  Widget build(BuildContext context) {
    if (forecasts.isEmpty) return const SizedBox.shrink();
    const columnWidth = 74.0;
    final totalWidth = forecasts.length * columnWidth;

    return Container(
      height: 476,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        children: [
          Image.asset(
            AppAssets.homeTrendCard,
            width: double.infinity,
            height: 476,
            fit: BoxFit.fill,
          ),
          Positioned(
            top: 54,
            bottom: 12,
            left: 0,
            right: 0,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: totalWidth,
                child: Stack(
                  children: [
                    // 温度折线层
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _TemperatureLinesPainter(
                          forecasts: forecasts,
                          columnWidth: columnWidth,
                        ),
                      ),
                    ),
                    // 每日列
                    Row(
                      children: forecasts
                          .map((f) => _TrendColumn(
                                forecast: f,
                                width: columnWidth,
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 单日趋势列 - 对齐 TrendForecastColumn
class _TrendColumn extends StatelessWidget {
  final HomeForecast forecast;
  final double width;

  const _TrendColumn({required this.forecast, required this.width});

  @override
  Widget build(BuildContext context) {
    final airColor = forecast.airCategory == '优'
        ? AppColors.airGood
        : AppColors.airOther;
    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            forecast.dayLabel,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.qmtqText,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            forecast.dateLabel,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.qmtqText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            forecast.condition,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.qmtqText,
            ),
          ),
          const SizedBox(height: 13),
          Image.asset(
            WeatherIconUtil.smallIcon(forecast.condition),
            width: 30,
            height: 30,
          ),
          // 折线区域留白
          const SizedBox(height: 177),
          const SizedBox(height: 25),
          Text(
            forecast.windDir,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.qmtqText,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${forecast.windScale}级',
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.qmtqText,
            ),
          ),
          const SizedBox(height: 25),
          Container(
            width: 48,
            height: 21,
            decoration: BoxDecoration(
              color: airColor,
              borderRadius: BorderRadius.circular(11),
            ),
            alignment: Alignment.center,
            child: Text(
              forecast.airCategory,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 温度折线绘制器 - 对齐 Android ForecastTemperatureLines
class _TemperatureLinesPainter extends CustomPainter {
  final List<HomeForecast> forecasts;
  final double columnWidth;

  _TemperatureLinesPainter({
    required this.forecasts,
    required this.columnWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (forecasts.length < 2) return;

    // 计算温度范围
    final temps = forecasts.expand((f) {
      return [int.tryParse(f.tempMax) ?? 0, int.tryParse(f.tempMin) ?? 0];
    }).toList();
    final maxT = temps.reduce(max);
    final minT = temps.reduce(min);
    final range = (maxT - minT).abs().clamp(1, 100).toDouble();

    // 折线区域参数
    const highBase = 238.0; // 高温线基准位置
    const lowBase = 278.0; // 低温线基准位置
    const amplitude = 18.0; // 振幅

    final highPaint = Paint()
      ..color = AppColors.qmtqOrange
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final lowPaint = Paint()
      ..color = AppColors.lowTemp
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()..style = PaintingStyle.fill;

    // 绘制高温线
    final highPath = Path();
    for (var i = 0; i < forecasts.length; i++) {
      final temp = int.tryParse(forecasts[i].tempMax) ?? 0;
      final ratio = (temp - minT) / range;
      final y = highBase - (ratio - 0.5) * 2 * amplitude;
      final x = i * columnWidth + columnWidth / 2;
      if (i == 0) {
        highPath.moveTo(x, y);
      } else {
        highPath.lineTo(x, y);
      }
    }
    canvas.drawPath(highPath, highPaint);

    // 绘制低温线
    final lowPath = Path();
    for (var i = 0; i < forecasts.length; i++) {
      final temp = int.tryParse(forecasts[i].tempMin) ?? 0;
      final ratio = (temp - minT) / range;
      final y = lowBase - (ratio - 0.5) * 2 * amplitude;
      final x = i * columnWidth + columnWidth / 2;
      if (i == 0) {
        lowPath.moveTo(x, y);
      } else {
        lowPath.lineTo(x, y);
      }
    }
    canvas.drawPath(lowPath, lowPaint);

    // 绘制圆点
    for (var i = 0; i < forecasts.length; i++) {
      final highTemp = int.tryParse(forecasts[i].tempMax) ?? 0;
      final lowTemp = int.tryParse(forecasts[i].tempMin) ?? 0;
      final highRatio = (highTemp - minT) / range;
      final lowRatio = (lowTemp - minT) / range;
      final highY = highBase - (highRatio - 0.5) * 2 * amplitude;
      final lowY = lowBase - (lowRatio - 0.5) * 2 * amplitude;
      final x = i * columnWidth + columnWidth / 2;

      canvas.drawCircle(Offset(x, highY), 4, dotPaint..color = AppColors.qmtqOrange);
      canvas.drawCircle(Offset(x, lowY), 4, dotPaint..color = AppColors.lowTemp);
    }
  }

  @override
  bool shouldRepaint(covariant _TemperatureLinesPainter oldDelegate) {
    return oldDelegate.forecasts != forecasts;
  }
}
