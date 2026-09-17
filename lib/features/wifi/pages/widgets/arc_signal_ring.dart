// 信号强度弧形环 - 对齐 Android wifimeter/ArcSeekBar.java + activity_wifi_strength.xml 属性
// startAngle=135 sweepAngle=270 stroke=15 圆帽,底色 #1e2b38,进度渐变 #55FF7D→#2AAAF3→#55FF7D
import 'dart:math' as math;
import 'package:flutter/material.dart';

class ArcSignalRing extends StatelessWidget {
  final double progress; // 0~100
  final double size;
  final Widget? centerChild;

  const ArcSignalRing({
    super.key,
    required this.progress,
    this.size = 150,
    this.centerChild,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _ArcPainter(progress: progress.clamp(0, 100) / 100),
          ),
          if (centerChild != null) centerChild!,
        ],
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double progress;
  _ArcPainter({required this.progress});

  static const double startAngle = 135;
  static const double sweepAngle = 270;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.10; // 对齐 15/150 比例
    final rect = Rect.fromLTWH(stroke / 2, stroke / 2,
        size.width - stroke, size.height - stroke);
    const startRad = startAngle * math.pi / 180;
    const sweepRad = sweepAngle * math.pi / 180;

    // 背景弧(对齐 arcNormalColor #1e2b38)
    final bgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF1E2B38);
    canvas.drawArc(rect, startRad, sweepRad, false, bgPaint);

    // 进度弧(SweepGradient #55FF7D→#2AAAF3→#55FF7D 沿弧方向)
    final progressSweep = sweepRad * progress;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..shader = const SweepGradient(
        startAngle: startRad,
        endAngle: startRad + sweepRad,
        colors: [
          Color(0xFF55FF7D),
          Color(0xFF2AAAF3),
          Color(0xFF55FF7D),
        ],
        transform: GradientRotation(0),
        tileMode: TileMode.clamp,
      ).createShader(rect);
    canvas.drawArc(rect, startRad, progressSweep, false, paint);
  }

  @override
  bool shouldRepaint(_ArcPainter oldDelegate) => oldDelegate.progress != progress;
}
