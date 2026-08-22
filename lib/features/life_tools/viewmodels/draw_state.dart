// 画板状态 - 对齐 Android DrawActivity + PaletteView
import 'package:flutter/foundation.dart';
import 'dart:ui';

/// 绘制模式 - 对齐 PaletteView.java:214-241
enum DrawMode { draw, eraser }

/// 单条绘制路径信息(对齐 PaletteView.java:174-192 PathDrawingInfo)
@immutable
class PathDrawingInfo {
  const PathDrawingInfo(this.path, this.paint);
  final Path path;
  final PaintData paint;
}

/// Paint 的可序列化表示(Paint 本身可变, 用 data 类保存快照)
@immutable
class PaintData {
  const PaintData({
    required this.color,
    required this.strokeWidth,
    required this.blendMode,
  });
  final Color color;
  final double strokeWidth;
  final BlendMode blendMode;
}

@immutable
class DrawState {
  /// 已绘制路径(对齐 mDrawingList, MAX_CACHE_STEP=20)
  final List<PathDrawingInfo> paths;

  /// 撤销栈(对齐 mRemovedList)
  final List<PathDrawingInfo> redoStack;

  /// 当前模式(对齐 Mode DRAW/ERASER)
  final DrawMode mode;

  /// 画笔颜色(对齐 mPenColor, 默认 #FF000000)
  final Color penColor;

  /// 画笔大小(对齐 mDrawSize, 默认 3dp)
  final double penSize;

  /// 橡皮擦大小(对齐 mEraserSize, 默认 30dp)
  final double eraserSize;

  const DrawState({
    this.paths = const [],
    this.redoStack = const [],
    this.mode = DrawMode.draw,
    this.penColor = const Color(0xFF000000),
    this.penSize = 3.0,
    this.eraserSize = 30.0,
  });

  DrawState copyWith({
    List<PathDrawingInfo>? paths,
    List<PathDrawingInfo>? redoStack,
    DrawMode? mode,
    Color? penColor,
    double? penSize,
    double? eraserSize,
  }) {
    return DrawState(
      paths: paths ?? this.paths,
      redoStack: redoStack ?? this.redoStack,
      mode: mode ?? this.mode,
      penColor: penColor ?? this.penColor,
      penSize: penSize ?? this.penSize,
      eraserSize: eraserSize ?? this.eraserSize,
    );
  }
}
