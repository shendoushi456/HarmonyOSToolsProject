/// 设置页 URL 常量
///
/// 对应 Android: SettingUrlConstants.java + config.gradle
/// 原值来自 BuildConfig.PRIVATE_URL / USER_URL，最终取自 config.gradle。
class SettingUrlConstants {
  /// 隐私协议 URL
  static const String policyUrl = 'https://api.jyhytech.top/agreement/bjyycx/privacy';

  /// 用户协议 URL
  static const String userUrl = 'https://api.jyhytech.top/agreement/bjyycx/user';
}
