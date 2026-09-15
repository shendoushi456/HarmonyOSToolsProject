import 'dart:io';

/// 图片库条目 - 对齐 com.cln.setting.utils.file.ImageItem(path/name/date)
class ImageGalleryItem {
  const ImageGalleryItem({
    required this.path,
    required this.name,
    required this.modifiedAt,
  });

  factory ImageGalleryItem.fromFile(File file) {
    return ImageGalleryItem(
      path: file.path,
      name: file.uri.pathSegments.last,
      modifiedAt: file.lastModifiedSync(),
    );
  }

  final String path;
  final String name;
  final DateTime modifiedAt;
}
