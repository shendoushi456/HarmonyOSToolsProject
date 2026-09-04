/// 有道翻译 API 响应模型
///
/// 对应 `https://openapi.youdao.com/api` 返回的 JSON 结构。
/// 手写 fromJson，不依赖 json_serializable。
class YoudaoTranslationResponse {
  YoudaoTranslationResponse({
    required this.errorCode,
    this.query,
    this.translation = const [],
    this.l,
  });

  factory YoudaoTranslationResponse.fromJson(Map<String, dynamic> json) {
    return YoudaoTranslationResponse(
      errorCode: json['errorCode'] as String? ?? '0',
      query: json['query'] as String?,
      translation: (json['translation'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      l: json['l'] as String?,
    );
  }

  /// 错误码，"0" 表示成功
  final String errorCode;

  /// 源语言查询内容
  final String? query;

  /// 翻译结果列表
  final List<String> translation;

  /// 源语言和目标语言（如 "EN2zh-CHS"）
  final String? l;

  /// 是否成功
  bool get isSuccess => errorCode == '0';
}
