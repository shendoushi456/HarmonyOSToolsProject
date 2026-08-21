// 应用信息工具 - 对齐 Android getApplicationLabel + getVersion
// 简化:硬编码应用名和版本号(避免引入 package_info_plus 的 ohos 适配风险)
// 后续若需动态获取可替换为 package_info_plus
class AppInfoUtil {
  AppInfoUtil._();

  /// 应用名(对齐 Android getApplicationLabel)
  static const String appName = '瞬息天气通';

  /// 版本号(对齐 Android getVersion → "1.0.1")
  static const String version = '1.0.1';
}

/// 协议 URL 常量 - 对齐 Android ProtocolDialog.java 中的 URL
class SettingUrls {
  SettingUrls._();

  /// 用户协议 URL（对齐 Android ProtocolDialog protocol_url_2）
  static const String user = 'https://api.bjbaby.top/agreement/bbsflwf/user';

  /// 隐私协议 URL（对齐 Android ProtocolDialog protocol_url_1）
  static const String policy = 'https://api.bjbaby.top/agreement/bbsflwf/privacy';
}
