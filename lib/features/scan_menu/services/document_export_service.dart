import 'dart:io';

import 'package:flutter/services.dart';

/// 导出到鸿蒙系统相册；平台未实现时明确返回错误，不静默伪装为已保存。
class DocumentExportService {
  static const _channel = MethodChannel('toolbox.scan_documents/gallery');

  Future<void> exportToGallery(File file, {required String name}) async {
    final bytes = await file.readAsBytes();
    await exportBytesToGallery(bytes, name: name);
  }

  Future<void> exportBytesToGallery(
    Uint8List bytes, {
    required String name,
  }) async {
    if (bytes.isEmpty) {
      throw const GalleryExportException('GALLERY_EXPORT_ERROR', '没有可保存的图片数据');
    }
    try {
      await _channel.invokeMethod<void>('saveImageBytes', <String, Object>{
        'bytes': bytes,
        'name': name,
      });
    } on PlatformException catch (error) {
      throw GalleryExportException(
        error.code,
        error.message ?? '保存到系统相册失败',
      );
    } on MissingPluginException {
      throw const GalleryExportException(
        'GALLERY_PLUGIN_UNAVAILABLE',
        '图片保存组件未加载，请重新安装应用后重试',
      );
    }
  }
}

class GalleryExportException implements Exception {
  const GalleryExportException(this.code, this.message);

  final String code;
  final String message;
}
