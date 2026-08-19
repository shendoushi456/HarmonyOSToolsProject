/// 支持的文件类型
///
/// 对应原 Android `SupportedFileTypes`，保真支持的文件格式与大小限制。
class SupportedFileTypes {
  SupportedFileTypes._();

  /// 支持的文件扩展名
  static const List<String> types = [
    'doc',
    'docx',
    'pdf',
    'jpg',
    'png',
    'bmp',
    'ppt',
    'pptx',
    'xlsx',
  ];

  /// 有道限制的是 Base64 编码后的大小（40MB）。
  /// 原始文件按最大 3/4 换算，留出 Base64 补齐空间。
  static const int maxFileSize = 30 * 1024 * 1024;

  /// 根据文件名获取文件类型
  ///
  /// 返回小写扩展名，不支持则返回 null。
  static String? getFileType(String fileName) {
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex < 0 || dotIndex == fileName.length - 1) {
      return null;
    }
    final ext = fileName.substring(dotIndex + 1).toLowerCase();
    return types.contains(ext) ? ext : null;
  }

  /// 检查文件类型是否支持
  static bool isSupported(String fileName) {
    return getFileType(fileName) != null;
  }
}
