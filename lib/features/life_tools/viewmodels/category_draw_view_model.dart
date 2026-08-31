// CategoryDrawViewModel - 分类涂鸦填色页 ViewModel
// 对齐 Android MainActivityTwo.java 的业务逻辑
// 内建 FloodFill（scanline flood fill）+ 撤销（到空重启）+ 保存
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

import 'category_draw_state.dart';

class CategoryDrawViewModel extends Notifier<CategoryDrawState> {
  @override
  CategoryDrawState build() => const CategoryDrawState();

  /// 初始化线稿 - 对齐 MainActivityTwo:482-484
  /// 反射 getIdentifier("gp"+code+"_"+position, "drawable", pkg)
  Future<void> initImage(int code, int position) async {
    final assetPath = _resolveAssetPath(code, position);
    try {
      final bytes = (await rootBundle.load(assetPath)).buffer.asUint8List();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) {
        throw StateError('线稿解码失败: $assetPath');
      }
      final normalized = Uint8List.fromList(img.encodePng(decoded));
      state = state.copyWith(
        initialBytes: normalized,
        currentBytes: Uint8List.fromList(normalized),
        imageWidth: decoded.width,
        imageHeight: decoded.height,
        code: code,
        position: position,
      );
    } catch (e) {
      if (kDebugMode) {
        print('CategoryDrawViewModel.initImage 错误: $e');
      }
    }
  }

  /// 在指定坐标填色 - 对齐 MainActivityTwo:586-673 + TheTask
  /// 使用 scanline FloodFill 算法（对齐 :733-775）
  Future<void> fillAt(int x, int y) async {
    final initialBytes = state.initialBytes;
    final currentBytes = state.currentBytes;
    if (initialBytes == null || currentBytes == null || state.isFilling) {
      return;
    }
    if (x < 0 || y < 0 || x >= state.imageWidth || y >= state.imageHeight) {
      return;
    }

    state = state.copyWith(isFilling: true);
    try {
      final oldColor = _pixelColor(initialBytes, x, y);
      final result = await compute(
        _floodFill,
        _FillRequest(
          currentBytes,
          initialBytes,
          x,
          y,
          (state.currentColor.r * 255).round(),
          (state.currentColor.g * 255).round(),
          (state.currentColor.b * 255).round(),
        ),
      );
      if (result != null) {
        final newDrawnPoints = [
          ...state.drawnPoints,
          DrawnPoint(x: x, y: y, oldColor: oldColor)
        ];
        state = state.copyWith(
          currentBytes: result,
          drawnPoints: newDrawnPoints,
        );
      }
    } finally {
      state = state.copyWith(isFilling: false);
    }
  }

  /// 撤销 - 对齐 MainActivityTwo.undoMethod:524-566
  /// 用 drawnPoints 取上一个点，填回 TRANSPARENT（即恢复原始）
  /// 保真 Bug 4：撤销到空时重启 Activity（返回 true 让 Page pushReplacement）
  /// 返回 true 表示需要重启，false 表示正常撤销
  Future<bool> undo() async {
    if (state.drawnPoints.isEmpty || state.isFilling) return false;
    final lastPoint = state.drawnPoints.last;
    final initialBytes = state.initialBytes;
    final currentBytes = state.currentBytes;
    if (initialBytes == null || currentBytes == null) return false;

    state = state.copyWith(isFilling: true);
    try {
      // 对齐 MainActivityTwo: 用 TRANSPARENT 替换回原色（恢复原始线稿）
      final result = await compute(
        _floodFill,
        _FillRequest(
          currentBytes,
          initialBytes,
          lastPoint.x,
          lastPoint.y,
          (lastPoint.oldColor.r * 255).round(),
          (lastPoint.oldColor.g * 255).round(),
          (lastPoint.oldColor.b * 255).round(),
        ),
      );
      if (result != null) {
        state = state.copyWith(
          currentBytes: result,
          drawnPoints: [...state.drawnPoints]..removeLast(),
        );
      }
    } finally {
      state = state.copyWith(isFilling: false);
    }

    // 保真 Bug 4：撤销到空时重启 Activity
    // 对齐 MainActivityTwo:559-563 counter<=0 时 recreate()
    return state.drawnPoints.isEmpty;
  }

  /// 设置颜色 - 对齐 MainActivityTwo.onClick 17 色按钮
  void setColor(Color color) {
    state = state.copyWith(currentColor: color);
  }

  /// 切换背景音乐 - 对齐 MainActivityTwo two_detail_action_mute
  void toggleBgMusic() {
    state = state.copyWith(bgMusicOn: !state.bgMusicOn);
  }

  /// 取像素颜色 - 用于记录撤销原色
  ui.Color _pixelColor(Uint8List bytes, int x, int y) {
    final image = img.decodeImage(bytes);
    if (image == null) return const Color(0x00000000);
    final pixel = image.getPixel(x, y);
    return Color.fromARGB(
      pixel.a.toInt(),
      pixel.r.toInt(),
      pixel.g.toInt(),
      pixel.b.toInt(),
    );
  }

  /// 根据 code + position 解析素材路径
  /// 对齐 MainActivityTwo:482 反射 getIdentifier("gp"+code+"_"+position)
  String _resolveAssetPath(int code, int position) {
    final category = _categoryDir(code);
    final ext = _extension(code, position);
    return 'assets/images/coloring_book/$category/gp${code}_$position.$ext';
  }

  /// code → 分类目录名
  String _categoryDir(int code) {
    switch (code) {
      case 1:
        return 'flowers';
      case 2:
        return 'cartoons';
      case 3:
        return 'animals';
      case 4:
        return 'foods';
      case 5:
        return 'transport';
      case 6:
      default:
        return 'nature';
    }
  }

  /// code + position → 扩展名（webp/png 混合，对齐 Android drawable 资源）
  String _extension(int code, int position) {
    // 硬编码扩展名映射（对齐实际复制的文件）
    const extMap = {
      1: {1: 'webp', 2: 'png', 3: 'webp', 4: 'png', 5: 'webp', 6: 'png'},
      2: {1: 'webp', 2: 'png', 3: 'png', 4: 'png', 5: 'png', 6: 'png'},
      3: {1: 'png', 2: 'webp', 3: 'webp', 4: 'png', 5: 'png', 6: 'png'},
      4: {1: 'webp', 2: 'webp', 3: 'webp', 4: 'webp', 5: 'webp', 6: 'png'},
      5: {1: 'webp', 2: 'webp', 3: 'png', 4: 'png', 5: 'webp', 6: 'png'},
      6: {1: 'png', 2: 'png', 3: 'png', 4: 'png', 5: 'webp', 6: 'webp'},
    };
    return extMap[code]?[position] ?? 'png';
  }
}

/// FloodFill 请求 - 对齐 MainActivityTwo._FillRequest + TheTask
class _FillRequest {
  const _FillRequest(
      this.bytes, this.originalBytes, this.x, this.y, this.r, this.g, this.b);
  final Uint8List bytes;
  final Uint8List originalBytes;
  final int x, y, r, g, b;
}

/// scanline FloodFill - 对齐 MainActivityTwo.floodFill:733-775
/// 在 isolate 中执行避免阻塞 UI
/// 支持透明背景线稿（分类涂鸦 gp 图）和不透明线稿（离线涂鸦 image 图）
Uint8List? _floodFill(_FillRequest request) {
  final image = img.decodeImage(request.bytes);
  final original = img.decodeImage(request.originalBytes);
  if (image == null || original == null) return null;

  final x0 = request.x, y0 = request.y;
  final originalTarget = original.getPixel(x0, y0);
  // 边界判断：不透明（a>128）且深色（r/g/b<100）才是黑线边界
  // 透明像素（a<128）不是边界，是可填色区域
  final isBoundary = originalTarget.a.toInt() > 128 &&
      originalTarget.r.toInt() < 100 &&
      originalTarget.g.toInt() < 100 &&
      originalTarget.b.toInt() < 100;
  if (isBoundary) return null;

  final tr = originalTarget.r.toInt(),
      tg = originalTarget.g.toInt(),
      tb = originalTarget.b.toInt();
  final targetIsTransparent = originalTarget.a.toInt() < 128;
  // 已是目标色则跳过（避免重复填色）
  if (!targetIsTransparent &&
      (tr - request.r).abs() < 4 &&
      (tg - request.g).abs() < 4 &&
      (tb - request.b).abs() < 4) {
    return request.bytes;
  }

  const tolerance = 24;
  bool matches(int x, int y) {
    final source = original.getPixel(x, y);
    // 边界：不透明且深色（黑线）
    final isBd = source.a.toInt() > 128 &&
        source.r.toInt() < 100 &&
        source.g.toInt() < 100 &&
        source.b.toInt() < 100;
    if (isBd) return false;
    // 透明背景线稿：只匹配透明像素（a<128）
    if (targetIsTransparent) {
      return source.a.toInt() < 128;
    }
    // 不透明线稿：按颜色匹配
    return (source.r.toInt() - tr).abs() <= tolerance &&
        (source.g.toInt() - tg).abs() <= tolerance &&
        (source.b.toInt() - tb).abs() <= tolerance;
  }

  // scanline flood fill - 对齐 MainActivityTwo:733-775 Queue<Point>
  final visited = Uint8List(image.width * image.height);
  final queue = <int>[y0 * image.width + x0];
  var head = 0;
  while (head < queue.length) {
    final index = queue[head++];
    if (visited[index] != 0) continue;
    visited[index] = 1;
    final x = index % image.width, y = index ~/ image.width;
    if (!matches(x, y)) continue;
    // 填色时 alpha 设为 255，让透明区域填色后可见
    image.setPixelRgba(x, y, request.r, request.g, request.b, 255);
    if (x > 0) queue.add(index - 1);
    if (x + 1 < image.width) queue.add(index + 1);
    if (y > 0) queue.add(index - image.width);
    if (y + 1 < image.height) queue.add(index + image.width);
  }
  return Uint8List.fromList(img.encodePng(image));
}

final categoryDrawViewModelProvider =
    NotifierProvider<CategoryDrawViewModel, CategoryDrawState>(
        CategoryDrawViewModel.new);
