import 'dart:io';

import 'package:flutter/services.dart';

/// 导出到鸿蒙系统相册；平台未实现时明确返回错误，不静默伪装为已保存。
class DocumentExportService {
  static const _channel = MethodChannel('toolbox.scan_documents/gallery');

  Future<void> exportToGallery(File file, {required String name}) async {
    await _channel.invokeMethod<void>('saveImage', <String, Object>{
      'sourcePath': file.path,
      'name': name,
    });
  }
}
