// Android ProtractorActivity/CycleRulerView 的 Flutter 实现。
import 'dart:math' as math;
import 'package:flutter/material.dart';

class ProtractorToolPage extends StatefulWidget {
  const ProtractorToolPage({super.key});

  @override
  State<ProtractorToolPage> createState() => _ProtractorToolPageState();
}

class _ProtractorToolPageState extends State<ProtractorToolPage> {
  double _angle = 90;
  bool _cameraOn = false;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('量角器'),
          backgroundColor: const Color(0xFFF0FFB8),
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: Container(
                  color: _cameraOn ? Colors.black : const Color(0xFFF6C766)),
            ),
            Positioned.fill(
              child: GestureDetector(
                onPanUpdate: (details) {
                  final box = context.findRenderObject() as RenderBox;
                  final point = box.globalToLocal(details.globalPosition);
                  final center =
                      Offset(box.size.width / 2, box.size.height * .78);
                  // Android CycleRulerView 以左端为 0°、右端为 180°。
                  // 屏幕坐标 Y 轴向下，因此需要将数学坐标角度反向映射。
                  final radians =
                      math.atan2(center.dy - point.dy, point.dx - center.dx);
                  final degrees = 180 - radians * 180 / math.pi;
                  setState(() => _angle = degrees.clamp(0, 180));
                },
                child: CustomPaint(
                  painter: _ProtractorPainter(_angle, dark: _cameraOn),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
            Positioned(
              left: 20,
              top: 20,
              child: Switch.adaptive(
                value: _cameraOn,
                onChanged: (value) => setState(() => _cameraOn = value),
                activeColor: Colors.white,
              ),
            ),
            Positioned(
              bottom: 35,
              left: 0,
              right: 0,
              child: Center(
                child: Text('${_angle.round()}°',
                    style: TextStyle(
                        color: _cameraOn ? Colors.white : Colors.black,
                        fontSize: 40)),
              ),
            ),
          ],
        ),
      );
}

class _ProtractorPainter extends CustomPainter {
  final double angle;
  final bool dark;
  _ProtractorPainter(this.angle, {required this.dark});

  @override
  void paint(Canvas canvas, Size size) {
    final color = dark ? Colors.white : const Color(0xFF757575);
    final center = Offset(size.width / 2, size.height * .78);
    final radius = size.width / 2;
    canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        math.pi,
        math.pi,
        true,
        Paint()..color = dark ? const Color(0x33000000) : Colors.white);
    final tickPaint = Paint()
      ..color = color
      ..strokeWidth = 2;
    for (var i = 0; i <= 180; i++) {
      final rad = math.pi + math.pi * i / 180;
      final outer = Offset(center.dx + math.cos(rad) * radius,
          center.dy + math.sin(rad) * radius);
      final innerRadius = i % 10 == 0
          ? radius - 24
          : i % 5 == 0
              ? radius - 17
              : radius - 10;
      final inner = Offset(center.dx + math.cos(rad) * innerRadius,
          center.dy + math.sin(rad) * innerRadius);
      canvas.drawLine(inner, outer, tickPaint);
    }
    final rad = math.pi + math.pi * angle / 180;
    final end = Offset(center.dx + math.cos(rad) * (radius - 12),
        center.dy + math.sin(rad) * (radius - 12));
    canvas.drawLine(
        center,
        end,
        Paint()
          ..color = color
          ..strokeWidth = 2);
    canvas.drawCircle(center, 6, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _ProtractorPainter oldDelegate) =>
      oldDelegate.angle != angle || oldDelegate.dark != dark;
}
