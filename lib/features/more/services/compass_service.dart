import 'dart:async';

import 'package:flutter/services.dart';

/// 使用鸿蒙方向传感器的桥接服务；无传感器或模拟器时由页面显示不可用状态。
class CompassService {
  const CompassService();
  static const _headingChannel = MethodChannel('com.p.a_b/toolbox_compass');

  Stream<double> get headingStream async* {
    try {
      while (true) {
        final value = await _headingChannel.invokeMethod<num>('getHeading');
        yield value?.toDouble() ?? 0;
        await Future<void>.delayed(const Duration(milliseconds: 180));
      }
    } finally {
      await _headingChannel.invokeMethod<void>('stopHeading');
    }
  }
}
