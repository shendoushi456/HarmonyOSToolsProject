/// 文档翻译状态码
///
/// 对应原 Android `DocTransStatus`，保真状态码常量与判断逻辑。
class DocTransStatus {
  DocTransStatus._();

  // 处理中状态
  static const int uploading = 1; // 上传中
  static const int converting = 2; // 转换中
  static const int translating = 3; // 翻译中
  static const int completed = 4; // 已完成
  static const int generating = 5; // 生成中

  // 错误状态
  static const int errorUploadFailed = -1; // 上传失败
  static const int errorConvertFailed = -2; // 转换失败
  static const int errorTranslateFailed = -3; // 翻译失败
  static const int errorCancelled = -4; // 已取消
  static const int errorGenerateFailed = -5; // 生成失败
  static const int errorTranslateFailed2 = -10; // 翻译失败
  static const int errorFileDeleted = -11; // 文件被删除

  /// 是否处理中（需要继续轮询）
  static bool isProcessing(int status) {
    return (status >= 1 && status <= 3) || status == 5;
  }

  /// 是否完成
  static bool isCompleted(int status) {
    return status == completed;
  }

  /// 是否失败
  static bool isFailed(int status) {
    return status < 0;
  }
}
