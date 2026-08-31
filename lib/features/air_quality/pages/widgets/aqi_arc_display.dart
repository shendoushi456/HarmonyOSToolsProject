// AQI 圆环 + 7 ValueLabel - 对齐 Android WeatherShChildFragment.TemperatureDisplay（行 362-418）+ ArcProgressBar（行 420-462）+ ValueLabel（行 482-506）
// SizedBox(250x250) + Stack(center):
//   SizedBox(120x120) CustomPaint(_ArcPainter) + Column[Text(aqi 44sp 白), Text(category 16sp 白)] + 7 个 _valueLabel(Transform.translate)
// _ArcPainter: 270° 圆弧，startAngle 135°, sweepAngle 270°, strokeWidth 12, StrokeCap.round
//   背景弧 0xFFE0E0E0, 进度弧 _aqiColor(aqi) sweepAngle 270°*progress, max 300
// 保真：无中心图标（安卓原版没有 kqzl_iocn，旧迁移自加的要删）
// 保真："中毒"（非"中度"）严格按安卓原文
import 'dart:math' show pi;
import 'package:flutter/material.dart';
import '../../../weather/models/weather_model.dart' show AirQuality;

class AqiArcDisplay extends StatelessWidget {
  /// 空气质量数据 - 对齐 Android WeatherShChildFragment.air (Airbean?)
  final AirQuality? air;

  const AqiArcDisplay({super.key, this.air});

  @override
  Widget build(BuildContext context) {
    // 保真默认值对齐 Android：aqi ?: 0（Int），category ?: "未知"
    final aqi = air?.aqi ?? 0;
    final category = (air?.category.isNotEmpty == true) ? air!.category : '未知';

    // 对齐 Android Box(fillMaxWidth, height=containerSize=250dp, CenterHorizontally, contentAlignment Center)
    return SizedBox(
      width: 250,
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 圆环本体 120x120 - 对齐 Android ArcProgressBar(120dp)
          SizedBox(
            width: 120,
            height: 120,
            child: CustomPaint(painter: _ArcPainter(aqi: aqi)),
          ),
          // 中心文字 - 对齐 Android Column[Text(aqi 44sp Medium White), Text(category 16sp Normal White)]
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$aqi',
                style: const TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontSize: 44,
                  fontWeight: FontWeight.w500, // Medium
                ),
              ),
              Text(
                category,
                style: const TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
          // 7 个 ValueLabel - 对齐 Android 行 397-416，用 Transform.translate 实现安卓 offset(x,y)
          _valueLabel('150', '轻度', dx: 0, dy: -90),
          _valueLabel('200', '中毒', dx: 65, dy: -65), // 保真："中毒"非"中度"
          _valueLabel('300', '重度', dx: 90, dy: 0),
          _valueLabel('500', '严重', dx: 65, dy: 65),
          _valueLabel('0', '健康', dx: -65, dy: 65),
          _valueLabel('50', '优', dx: -90, dy: 0),
          _valueLabel('100', '良', dx: -65, dy: -65),
        ],
      ),
    );
  }

  /// 单个 ValueLabel - 对齐 Android ValueLabel(value, label, offsetX, offsetY)
  Widget _valueLabel(String value, String label,
      {required double dx, required double dy}) {
    return Transform.translate(
      offset: Offset(dx, dy), // Flutter y 正向下=下，与安卓 offset y 一致
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // value 16sp Medium White
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFFFFFFFF),
              fontSize: 16,
              fontWeight: FontWeight.w500, // Medium
            ),
          ),
          // label 10sp Normal White
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFFFFFFF),
              fontSize: 10,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

/// AQI 圆弧 Painter - 对齐 Android ArcProgressBar（行 420-462）
class _ArcPainter extends CustomPainter {
  final int aqi;

  _ArcPainter({required this.aqi});

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 12.0; // 对齐 Android 12dp.toPx()
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round // 对齐 Android cap = StrokeCap.Round
      ..strokeWidth = strokeWidth;

    // 圆环矩形 - 紧贴边缘
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: (size.width - strokeWidth) / 2,
    );

    // 角度转弧度 - 对齐 Android startAngle 135f, sweepAngle 270f
    const startAngle = 135 * pi / 180; // 135° 弧度
    const sweepAngle = 270 * pi / 180; // 270° 弧度

    // 1. 背景圆弧 - 对齐 Android drawArc(bg 0xFFE0E0E0, startAngle 135f, sweepAngle 270f, useCenter false)
    paint.color = const Color(0xFFE0E0E0);
    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);

    // 2. 进度圆弧 - 对齐 Android drawArc(_aqiColor, startAngle 135f, sweepAngle 270f * progress)
    const maxValue = 300; // 对齐 Android max 300
    final progress = (aqi / maxValue).clamp(0.0, 1.0);
    paint.color = _aqiColor(aqi);
    canvas.drawArc(rect, startAngle, sweepAngle * progress, false, paint);
  }

  /// AQI 颜色分级 - 对齐 Android ArcProgressBar 行 427-434
  Color _aqiColor(int aqi) {
    if (aqi <= 50) return const Color(0xFF00C853); // 优 - 绿
    if (aqi <= 100) return const Color(0xFFFFD600); // 良 - 黄
    if (aqi <= 150) return const Color(0xFFFF9800); // 轻度 - 橙
    if (aqi <= 200) return const Color(0xFFF44336); // 中度 - 红
    if (aqi <= 300) return const Color(0xFF9C27B0); // 重度 - 紫
    return const Color(0xFF607D8B); // 严重 - 灰
  }

  @override
  bool shouldRepaint(_ArcPainter oldDelegate) => oldDelegate.aqi != aqi;
}
