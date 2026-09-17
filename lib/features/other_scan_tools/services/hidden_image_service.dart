// 隐藏图合成服务 - 对齐 Android pic_toolslibrary BitmapPixelUtil.makeHideImage
// 流程(与安卓逐步对应):
//   上层图: 去色 -> 调亮色阶(120,255) -> 反相
//   下层图: 去色 -> 调暗色阶(0,135)
//   线性减淡(上层,下层) -> 取红色通道alpha作蒙版 -> 划分(上层,下层) -> 蒙版合成
// 色阶表按安卓 getColorLevelTable(outputMin, outputMax) 公式运行时生成。
// 划分步骤里除零/溢出的通道值复刻 Java (int) 强转 + Color.argb 位截断(&0xFF)语义。
// 注: 本工程语言版本不支持 records，compute 入参用 _HideArgs 包装。
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

class HiddenImageService {
  HiddenImageService._();

  static final HiddenImageService instance = HiddenImageService._();

  /// 对齐 Activity.handleStartButtonEvent + BitmapPixelUtil.makeHideImage。
  /// 返回 PNG 字节；任一图解码失败返回 null(安卓返回 null 后仅关弹窗)。
  Future<Uint8List?> makeHideImage(Uint8List outerBytes, Uint8List interBytes) {
    // 对齐安卓: 合成在后台线程执行。
    return compute(_makeHideImageSync, _HideArgs(outerBytes, interBytes));
  }

  static Uint8List? _makeHideImageSync(_HideArgs args) {
    var outer = img.decodeImage(args.outer);
    var inter = img.decodeImage(args.inter);
    if (outer == null || inter == null) return null;

    // 对齐 Activity: 字节大的一张缩放到另一张的尺寸。
    if (args.outer.lengthInBytes > args.inter.lengthInBytes) {
      outer = img.copyResize(outer, width: inter.width, height: inter.height);
    } else if (args.outer.lengthInBytes < args.inter.lengthInBytes) {
      inter = img.copyResize(inter, width: outer.width, height: outer.height);
    }

    // 0.1~0.4 上层: 去色 -> 调亮色阶 -> 反相
    _desaturate(outer);
    _applyLevelTable(outer, _colorLevelTable(120, 255));
    _invert(outer);
    // 0.5~0.6 下层: 去色 -> 调暗色阶
    _desaturate(inter);
    _applyLevelTable(inter, _colorLevelTable(0, 135));

    // 0.7 线性减淡(上层,下层)
    _linearDodge(outer, inter);
    // 0.8 红色通道: 记录此刻上层红色分量作为最终蒙版 alpha
    final width = outer.width;
    final maskAlpha = Uint8List(width * outer.height);
    for (final p in outer) {
      maskAlpha[p.y * width + p.x] = p.r.toInt();
    }
    // 0.9 划分(上层,下层)
    _divide(outer, inter);
    // 1.0 蒙版: 用红色通道 alpha 替换上层透明度
    for (final p in outer) {
      p.a = maskAlpha[p.y * width + p.x];
    }

    return Uint8List.fromList(img.encodePng(outer));
  }

  /// 去色: gray = (r+g+b)/3，保留 alpha。
  static void _desaturate(img.Image target) {
    for (final p in target) {
      final gray = (p.r.toInt() + p.g.toInt() + p.b.toInt()) ~/ 3;
      p..r = gray..g = gray..b = gray;
    }
  }

  /// 反相: 255 - c，保留 alpha。
  static void _invert(img.Image target) {
    for (final p in target) {
      p
        ..r = 255 - p.r.toInt()
        ..g = 255 - p.g.toInt()
        ..b = 255 - p.b.toInt();
    }
  }

  /// 色阶映射(调亮/调暗共用，安卓 changeColorLevel)。
  static void _applyLevelTable(img.Image target, List<int> table) {
    for (final p in target) {
      p
        ..r = table[p.r.toInt()]
        ..g = table[p.g.toInt()]
        ..b = table[p.b.toInt()];
    }
  }

  /// 线性减淡(Photoshop 图层特效): c = min(255, src + dst)，alpha 强制 255。
  static void _linearDodge(img.Image src, img.Image target) {
    for (final p in src) {
      final dst = target.getPixel(p.x, p.y);
      final r = p.r.toInt() + dst.r.toInt();
      final g = p.g.toInt() + dst.g.toInt();
      final b = p.b.toInt() + dst.b.toInt();
      p
        ..a = 255
        ..r = r > 255 ? 255 : r
        ..g = g > 255 ? 255 : g
        ..b = b > 255 ? 255 : b;
    }
  }

  /// 划分(Photoshop 图层特效): c = 255 / (src / dst)。
  /// Java float 除零产生 Infinity/NaN，(int) 强转后经 Color.argb 位截断，
  /// 最终通道值 = 截断结果 & 0xFF，此处逐分支复刻。
  static void _divide(img.Image src, img.Image target) {
    for (final p in src) {
      final dst = target.getPixel(p.x, p.y);
      p
        ..a = 255
        ..r = _divideChannel(p.r.toInt(), dst.r.toInt())
        ..g = _divideChannel(p.g.toInt(), dst.g.toInt())
        ..b = _divideChannel(p.b.toInt(), dst.b.toInt());
    }
  }

  static int _divideChannel(int v, int dst) {
    if (v == 0 && dst == 0) {
      return 0; // 0/0=NaN -> 255/NaN=NaN -> (int)NaN = 0
    }
    if (v == 0) {
      return 255; // 255/0=Infinity -> (int)Inf=2147483647 -> &0xFF = 255
    }
    if (dst == 0) {
      return 0; // v/0=Inf -> 255/Inf = 0
    }
    return (255 / (v / dst)).truncate() & 0xFF;
  }

  /// 对齐安卓 getColorLevelTable(outputMin, outputMax)。
  static List<int> _colorLevelTable(int outputMin, int outputMax) {
    const inputMin = 0, inputMiddle = 128, inputMax = 255;
    if (outputMin < 0) outputMin = 0;
    if (outputMin > 255) outputMin = 255;
    if (outputMax < 0) outputMax = 0;
    if (outputMax > 255) outputMax = 255;
    final gamma = math.log(0.5) /
        math.log((inputMiddle - inputMin) / (inputMax - inputMin));
    final data = List<int>.filled(256, 0);
    for (var index = 0; index <= 255; index++) {
      var temp = (index - inputMin).toDouble();
      if (temp < 0) {
        temp = outputMin.toDouble();
      } else if (temp + inputMin > inputMax) {
        temp = outputMax.toDouble();
      } else {
        temp = outputMin.toDouble() +
            (outputMax - outputMin) *
                math.pow(temp / (inputMax - inputMin), gamma).toDouble();
      }
      if (temp > 255) temp = 255;
      if (temp < 0) temp = 0;
      data[index] = temp.toInt();
    }
    return data;
  }
}

class _HideArgs {
  const _HideArgs(this.outer, this.inter);

  final Uint8List outer;
  final Uint8List inter;
}
