// 指南针状态 - 对齐 Android CompassActivity + ChaosCompassView
// 仅暴露方位角和方位文字(3D 倾斜由 Page 层 AnimationController 处理)
import 'package:flutter/foundation.dart';

@immutable
class CompassState {
  /// 方位角 0-360(对齐 ChaosCompassView.java:883 imageRotationDegrees)
  final double azimuth;

  /// 方位文字(北/东北/东/东南/南,对齐 ChaosCompassView.java:513-529)
  final String directionText;

  /// 是否正在加载传感器
  final bool isLoading;

  /// 错误信息
  final String? error;

  const CompassState({
    this.azimuth = 0,
    this.directionText = '北',
    this.isLoading = false,
    this.error,
  });

  CompassState copyWith({
    double? azimuth,
    String? directionText,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return CompassState(
      azimuth: azimuth ?? this.azimuth,
      directionText: directionText ?? this.directionText,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
