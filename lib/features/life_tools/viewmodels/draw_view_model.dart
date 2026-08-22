// 画板 ViewModel - 对齐 Android PaletteView.java
// undo/redo/clear/setMode, MAX_CACHE_STEP=20(对齐 PaletteView.java:37)
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'draw_state.dart';

class DrawViewModel extends Notifier<DrawState> {
  /// 最大缓存步数 - 对齐 PaletteView.java:37 MAX_CACHE_STEP
  static const int maxCacheStep = 20;

  @override
  DrawState build() => const DrawState();

  /// 添加路径 - 对齐 PaletteView.java:570-597 saveDrawingPath
  void addPath(Path path) {
    // 构造当前 paint 快照(对齐 PathDrawingInfo 拷贝 Paint)
    final paint = PaintData(
      color: state.mode == DrawMode.draw ? state.penColor : const Color(0x00000000),
      strokeWidth: state.mode == DrawMode.draw ? state.penSize : state.eraserSize,
      blendMode: state.mode == DrawMode.draw ? BlendMode.src : BlendMode.clear,
    );
    final info = PathDrawingInfo(Path.from(path), paint);
    final paths = [...state.paths, info];
    // 超过上限移除最早(对齐 PaletteView.java:582-585)
    if (paths.length > maxCacheStep) paths.removeAt(0);
    state = state.copyWith(paths: paths, redoStack: const []);
  }

  /// 撤销 - 对齐 PaletteView.java:476-513 undo
  void undo() {
    if (state.paths.isEmpty) return;
    final paths = [...state.paths];
    final last = paths.removeLast();
    state = state.copyWith(paths: paths, redoStack: [...state.redoStack, last]);
  }

  /// 重做 - 对齐 PaletteView.java:447-474 redo
  void redo() {
    if (state.redoStack.isEmpty) return;
    final redo = [...state.redoStack];
    final last = redo.removeLast();
    state = state.copyWith(paths: [...state.paths, last], redoStack: redo);
  }

  /// 清除 - 对齐 PaletteView.java:515-551 clear
  void clear() {
    state = state.copyWith(paths: const [], redoStack: const []);
  }

  /// 设置模式 - 对齐 PaletteView.java:214-241
  void setMode(DrawMode mode) => state = state.copyWith(mode: mode);

  /// 设置颜色
  void setPenColor(Color color) => state = state.copyWith(penColor: color);

  /// 设置画笔大小
  void setPenSize(double size) => state = state.copyWith(penSize: size);
}

/// 画板 ViewModel Provider
final drawViewModelProvider =
    NotifierProvider<DrawViewModel, DrawState>(DrawViewModel.new);
