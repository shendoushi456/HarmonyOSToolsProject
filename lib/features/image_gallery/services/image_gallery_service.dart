import 'dart:io';

import '../../scan_menu/models/scanned_document.dart';
import '../../scan_menu/repositories/scanned_document_repository.dart';
import '../models/image_item.dart';

/// 图片库数据源。
///
/// Android 端从 `getExternalFilesDir(DIRECTORY_PICTURES)/MyImages` 目录列出图片
/// （`.jpg` 后缀）。该目录在 HarmonyOS 项目中并不存在真正的写入路径，因此
/// 这里对齐到鸿蒙项目既有的"扫描件库"(`scan_menu/documents/`，由
/// [ScannedDocumentRepository] 管理)；保留文件名/排序逻辑，让迁移 UI 真正有
/// 数据可显示。保存到本地与删除继续走既有的导出服务和扫描件库。
class ImageGalleryService {
  ImageGalleryService(this._repository);

  final ScannedDocumentRepository _repository;

  /// 默认目录名，对齐 Android 端 `getExternalFilesDir(Environment.DIRECTORY_PICTURES)`。
  /// 鸿蒙端实际不存在该路径，作为占位常量保留供诊断输出。
  static const String androidImagesDirName = 'MyImages';

  Future<List<ImageItem>> loadImages({
    required bool newestFirst,
  }) async {
    final directory = await _repository.documentsDirectory();
    if (!await directory.exists()) return const [];

    final files = await directory
        .list()
        .where((entry) => entry is File && _isImage(entry.path))
        .cast<File>()
        .toList();
    final items = await Future.wait(files.map(_toItem));
    items.sort((left, right) => newestFirst
        ? right.date.compareTo(left.date)
        : left.date.compareTo(right.date));
    return items;
  }

  Future<bool> delete(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
      return true;
    }
    return false;
  }

  Future<ImageItem> _toItem(File file) async {
    final stat = await file.stat();
    return ImageItem(
      path: file.path,
      name: _displayName(file),
      date: stat.modified,
    );
  }

  String _displayName(File file) {
    final filename = file.uri.pathSegments.last;
    final separator = filename.indexOf('_');
    final visible = separator < 0
        ? filename
        : filename
            .substring(separator + 1)
            .replaceFirst(RegExp(r'\.[^.]+$'), '');
    return visible.isEmpty ? filename : visible;
  }

  bool _isImage(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png');
  }
}

/// 把 [ScannedDocument] 桥接为 [ImageItem]，方便上层统一展示。
ImageItem scannedDocumentToImageItem(ScannedDocument doc) {
  return ImageItem(path: doc.path, name: doc.name, date: doc.modifiedAt);
}