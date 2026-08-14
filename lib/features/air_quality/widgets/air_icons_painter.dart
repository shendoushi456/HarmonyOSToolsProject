// 空气质量矢量图标 - 对齐 Android AirVectorIcon(行 295-374)
// 4 个 CustomPainter:穿衣(T恤)/出行(车)/旅游(飞机)/防晒(太阳)
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/air_index_item.dart';

/// 穿衣图标(T恤) - 对齐 AirIconType.CLOTHING(行 300-317)
class ClothingIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.airBlue
      ..style = PaintingStyle.fill;
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w * .31, h * .18)
      ..lineTo(w * .45, h * .28)
      ..lineTo(w * .55, h * .28)
      ..lineTo(w * .69, h * .18)
      ..lineTo(w * .9, h * .36)
      ..lineTo(w * .75, h * .52)
      ..lineTo(w * .68, h * .47)
      ..lineTo(w * .68, h * .86)
      ..lineTo(w * .32, h * .86)
      ..lineTo(w * .32, h * .47)
      ..lineTo(w * .25, h * .52)
      ..lineTo(w * .1, h * .36)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 出行图标(车) - 对齐 AirIconType.TRANSIT(行 319-335)
class TransitIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final blue = Paint()..color = AppColors.airBlue;
    final tagBlue = Paint()..color = AppColors.airTagBlue;
    final w = size.width;
    final h = size.height;
    final strokePaint = Paint()
      ..color = AppColors.airBlue
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    // 车身(圆角矩形)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * .21, h * .12, w * .58, h * .68),
        const Radius.circular(5),
      ),
      blue,
    );
    // 车窗
    canvas.drawRect(
      Rect.fromLTWH(w * .3, h * .25, w * .4, h * .23),
      tagBlue,
    );
    // 车轮
    canvas.drawCircle(Offset(w * .34, h * .65), 2.2, tagBlue);
    canvas.drawCircle(Offset(w * .66, h * .65), 2.2, tagBlue);
    // 车腿
    canvas.drawLine(
      Offset(w * .27, h * .87),
      Offset(w * .42, h * .76),
      strokePaint,
    );
    canvas.drawLine(
      Offset(w * .73, h * .87),
      Offset(w * .58, h * .76),
      strokePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 旅游图标(飞机) - 对齐 AirIconType.TRAVEL(行 337-355)
class TravelIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.airBlue
      ..style = PaintingStyle.fill;
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w * .08, h * .43)
      ..lineTo(w * .41, h * .49)
      ..lineTo(w * .77, h * .13)
      ..quadraticBezierTo(w * .88, h * .04, w * .91, h * .12)
      ..quadraticBezierTo(w * .93, h * .19, w * .86, h * .29)
      ..lineTo(w * .62, h * .58)
      ..lineTo(w * .75, h * .86)
      ..lineTo(w * .63, h * .91)
      ..lineTo(w * .43, h * .67)
      ..lineTo(w * .25, h * .85)
      ..lineTo(w * .17, h * .8)
      ..lineTo(w * .3, h * .58)
      ..lineTo(w * .06, h * .51)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 防晒/太阳图标 - 对齐 AirIconType.SUN(行 357-371)
class SunIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.airBlue;
    final strokePaint = Paint()
      ..color = AppColors.airBlue
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    final center = Offset(size.width / 2, size.height / 2);
    final minDim = size.shortestSide;
    // 中心圆
    canvas.drawCircle(center, minDim * .2, paint);
    // 8 条放射线
    for (var i = 0; i < 8; i++) {
      final angle = i * 45 * math.pi / 180;
      final start = minDim * .31;
      final end = minDim * .45;
      canvas.drawLine(
        Offset(
          center.dx + math.cos(angle) * start,
          center.dy + math.sin(angle) * start,
        ),
        Offset(
          center.dx + math.cos(angle) * end,
          center.dy + math.sin(angle) * end,
        ),
        strokePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 根据图标类型获取对应 Painter
CustomPainter painterForType(AirIconType type) {
  switch (type) {
    case AirIconType.clothing:
      return ClothingIconPainter();
    case AirIconType.transit:
      return TransitIconPainter();
    case AirIconType.travel:
      return TravelIconPainter();
    case AirIconType.sun:
      return SunIconPainter();
  }
}
