// PalettePainter - 画板绘制
// 对齐 Android PaletteView.java:600-616 onDraw drawBitmap + L141-143 Xfermode
// CustomPainter 遍历 paths list 重绘(Flutter 无双缓冲, 用 list 重绘, MAX_CACHE_STEP=20 性能足够)
import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../viewmodels/draw_state.dart';

class PalettePainter extends CustomPainter {
  PalettePainter({required this.paths});

  final List<PathDrawingInfo> paths;

  @override
  void paint(Canvas canvas, Size size) {
    // 遍历所有 path 重绘 - 对齐 PaletteView.java:600-616 onDraw drawBitmap
    // BlendMode.clear 需要 saveLayer 才能正确擦除(透明)
    canvas.saveLayer(Offset.zero & size, Paint());
    for (final info in paths) {
      final paint = Paint()
        ..color = info.paint.color
        ..strokeWidth = info.paint.strokeWidth
        ..blendMode = info.paint.blendMode
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..isAntiAlias = true;
      canvas.drawPath(info.path, paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant PalettePainter oldDelegate) {
    return oldDelegate.paths != paths;
  }
}
