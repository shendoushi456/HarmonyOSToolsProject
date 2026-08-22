import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../services/compass_service.dart';

/// 对齐 Android CompassActivity：由系统方向传感器驱动的指南针。
class CompassPage extends StatefulWidget {
  const CompassPage({super.key});

  @override
  State<CompassPage> createState() => _CompassPageState();
}

class _CompassPageState extends State<CompassPage> {
  final CompassService _compass = const CompassService();
  StreamSubscription<double>? _subscription;
  double _heading = 0;
  bool _unavailable = false;

  @override
  void initState() {
    super.initState();
    _subscription = _compass.headingStream.listen((heading) {
      if (mounted) setState(() => _heading = heading);
    }, onError: (_) {
      if (mounted) setState(() => _unavailable = true);
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final normalized = (_heading % 360 + 360) % 360;
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            title: const Text('指南针')),
        body: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          SizedBox(
              width: 284,
              height: 284,
              child: CustomPaint(
                  painter: _CompassPainter(heading: normalized),
                  child: Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text('${normalized.round()}°',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.w300)),
                    Text(_directionLabel(normalized),
                        style: const TextStyle(
                            color: Color(0xFFB5BEC6), fontSize: 16))
                  ])))),
          const SizedBox(height: 34),
          Text(_unavailable ? '当前设备未提供方向传感器' : '请缓慢转动设备校准方向',
              style: const TextStyle(color: Color(0xFFABB4BD), fontSize: 14))
        ])));
  }
}

String _directionLabel(double degree) {
  const labels = ['北', '东北', '东', '东南', '南', '西南', '西', '西北'];
  return labels[((degree + 22.5) ~/ 45) % 8];
}

class _CompassPainter extends CustomPainter {
  final double heading;
  const _CompassPainter({required this.heading});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0xFF7B8791);
    canvas.drawCircle(center, radius, ring);
    final marker = Paint()
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-heading * math.pi / 180);
    for (var index = 0; index < 72; index++) {
      final major = index % 9 == 0;
      marker.color = major ? Colors.white : const Color(0xFF7B8791);
      final outer = -radius + 8;
      final inner = outer + (major ? 15 : 7);
      canvas.drawLine(Offset(0, outer), Offset(0, inner), marker);
      canvas.rotate(2 * math.pi / 72);
    }
    _drawLabel(canvas, 'N', Offset(0, -radius + 38), const Color(0xFFF05A5A));
    canvas.rotate(math.pi / 2);
    _drawLabel(canvas, 'E', Offset(0, -radius + 38), Colors.white);
    canvas.rotate(math.pi / 2);
    _drawLabel(canvas, 'S', Offset(0, -radius + 38), Colors.white);
    canvas.rotate(math.pi / 2);
    _drawLabel(canvas, 'W', Offset(0, -radius + 38), Colors.white);
    canvas.restore();

    final north = Path()
      ..moveTo(center.dx, center.dy - radius + 20)
      ..lineTo(center.dx - 8, center.dy - radius + 42)
      ..lineTo(center.dx + 8, center.dy - radius + 42)
      ..close();
    canvas.drawPath(north, Paint()..color = const Color(0xFFF05A5A));
    canvas.drawCircle(center, 4, Paint()..color = Colors.white);
  }

  void _drawLabel(Canvas canvas, String label, Offset offset, Color color) {
    final painter = TextPainter(
        text: TextSpan(
            text: label,
            style: TextStyle(
                color: color, fontSize: 16, fontWeight: FontWeight.w600)),
        textDirection: TextDirection.ltr)
      ..layout();
    painter.paint(
        canvas, offset - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(covariant _CompassPainter oldDelegate) =>
      oldDelegate.heading != heading;
}
