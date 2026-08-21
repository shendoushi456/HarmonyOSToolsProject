// AQI 圆环展示区 - 对齐 Android WeatherShChildFragment.TemperatureDisplay + CircleProgressBar
// Row(padding h 20, shadow 3dp, RoundedCorner 18dp, white, padding start 30 end 10 vertical 20, spacedBy 60)
//   左侧 Box 120dp: CircleProgressBar(max 300) + kqzl_iocn 68dp center
//   右侧 Column: AQI 52sp + "实时更新"+category 16sp
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../weather/models/weather_model.dart' show AirQuality;

class AqiCircleDisplay extends StatelessWidget {
  /// 空气质量数据 - 对齐 Android air (Airbean?)
  final AirQuality? air;

  const AqiCircleDisplay({super.key, this.air});

  @override
  Widget build(BuildContext context) {
    // 默认值对齐 Android: air?.aqi ?: 0, air?.category ?: "未知"
    final aqi = air?.aqi ?? 0;
    final category = (air?.category.isNotEmpty == true) ? air!.category : '未知';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            // 对齐 Android shadow elevation 3dp
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 3,
              offset: Offset(0, 2),
            ),
          ],
        ),
        // 对齐 Android padding(start 30, end 10, vertical 20)
        padding: const EdgeInsets.only(
          left: 30,
          right: 10,
          top: 20,
          bottom: 20,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          // 对齐 Android horizontalArrangement = spacedBy(60dp)
          children: [
            // 左侧: 圆环进度条 Box 120dp
            SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 圆环进度条 - 对齐 Android CircleProgressBar size 120dp
                  CustomPaint(
                    size: const Size(120, 120),
                    painter: _CircleProgressBarPainter(aqi),
                  ),
                  // 圆环中心图标 - 对齐 Android AsyncImage kqzl_iocn 68dp
                  Image.asset(
                    AppAssets.airQualityCenterIcon,
                    width: 68,
                    height: 68,
                  ),
                ],
              ),
            ),
            // spacedBy 60dp
            const SizedBox(width: 60),
            // 右侧: AQI 数值 + "实时更新" + category
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // AQI 数值 52sp 0xFF73C3EB Medium
                  Text(
                    '$aqi',
                    style: const TextStyle(
                      color: Color(0xFF73C3EB),
                      fontSize: 52,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  // "实时更新" + category Row 16sp 0xFF73C3EB Medium
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '实时更新',
                        style: TextStyle(
                          color: Color(0xFF73C3EB),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        category,
                        style: const TextStyle(
                          color: Color(0xFF73C3EB),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 圆环进度条 Painter - 对齐 Android WeatherShChildFragment.CircleProgressBar
/// strokeWidth 16dp, startAngle -90°(顶部), 背景圆环 sweepAngle 360°,
/// 进度圆环 sweepAngle = 360 * (aqi / 300), max 300, StrokeCap.round, useCenter false
class _CircleProgressBarPainter extends CustomPainter {
  final int aqi;

  const _CircleProgressBarPainter(this.aqi);

  @override
  void paint(Canvas canvas, Size size) {
    // strokeWidth 16dp（Flutter CustomPainter 中 1 逻辑像素 = 1dp）
    const strokeWidth = 16.0;
    // Flutter Size 无 minDimension,用 shortestSide(size.width/height 较小者)
    final minDim = size.shortestSide; // 120
    final radius = (minDim - strokeWidth) / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);

    // 对齐 Android startAngle = -90f (顶部, Flutter 弧度 -π/2)
    const startAngle = -math.pi / 2;
    // 总角度 360° (完整圆, Flutter 弧度 2π)
    const totalSweep = 2 * math.pi;
    // max 300, progress = (aqi / 300).coerceIn(0, 1)
    final progress = (aqi / 300).clamp(0.0, 1.0);
    final currentSweep = totalSweep * progress;

    // 1. 背景圆环 - 对齐 Android drawArc(color 0xFFf3e8dc, startAngle -90, sweepAngle 360, useCenter false)
    final bgPaint = Paint()
      ..color = const Color(0xFFf3e8dc)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, startAngle, totalSweep, false, bgPaint);

    // 2. 进度圆环 - 对齐 Android drawArc(color 0xFF73C3EB, startAngle -90, sweepAngle currentSweepAngle, useCenter false)
    final progressPaint = Paint()
      ..color = const Color(0xFF73C3EB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, startAngle, currentSweep, false, progressPaint);
  }

  @override
  bool shouldRepaint(_CircleProgressBarPainter oldDelegate) =>
      oldDelegate.aqi != aqi;
}
