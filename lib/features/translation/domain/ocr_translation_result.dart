/// OCR 图片翻译结果
///
/// 对应原 Android `OcrTranslationResult`，保真字段。
class OcrTranslationResult {
  const OcrTranslationResult({
    required this.originalText,
    required this.translatedText,
  });

  /// 原文（多个 region 的 context 用 `\n` 连接）
  final String originalText;

  /// 译文（多个 region 的 tranContent 用 `\n` 连接）
  final String translatedText;
}
