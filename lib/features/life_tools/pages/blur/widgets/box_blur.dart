// box-blur 算法 - Dart 自写(对齐 Android jp.wasabeef:blurry 高斯模糊)
// 可分离滤波器: 水平 1D box-blur + 垂直 1D box-blur, 重复 3 次近似高斯
import 'dart:typed_data';
import 'package:image/image.dart' as img;

/// 对 image 包的 Image 应用 box-blur
/// [radius] 模糊半径(像素)
img.Image applyBoxBlur(img.Image src, int radius) {
  if (radius < 1) return src;
  var result = src;
  // 重复 3 次近似高斯(对齐 Blurry RenderScript 高斯模糊视觉效果)
  for (var i = 0; i < 3; i++) {
    result = _boxBlurPass(result, radius);
  }
  return result;
}

img.Image _boxBlurPass(img.Image src, int radius) {
  final w = src.width;
  final h = src.height;
  final dst = img.Image(width: w, height: h);
  final div = radius * 2 + 1;

  // 水平 pass
  for (var y = 0; y < h; y++) {
    var rSum = 0, gSum = 0, bSum = 0, aSum = 0;
    // 初始窗口
    for (var k = -radius; k <= radius; k++) {
      final px = src.getPixel(k.clamp(0, w - 1), y);
      rSum += px.r.toInt();
      gSum += px.g.toInt();
      bSum += px.b.toInt();
      aSum += px.a.toInt();
    }
    for (var x = 0; x < w; x++) {
      dst.setPixelRgba(
        x, y,
        (rSum / div).round(),
        (gSum / div).round(),
        (bSum / div).round(),
        (aSum / div).round(),
      );
      // 滑动窗口: 移除左边, 添加右边
      final xOut = (x - radius - 1).clamp(0, w - 1);
      final xIn = (x + radius + 1).clamp(0, w - 1);
      final pOut = src.getPixel(xOut, y);
      final pIn = src.getPixel(xIn, y);
      rSum += pIn.r.toInt() - pOut.r.toInt();
      gSum += pIn.g.toInt() - pOut.g.toInt();
      bSum += pIn.b.toInt() - pOut.b.toInt();
      aSum += pIn.a.toInt() - pOut.a.toInt();
    }
  }

  // 垂直 pass
  for (var x = 0; x < w; x++) {
    var rSum = 0, gSum = 0, bSum = 0, aSum = 0;
    for (var k = -radius; k <= radius; k++) {
      final px = dst.getPixel(x, k.clamp(0, h - 1));
      rSum += px.r.toInt();
      gSum += px.g.toInt();
      bSum += px.b.toInt();
      aSum += px.a.toInt();
    }
    for (var y = 0; y < h; y++) {
      src.setPixelRgba(
        x, y,
        (rSum / div).round(),
        (gSum / div).round(),
        (bSum / div).round(),
        (aSum / div).round(),
      );
      final yOut = (y - radius - 1).clamp(0, h - 1);
      final yIn = (y + radius + 1).clamp(0, h - 1);
      final pOut = dst.getPixel(x, yOut);
      final pIn = dst.getPixel(x, yIn);
      rSum += pIn.r.toInt() - pOut.r.toInt();
      gSum += pIn.g.toInt() - pOut.g.toInt();
      bSum += pIn.b.toInt() - pOut.b.toInt();
      aSum += pIn.a.toInt() - pOut.a.toInt();
    }
  }
  return src;
}
