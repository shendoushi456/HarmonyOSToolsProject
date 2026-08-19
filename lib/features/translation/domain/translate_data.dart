/// 翻译数据实体
///
/// 对应原 Android `TranslateData`，包装翻译结果。
/// 由于有道 HTTP API v3.0.0（2024.04.22）已下线词典数据，
/// [means]、[webMeans]、[getWordForms] 返回空字符串（保真度声明见迁移方案）。
class TranslateData {
  TranslateData({
    required this.createTime,
    required this.query,
    required this.translation,
    this.speakUrl,
    this.tSpeakUrl,
  });

  /// 创建时间（毫秒）
  final int createTime;

  /// 原文查询内容
  final String query;

  /// 译文（多条用 `\n` 连接）
  final String translation;

  /// 原文发音 URL
  final String? speakUrl;

  /// 译文发音 URL
  final String? tSpeakUrl;

  /// 获取查询内容（保真原 `getQuery()`）
  String getQuery() => query;

  /// 获取翻译结果（保真原 `translates()`）
  String translates() => translation;

  /// 获取查词结果
  ///
  /// API v3.0.0 已下线词典数据，返回空字符串。
  String means() => '';

  /// 获取网络释义
  ///
  /// API 不返回 webExplains，返回空字符串。
  String webMeans() => '';

  /// 获取词形变化
  ///
  /// API 不返回 wfs，返回空字符串。
  String getWordForms() => '';
}
