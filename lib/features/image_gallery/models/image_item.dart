/// 图片库列表项模型 - 对应 Android ImageItem.kt。
///
/// name 取自文件名的可见部分(去掉时间戳前缀)，date 为最后修改时间。
class ImageItem {
  const ImageItem({
    required this.path,
    required this.name,
    required this.date,
  });

  final String path;
  final String name;
  final DateTime date;
}