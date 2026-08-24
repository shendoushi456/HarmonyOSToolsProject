import 'dart:async';

import 'package:flutter/services.dart';

/// 鸿蒙方向传感器通道。
///
/// 保持与定位通道隔离，页面销毁时停止监听，避免 IndexedStack 中的后台轮询。
class HeadingPlatformService {
  const HeadingPlatformService();

  static const MethodChannel _channel =
      MethodChannel('com.p.a_b/toolbox_heading');

  Stream<double> get headingStream async* {
    try {
      while (true) {
        final heading = await _channel.invokeMethod<num>('getHeading');
        yield _normalize(heading?.toDouble() ?? 0);
        await Future<void>.delayed(const Duration(milliseconds: 180));
      }
    } finally {
      await _channel.invokeMethod<void>('stopHeading');
    }
  }

  double _normalize(double value) => (value % 360 + 360) % 360;
}
