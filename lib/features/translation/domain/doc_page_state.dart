/// 文档翻译页面状态
///
/// 对应原 Android `DocPageState` 枚举。
enum DocPageState {
  /// 上传页面
  upload,

  /// 预览页面
  preview,

  /// 翻译中（Loading 覆盖层）
  translating,
}
