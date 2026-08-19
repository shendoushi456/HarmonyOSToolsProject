/// 应用配置
///
/// 有道翻译 API 密钥配置。
/// 用户需将下方占位符替换为实际的有道应用 ID 和密钥。
/// 获取方式：https://ai.youdao.com → 应用管理
class AppConfig {
  AppConfig._();

  /// 有道应用 ID（appKey）
  ///
  /// TODO(用户): 替换为实际的有道应用 ID
  static const String youdaoAppId = '1727c4fd13d6a729';

  /// 有道应用密钥（appSecret）
  ///
  /// TODO(用户): 替换为实际的有道应用密钥
  static const String youdaoAppSecret = 'Ymg5lt2YMMim7K06HINMSl7EkSrfJSJk';

  /// 有道作文批改应用 ID（作文批改使用独立服务实例）。
  static const String youdaoCorrectionAppId = '2c481e93cff5c35f';

  /// 有道作文批改应用密钥。
  static const String youdaoCorrectionAppSecret =
      '2d407e2de4e831e465debf21ac99e06444fcb61db020618389eff02fd2f8bf7d';

  /// 有道文档翻译应用 ID（文档翻译使用独立密钥）
  ///
  /// TODO(用户): 替换为实际的有道文档翻译应用 ID
  static const String youdaoDocAppId = '5898ed966ea1635f';

  /// 有道文档翻译应用密钥
  ///
  /// TODO(用户): 替换为实际的有道文档翻译应用密钥
  static const String youdaoDocAppSecret = 'EjuGEK9KLJerc1plkBhrgnkXx7XG6wVG';

  /// 隐私政策 URL
  static const String privacyUrl =
      'https://api.bjbaby.top/agreement/bbkxfy/privacy';

  /// 用户协议 URL
  static const String userAgreementUrl =
      'https://api.bjbaby.top/agreement/bbkxfy/user';
}
