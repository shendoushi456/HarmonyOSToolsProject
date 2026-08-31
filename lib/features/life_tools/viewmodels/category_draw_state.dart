// CategoryDrawState - 分类涂鸦填色页状态
// 对齐 Android MainActivityTwo.java 的数据状态
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart';

/// 撤销点记录 - 对齐 MainActivityTwo.drawnPoints
/// 记录每次填色的坐标和原色，用于撤销时恢复
@immutable
class DrawnPoint {
  const DrawnPoint({required this.x, required this.y, required this.oldColor});
  final int x;
  final int y;
  final Color oldColor;
}

@immutable
class CategoryDrawState {
  /// 原始线稿 bytes（对齐 mBitmap 初始）
  final Uint8List? initialBytes;

  /// 当前画面 bytes（对齐 mBitmap 变化后）
  final Uint8List? currentBytes;

  /// 图片宽度（对齐 w）
  final int imageWidth;

  /// 图片高度（对齐 h）
  final int imageHeight;

  /// 已绘制点列表（对齐 drawnPoints + counter）
  final List<DrawnPoint> drawnPoints;

  /// 当前选中色（对齐 select_color，默认 deep_orange #FF9800）
  final Color currentColor;

  /// 背景音乐开关（对齐 mPlayer 循环播放）
  final bool bgMusicOn;

  /// 是否正在填色（对齐 TheTask 执行中）
  final bool isFilling;

  /// 当前分类 code（对齐 MainActivityTwo.code）
  final int code;

  /// 当前 position（对齐 MainActivityTwo.position）
  final int position;

  const CategoryDrawState({
    this.initialBytes,
    this.currentBytes,
    this.imageWidth = 1,
    this.imageHeight = 1,
    this.drawnPoints = const [],
    this.currentColor = const Color(0xFFFF9800), // deep_orange 默认
    this.bgMusicOn = true,
    this.isFilling = false,
    this.code = 0,
    this.position = 0,
  });

  CategoryDrawState copyWith({
    Uint8List? initialBytes,
    Uint8List? currentBytes,
    int? imageWidth,
    int? imageHeight,
    List<DrawnPoint>? drawnPoints,
    Color? currentColor,
    bool? bgMusicOn,
    bool? isFilling,
    int? code,
    int? position,
  }) {
    return CategoryDrawState(
      initialBytes: initialBytes ?? this.initialBytes,
      currentBytes: currentBytes ?? this.currentBytes,
      imageWidth: imageWidth ?? this.imageWidth,
      imageHeight: imageHeight ?? this.imageHeight,
      drawnPoints: drawnPoints ?? this.drawnPoints,
      currentColor: currentColor ?? this.currentColor,
      bgMusicOn: bgMusicOn ?? this.bgMusicOn,
      isFilling: isFilling ?? this.isFilling,
      code: code ?? this.code,
      position: position ?? this.position,
    );
  }
}
