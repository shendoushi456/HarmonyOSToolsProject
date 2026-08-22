// 毛玻璃状态 - 对齐 Android ToolsPictureBlurActivity.java
import 'package:flutter/foundation.dart';
import 'dart:typed_data';

@immutable
class BlurState {
  /// 原始图片字节
  final Uint8List? originalBytes;

  /// 模糊后图片字节
  final Uint8List? blurredBytes;

  /// 模糊半径 1-25(对齐 seekbar1, 默认 12)
  final int radius;

  /// 是否正在处理
  final bool isProcessing;

  /// 错误信息
  final String? error;

  const BlurState({
    this.originalBytes,
    this.blurredBytes,
    this.radius = 12,
    this.isProcessing = false,
    this.error,
  });

  BlurState copyWith({
    Uint8List? originalBytes,
    Uint8List? blurredBytes,
    int? radius,
    bool? isProcessing,
    String? error,
    bool clearError = false,
  }) {
    return BlurState(
      originalBytes: originalBytes ?? this.originalBytes,
      blurredBytes: blurredBytes ?? this.blurredBytes,
      radius: radius ?? this.radius,
      isProcessing: isProcessing ?? this.isProcessing,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
