// ChaosCompassPainter - 指南针自定义绘制
// 对齐 Android third-module/toolslibrary/src/main/java/com/base/toolslibrary/view/ChaosCompassView.java
// 复刻 onDraw 7 步绘制(剔除冒泡排序/二分查找垃圾代码)
// 注意:3D Camera 矩阵由 Page 层 Transform 处理, painter 仅做 2D 绘制
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

class ChaosCompassPainter extends CustomPainter {
  ChaosCompassPainter({required this.azimuth});

  /// 方位角 0-360(对齐 ChaosCompassView.java mVal)
  final double azimuth;

  @override
  void paint(Canvas canvas, Size size) {
    // onMeasure - 对齐 ChaosCompassView.java:556-570
    final width = math.min(size.width, size.height);
    final mTextHeight = width / 3;
    final mCenterX = width / 2;
    final mOutSideRadius = width * 3 / 8;
    final mCircumRadius = mOutSideRadius * 4 / 5;
    // 罗盘圆心 Y(对齐 mOutSideRadius + mTextHeight)
    final centerY = mOutSideRadius + mTextHeight;

    // 1. drawText - 顶部方位文字(对齐 ChaosCompassView.java:502-535)
    _drawText(canvas, width, mTextHeight);

    // 2. drawCompassOutSide - 外圈小三角+4弧(对齐 L478-499)
    _drawCompassOutSide(canvas, width, mTextHeight, mOutSideRadius);

    // 3. drawCompassCircum - 外接圆+偏转红弧(对齐 L433-453)
    _drawCompassCircum(canvas, azimuth, width, mTextHeight, mOutSideRadius, mCircumRadius);

    // 4. drawInnerCricle - 内圆辐射渐变(对齐 L323-325)
    _drawInnerCircle(canvas, width, centerY, mCircumRadius);

    // 5. drawCompassDegreeScale - 240刻度+NESW(对齐 L358-410)
    _drawCompassDegreeScale(canvas, azimuth, width, mCenterX, mTextHeight, mOutSideRadius, mCircumRadius);

    // 6. drawCenterText - 圆心数字°(对齐 L328-345)
    _drawCenterText(canvas, azimuth, width, centerY);
  }

  /// 1. 顶部方位文字 - 对齐 drawText L513-534
  void _drawText(Canvas canvas, double width, double mTextHeight) {
    final text = _directionText(azimuth);
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 80,
          fontWeight: FontWeight.normal,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(width / 2 - tp.width / 2, mTextHeight / 2 - tp.height / 2));
  }

  /// 2. 外圈小三角形 + 4 段圆弧 - 对齐 drawCompassOutSide L478-499
  void _drawCompassOutSide(
    Canvas canvas,
    double width,
    double mTextHeight,
    double mOutSideRadius,
  ) {
    canvas.save();

    // 小三角形(对齐 L480-488): mTriangleHeight=40, mTriangleSide=46.18
    const mTriangleHeight = 40.0;
    const mTriangleSide = 46.18;
    final trianglePath = Path()
      ..moveTo(width / 2, mTextHeight - mTriangleHeight)
      ..lineTo(width / 2 - mTriangleSide / 2, mTextHeight)
      ..lineTo(width / 2 + mTriangleSide / 2, mTextHeight)
      ..close();
    // 外圈三角形 paint(对齐 mOutSideCircumPaint, 颜色用浅灰)
    final outsidePaint = Paint()
      ..color = AppColors.compassLightGray
      ..style = PaintingStyle.fill;
    canvas.drawPath(trianglePath, outsidePaint);

    // 4 段圆弧 - 对齐 L495-498
    // Arc rect: (width/2-mOutSideRadius, mTextHeight, width/2+mOutSideRadius, mTextHeight+mOutSideRadius*2)
    final arcRect = Rect.fromLTWH(
      width / 2 - mOutSideRadius,
      mTextHeight,
      mOutSideRadius * 2,
      mOutSideRadius * 2,
    );
    // 度→弧度
    const deg = math.pi / 180;
    // L495: 浅灰弧 -80°起 120°
    canvas.drawArc(
      arcRect,
      -80 * deg,
      120 * deg,
      false,
      Paint()
        ..color = AppColors.compassLightGray
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5,
    );
    // L496: 深灰弧 40°起 20°
    canvas.drawArc(
      arcRect,
      40 * deg,
      20 * deg,
      false,
      Paint()
        ..color = AppColors.compassDeepGray
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    // L497: 浅灰弧 -100°起 -20°
    canvas.drawArc(
      arcRect,
      -100 * deg,
      -20 * deg,
      false,
      Paint()
        ..color = AppColors.compassLightGray
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5,
    );
    // L498: 暗红弧 -120°起 -120°
    canvas.drawArc(
      arcRect,
      -120 * deg,
      -120 * deg,
      false,
      Paint()
        ..color = AppColors.compassDarkRed
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5,
    );

    canvas.restore();
  }

  /// 3. 外接圆 + 偏转红弧 - 对齐 drawCompassCircum L433-453
  void _drawCompassCircum(
    Canvas canvas,
    double val,
    double width,
    double mTextHeight,
    double mOutSideRadius,
    double mCircumRadius,
  ) {
    canvas.save();
    const deg = math.pi / 180;
    final centerY = mOutSideRadius + mTextHeight;

    // 旋转 -val(对齐 L436) - Flutter canvas.rotate 只接受弧度, 需 translate 配合
    canvas.translate(width / 2, centerY);
    canvas.rotate(-val * deg);
    canvas.translate(-width / 2, -centerY);

    // 小三角形(对齐 L435-442): mTriangleHeight = (mOutSideRadius-mCircumRadius)/2
    final mTriangleHeight = (mOutSideRadius - mCircumRadius) / 2;
    final mTriangleSide = (mTriangleHeight / math.sqrt(3)) * 2;
    final trianglePath = Path()
      ..moveTo(width / 2, mTriangleHeight + mTextHeight)
      ..lineTo(width / 2 - mTriangleSide / 2, mTextHeight + mTriangleHeight * 2)
      ..lineTo(width / 2 + mTriangleSide / 2, mTextHeight + mTriangleHeight * 2)
      ..close();
    // 外接圆三角形 paint(mCircumPaint)
    canvas.drawPath(
      trianglePath,
      Paint()
        ..color = AppColors.compassLightGray
        ..style = PaintingStyle.fill,
    );

    // 350° 深灰弧(对齐 L444) - 外接圆 rect
    final circumRect = Rect.fromCircle(center: Offset(width / 2, centerY), radius: mCircumRadius);
    canvas.drawArc(
      circumRect,
      -85 * deg,
      350 * deg,
      false,
      Paint()
        ..color = AppColors.compassDeepGray
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5,
    );

    // 偏转红弧(对齐 L446-452) - mAnglePaint 红色
    final anglePaint = Paint()
      ..color = AppColors.compassRed
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;
    if (val <= 180) {
      canvas.drawArc(circumRect, -85 * deg, val * deg, false, anglePaint);
    } else {
      final valCompare = (360 - val) * deg;
      canvas.drawArc(circumRect, -95 * deg, -valCompare, false, anglePaint);
    }

    canvas.restore();
  }

  /// 4. 内圆辐射渐变 - 对齐 drawInnerCricle L323-325
  void _drawInnerCircle(Canvas canvas, double width, double centerY, double mCircumRadius) {
    final radius = mCircumRadius - 40;
    if (radius <= 0) return;
    // RadialGradient #323232 → #000000
    final paint = Paint()
      ..shader = const RadialGradient(
        colors: [AppColors.compassInnerStart, AppColors.compassInnerEnd],
      ).createShader(Rect.fromCircle(center: Offset(width / 2, centerY), radius: radius));
    canvas.drawCircle(Offset(width / 2, centerY), radius, paint);
  }

  /// 5. 240 刻度 + NESW - 对齐 drawCompassDegreeScale L358-410
  void _drawCompassDegreeScale(
    Canvas canvas,
    double val,
    double width,
    double mCenterX,
    double mTextHeight,
    double mOutSideRadius,
    double mCircumRadius,
  ) {
    canvas.save();
    const deg = math.pi / 180;
    final centerY = mOutSideRadius + mTextHeight;

    // 旋转 -val(对齐 L375)
    canvas.translate(mCenterX, centerY);
    canvas.rotate(-val * deg);
    canvas.translate(-mCenterX, -centerY);

    // 刻度线起止 Y(对齐 L379/381)
    final lineStartY = mTextHeight + mOutSideRadius - mCircumRadius + 10;
    final lineEndY = mTextHeight + mOutSideRadius - mCircumRadius + 30;
    final lineX = width / 2;

    final deepGrayPaint = Paint()
      ..color = AppColors.compassDeepGray
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final lightGrayPaint = Paint()
      ..color = AppColors.compassLightGray
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // 文字 paint(对齐 mNorthPaint/mOthersPaint/mSamllDegreePaint)
    final northPaint = TextPainter(textDirection: TextDirection.ltr);
    final othersTp = TextPainter(textDirection: TextDirection.ltr);
    final smallTp = TextPainter(textDirection: TextDirection.ltr);
    final textY = mTextHeight + mOutSideRadius - mCircumRadius + 40;

    for (var i = 0; i < 240; i++) {
      // 画刻度线(对齐 L378-382)
      if (i == 0 || i == 60 || i == 120 || i == 180) {
        canvas.drawLine(Offset(lineX, lineStartY), Offset(lineX, lineEndY), deepGrayPaint);
      } else {
        canvas.drawLine(Offset(lineX, lineStartY), Offset(lineX, lineEndY), lightGrayPaint);
      }

      // 画文字(对齐 L383-407)
      _drawScaleText(canvas, northPaint, othersTp, smallTp, i, lineX, textY);

      // 每次循环旋转 1.5°(对齐 L408)
      canvas.translate(mCenterX, centerY);
      canvas.rotate(1.5 * deg);
      canvas.translate(-mCenterX, -centerY);
    }

    canvas.restore();
  }

  void _drawScaleText(
    Canvas canvas,
    TextPainter northTp,
    TextPainter othersTp,
    TextPainter smallTp,
    int i,
    double x,
    double y,
  ) {
    TextPainter? tp;
    String? text;
    double fontSize = 18;
    Color color = AppColors.compassLightGray;
    if (i == 0) {
      text = 'N'; fontSize = 30; color = AppColors.compassRed;
    } else if (i == 60) {
      text = 'E'; fontSize = 30; color = Colors.white;
    } else if (i == 120) {
      text = 'S'; fontSize = 30; color = Colors.white;
    } else if (i == 180) {
      text = 'W'; fontSize = 30; color = Colors.white;
    } else if (i == 20) {
      text = '30'; fontSize = 18; color = AppColors.compassLightGray;
    } else if (i == 40) {
      text = '60'; fontSize = 18; color = AppColors.compassLightGray;
    } else if (i == 80) {
      text = '120'; fontSize = 18; color = AppColors.compassLightGray;
    } else if (i == 100) {
      text = '150'; fontSize = 18; color = AppColors.compassLightGray;
    } else if (i == 140) {
      text = '210'; fontSize = 18; color = AppColors.compassLightGray;
    } else if (i == 160) {
      text = '240'; fontSize = 18; color = AppColors.compassLightGray;
    } else if (i == 200) {
      text = '300'; fontSize = 18; color = AppColors.compassLightGray;
    } else if (i == 220) {
      text = '330'; fontSize = 18; color = AppColors.compassLightGray;
    }

    if (text == null) return;
    tp = (i == 0 || i == 60 || i == 120 || i == 180) ? northTp : (text.length > 2 ? smallTp : smallTp);
    tp.text = TextSpan(
      text: text,
      style: TextStyle(color: color, fontSize: fontSize),
    );
    tp.layout();
    tp.paint(canvas, Offset(x - tp.width / 2, y));
  }

  /// 6. 圆心数字° - 对齐 drawCenterText L328-345
  void _drawCenterText(Canvas canvas, double val, double width, double centerY) {
    final tp = TextPainter(
      text: TextSpan(
        text: '${val.toInt()}°',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 120,
          fontWeight: FontWeight.normal,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(width / 2 - tp.width / 2, centerY - tp.height / 2));
  }

  /// 方位文字 - 对齐 ChaosCompassView.java:513-529
  String _directionText(double val) {
    if (val <= 15 || val >= 345) return '北';
    if (val <= 75) return '东北';
    if (val <= 105) return '东';
    if (val <= 165) return '东南';
    if (val <= 195) return '南';
    if (val <= 255) return '东南';
    if (val <= 285) return '东';
    return '东北';
  }

  @override
  bool shouldRepaint(covariant ChaosCompassPainter oldDelegate) {
    return oldDelegate.azimuth != azimuth;
  }
}
