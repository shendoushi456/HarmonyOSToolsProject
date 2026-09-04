import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/scanned_document.dart';

/// 管理“文档首页”中的扫描图片，不依赖 UI 或平台相册实现。
class ScannedDocumentRepository {
  static const _directoryName = 'scan_menu/documents';

  Future<Directory> _documentsDirectory() async {
    final root = await getApplicationDocumentsDirectory();
    final directory = Directory('${root.path}/$_directoryName');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  /// 扫描件存储目录(供 ImageGalleryService 共享路径约定)。
  Future<Directory> documentsDirectory() => _documentsDirectory();

  Future<List<ScannedDocument>> loadDocuments({
    required bool newestFirst,
  }) async {
    final directory = await _documentsDirectory();
    final files = await directory
        .list()
        .where((entry) => entry is File && _isImage(entry.path))
        .cast<File>()
        .toList();
    final documents = await Future.wait(files.map(_toDocument));
    documents.sort((left, right) => newestFirst
        ? right.modifiedAt.compareTo(left.modifiedAt)
        : left.modifiedAt.compareTo(right.modifiedAt));
    return documents;
  }

  Future<ScannedDocument> saveCapturedDocument(
    File source, {
    required String displayName,
  }) async {
    final directory = await _documentsDirectory();
    final extension = _extensionFor(source.path);
    final safeName = _safeName(displayName);
    final destination = File(
      '${directory.path}/${DateTime.now().microsecondsSinceEpoch}_$safeName$extension',
    );
    await source.copy(destination.path);
    return _toDocument(destination);
  }

  Future<void> delete(ScannedDocument document) async {
    final file = File(document.path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<ScannedDocument> _toDocument(File file) async {
    final stat = await file.stat();
    final filename = file.uri.pathSegments.last;
    final separator = filename.indexOf('_');
    final visibleName = separator < 0
        ? filename
        : filename
            .substring(separator + 1)
            .replaceFirst(RegExp(r'\.[^.]+$'), '');
    return ScannedDocument(
      path: file.path,
      name: visibleName,
      modifiedAt: stat.modified,
    );
  }

  bool _isImage(String path) {
    final lowerPath = path.toLowerCase();
    return lowerPath.endsWith('.jpg') ||
        lowerPath.endsWith('.jpeg') ||
        lowerPath.endsWith('.png');
  }

  String _extensionFor(String path) {
    final lowerPath = path.toLowerCase();
    if (lowerPath.endsWith('.png')) return '.png';
    if (lowerPath.endsWith('.jpeg')) return '.jpeg';
    return '.jpg';
  }

  String _safeName(String value) {
    final cleaned = value.trim().replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    return cleaned.isEmpty ? '文档扫描' : cleaned;
  }
}
