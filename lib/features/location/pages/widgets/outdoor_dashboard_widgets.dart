import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../weather/models/weather_model.dart';
import '../../models/location_snapshot.dart';

const _textDark = Color(0xFF022246);
const _cardWhite = Color(0xD9FFFFFF);
const _blue = Color(0xFF498BDA);

/// 对齐 Android 的 LocationInfoCard；定位授权状态由上层 ViewModel 提供。
class LocationInfoCard extends StatelessWidget {
  final LocationSnapshot? location;
  final bool isLoading;
  final bool needsPermission;
  final String? error;
  final VoidCallback onRequestPermission;

  const LocationInfoCard({
    super.key,
    required this.location,
    required this.isLoading,
    required this.needsPermission,
    required this.error,
    required this.onRequestPermission,
  });

  @override
  Widget build(BuildContext context) {
    final hasLocation = location != null;
    final title = hasLocation
        ? (location!.address.isEmpty ? '当前位置' : location!.address)
        : isLoading
            ? '获取位置中...'
            : needsPermission
                ? '授权位置后，可显示当前地点'
                : error ?? '暂时无法获取当前位置';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
      decoration: BoxDecoration(
        color: _cardWhite,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(children: [
        Image.asset(AppAssets.outdoorAddressIcon, width: 22, height: 22),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: _textDark,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              if (hasLocation)
                Text(
                  '${location!.latitude.toStringAsFixed(4)}, ${location!.longitude.toStringAsFixed(4)}',
                  style:
                      const TextStyle(color: Color(0xFF666666), fontSize: 11),
                ),
            ],
          ),
        ),
        if (!hasLocation && !isLoading)
          TextButton(
            onPressed: onRequestPermission,
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF1C79E9),
              minimumSize: const Size(55, 27),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7)),
            ),
            child: const Text('允许',
                style: TextStyle(color: Colors.white, fontSize: 13)),
          ),
      ]),
    );
  }
}

class OutdoorMetric {
  final String title;
  final String value;
  final String iconAsset;

  const OutdoorMetric(this.title, this.value, this.iconAsset);
}

class OutdoorMetricGrid extends StatelessWidget {
  final List<OutdoorMetric> metrics;

  const OutdoorMetricGrid({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: metrics.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.5,
          ),
          itemBuilder: (context, index) => _MetricCard(metric: metrics[index]),
        ),
      );
}

class _MetricCard extends StatelessWidget {
  final OutdoorMetric metric;

  const _MetricCard({required this.metric});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        decoration: BoxDecoration(
          color: _cardWhite,
          borderRadius: BorderRadius.circular(13),
        ),
        child: Row(children: [
          Image.asset(metric.iconAsset, width: 40, height: 40),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(metric.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: _textDark,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 3),
                Text(metric.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Color(0xFF68A1E0), fontSize: 12)),
              ],
            ),
          ),
        ]),
      );
}

class AltitudeCard extends StatelessWidget {
  final double? altitude;

  const AltitudeCard({super.key, required this.altitude});

  @override
  Widget build(BuildContext context) {
    final value = altitude == null ? '--' : altitude!.round().toString();
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
          color: _cardWhite, borderRadius: BorderRadius.circular(13)),
      child: Row(
        children: [
          Image.asset(AppAssets.outdoorAltitudeIcon, width: 71, height: 71),
          const Spacer(),
          Text('$value｜海拔高度（M）',
              style: const TextStyle(
                  color: _textDark, fontSize: 18, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

/// 对齐 Android CompassView：实心蓝色圆盘、外环、双向指针和随方位旋转的东南西北。
class OutdoorCompass extends StatelessWidget {
  final double heading;

  const OutdoorCompass({super.key, required this.heading});

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 320,
        width: double.infinity,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(end: heading),
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          builder: (_, value, __) => CustomPaint(
            painter: _OutdoorCompassPainter(heading: value),
          ),
        ),
      );
}

class _OutdoorCompassPainter extends CustomPainter {
  final double heading;

  const _OutdoorCompassPainter({required this.heading});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) * .425;
    final outerRadius = maxRadius - 1;
    final solidRadius = outerRadius - 16;
    final direction = -heading * math.pi / 180;

    canvas.drawCircle(center, solidRadius, Paint()..color = _blue);
    canvas.drawCircle(
      center,
      outerRadius,
      Paint()
        ..color = const Color(0xFFAFCDE2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final arrowStart = (solidRadius + outerRadius) / 2;
    final arrowEnd = outerRadius + 12;
    _drawArrow(canvas, center, direction, arrowStart, arrowEnd, Colors.red);
    _drawArrow(canvas, center, direction + math.pi, arrowStart, arrowEnd,
        Colors.white);

    _drawDirections(canvas, center, solidRadius - 24, direction);
    _drawCenteredText(
      canvas,
      '${heading.round()}°',
      center,
      solidRadius * .35,
      Colors.white,
      FontWeight.bold,
    );
  }

  void _drawArrow(Canvas canvas, Offset center, double rad, double start,
      double end, Color color) {
    final perpendicular = (end - start) / math.sqrt(3);
    Offset point(double radius, double shift) => Offset(
          center.dx + radius * math.sin(rad) + shift * math.cos(rad),
          center.dy - radius * math.cos(rad) + shift * math.sin(rad),
        );
    final path = Path()
      ..moveTo(point(end, 0).dx, point(end, 0).dy)
      ..lineTo(point(start, -perpendicular).dx, point(start, -perpendicular).dy)
      ..lineTo(point(start, perpendicular).dx, point(start, perpendicular).dy)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _drawDirections(
      Canvas canvas, Offset center, double radius, double rad) {
    const labels = ['北', '东', '南', '西'];
    for (var index = 0; index < labels.length; index++) {
      final angle = rad + index * math.pi / 2;
      final offset = Offset(
        center.dx + radius * math.sin(angle),
        center.dy - radius * math.cos(angle),
      );
      _drawCenteredText(
        canvas,
        labels[index],
        offset,
        index == 0 ? radius * .15 : radius * .13,
        index == 0 ? Colors.red : Colors.white,
        index == 0 ? FontWeight.bold : FontWeight.normal,
      );
    }
  }

  void _drawCenteredText(
    Canvas canvas,
    String text,
    Offset center,
    double size,
    Color color,
    FontWeight weight,
  ) {
    final painter = TextPainter(
      text: TextSpan(
          text: text,
          style: TextStyle(color: color, fontSize: size, fontWeight: weight)),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
        canvas, center - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(covariant _OutdoorCompassPainter oldDelegate) =>
      oldDelegate.heading != heading;
}

List<OutdoorMetric> altitudeMetrics(DailyWeather? weather, AirQuality? air) => [
      OutdoorMetric('空气质量', air?.category ?? '良', AppAssets.outdoorAirIcon),
      OutdoorMetric('太阳辐射', weather?.uvIndex ?? '--', AppAssets.outdoorUvIcon),
      OutdoorMetric('风向', weather?.windDirDay ?? '--',
          AppAssets.outdoorWindDirectionIcon),
      OutdoorMetric('风速', _windSpeed(weather), AppAssets.outdoorWindSpeedIcon),
    ];

List<OutdoorMetric> compassMetrics(
        LocationSnapshot? location, DailyWeather? weather) =>
    [
      OutdoorMetric(
          '经度', _coordinate(location?.longitude), AppAssets.outdoorAirIcon),
      OutdoorMetric(
          '纬度', _coordinate(location?.latitude), AppAssets.outdoorUvIcon),
      OutdoorMetric('风速', _windSpeed(weather), AppAssets.outdoorWindSpeedIcon),
      OutdoorMetric(
          '海拔',
          location?.hasAltitude == true
              ? '${location!.altitude!.round()} M'
              : '--',
          AppAssets.outdoorWindDirectionIcon),
    ];

String _coordinate(double? value) =>
    value == null ? '--' : value.toStringAsFixed(4);
String _windSpeed(DailyWeather? weather) =>
    weather == null || weather.windSpeedDay.isEmpty
        ? '--'
        : '${weather.windSpeedDay}km/h';
