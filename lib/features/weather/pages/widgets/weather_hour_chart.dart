import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../models/weather_model.dart';

class WeatherHourChartCard extends StatelessWidget {
  final List<HourForecast> hourly;
  const WeatherHourChartCard({super.key, required this.hourly});

  @override
  Widget build(BuildContext context) {
    final temps = hourly
        .take(8)
        .map((e) => int.tryParse(e.temperature.replaceAll('°', '')) ?? 0)
        .toList();
    final labels = hourly.take(8).map((e) => e.time).toList();
    return Container(
      margin: const EdgeInsets.only(top: 27, left: 20, right: 20),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 15),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
                color: Color(0x22000000), blurRadius: 4, offset: Offset(0, 2))
          ]),
      child: Column(children: [
        Row(children: [
          const Text('24小时预报',
              style: TextStyle(fontSize: 16, color: Color(0xFF191919))),
          const Spacer(),
          Image.asset(AppAssets.toolboxWeatherDotYellow, width: 6, height: 6),
          const SizedBox(width: 4),
          const Text('最高温度',
              style: TextStyle(fontSize: 12, color: Color(0xFF191919)))
        ]),
        const SizedBox(height: 20),
        SizedBox(
            height: 100,
            child: CustomPaint(
                painter: _WeatherHourPainter(temps),
                child: const SizedBox.expand())),
        const SizedBox(height: 4),
        Row(children: [
          for (final label in labels)
            Expanded(
                child: Center(
                    child: Text(label,
                        style: const TextStyle(
                            fontSize: 8, color: Color(0xFF191919)))))
        ]),
      ]),
    );
  }
}

class _WeatherHourPainter extends CustomPainter {
  final List<int> temps;
  _WeatherHourPainter(this.temps);
  @override
  void paint(Canvas canvas, Size size) {
    if (temps.isEmpty) return;
    final max = temps.reduce((a, b) => a > b ? a : b);
    final min = temps.reduce((a, b) => a < b ? a : b);
    final range = (max - min).clamp(1, 100);
    const side = 12.0, top = 15.0, chartH = 35.0;
    final step =
        temps.length > 1 ? (size.width - side * 2) / (temps.length - 1) : 0.0;
    final points = List.generate(
        temps.length,
        (i) => Offset(
            side + i * step, top + (1 - (temps[i] - min) / range) * chartH));
    final line = Paint()
      ..color = const Color(0x5589B9F7)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    final curve = Paint()
      ..color = const Color(0xFF89B9F7)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final point = Paint()..style = PaintingStyle.fill;
    for (final p in points) {
      canvas.drawLine(Offset(p.dx, p.dy + 3), Offset(p.dx, size.height), line);
    }
    if (points.length > 1) {
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (var i = 1; i < points.length; i++) {
        final a = points[i - 1],
            b = points[i],
            mx = (a.dx + b.dx) / 2,
            my = (a.dy + b.dy) / 2;
        path.quadraticBezierTo(a.dx, a.dy, mx, my);
      }
      path.lineTo(points.last.dx, points.last.dy);
      canvas.drawPath(path, curve);
    }
    for (var i = 0; i < points.length; i++) {
      final c = i == 3 ? const Color(0xFFFFB135) : const Color(0xFF89B9F7);
      point.color = c;
      canvas.drawCircle(points[i], 3, point);
      final tp = TextPainter(
          text: TextSpan(
              text: '${temps[i]}°', style: TextStyle(fontSize: 8, color: c)),
          textDirection: TextDirection.ltr)
        ..layout();
      tp.paint(canvas, Offset(points[i].dx - tp.width / 2, points[i].dy - 14));
    }
  }

  @override
  bool shouldRepaint(covariant _WeatherHourPainter oldDelegate) =>
      oldDelegate.temps != temps;
}
