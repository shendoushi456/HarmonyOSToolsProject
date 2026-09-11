import 'dart:io';

import 'package:flutter/services.dart';

/// 相册保存失败的明确原因，页面据此提供对应交互而不是误报权限问题。
class GalleryExportException implements Exception {
  const GalleryExportException(this.code, this.message);

  final String code;
  final String message;

  bool get isCanceled => code == 'GALLERY_SAVE_CANCELED';
}

/// 导出到鸿蒙系统相册；平台未实现时明确返回错误，不静默伪装为已保存。
class DocumentExportService {
  static const _channel = MethodChannel('toolbox.scan_documents/gallery');

  Future<void> exportToGallery(File file, {required String name}) async {
    final bytes = await file.readAsBytes();
    await exportBytesToGallery(bytes, name: name);
  }

  /// 将多张图片一次性写入鸿蒙照片库。
  ///
  /// 原生侧只弹一次 SaveButton 确认，授权后在同一回调内写入全部图片。
  /// PDF 转图片等多页结果使用，避免逐张弹出系统确认框。
  Future<void> exportBytesListToGallery(
    List<Uint8List> bytesList, {
    required String name,
  }) async {
    if (bytesList.isEmpty) {
      throw const GalleryExportException('GALLERY_EXPORT_ERROR', '没有可保存的图片数据');
    }
    try {
      await _channel.invokeMethod<void>('saveImageBytesList', <String, Object>{
        'bytesList': bytesList,
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

  /// 将内存中的图片直接写入鸿蒙照片库。
  ///
  /// 图像处理页的结果本来就在内存中；直接传给原生层可避免不同设备上
  /// Flutter 沙箱路径与 ArkTS 文件 API 之间不兼容而导致保存失败。
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
