import 'package:flutter/material.dart';

import 'magnifier_camera_page.dart';

/// 工具页原“清晰拍照”卡片的兼容入口。
/// Android 原版对应的是放大镜相机，而不是拍照后查看图片的页面。
class ClearCapturePage {
  const ClearCapturePage._();

  static Future<void> push(BuildContext context) {
    return Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => const MagnifierCameraPage()),
    );
  }
}
