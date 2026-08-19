import 'package:harmonyos_flutter_empty/features/translation/domain/ocr_translation_result.dart';

/// OCR 图片翻译 UI 状态
///
/// 对应原 Android `OcrTranslationUiState`，保真字段与默认值。
class OcrTranslationUiState {
  const OcrTranslationUiState({
    this.fromLanguage = '自动',
    this.toLanguage = '中文',
    this.isLoading = false,
    this.errorMessage,
    this.translationResult,
  });

  /// 源语言（中文名）
  final String fromLanguage;

  /// 目标语言（中文名）
  final String toLanguage;

  /// 是否加载中
  final bool isLoading;

  /// 错误消息
  final String? errorMessage;

  /// 翻译结果
  final OcrTranslationResult? translationResult;

  OcrTranslationUiState copyWith({
    String? fromLanguage,
    String? toLanguage,
    bool? isLoading,
    String? errorMessage,
    OcrTranslationResult? translationResult,
  }) {
    return OcrTranslationUiState(
      fromLanguage: fromLanguage ?? this.fromLanguage,
      toLanguage: toLanguage ?? this.toLanguage,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      translationResult: translationResult ?? this.translationResult,
    );
  }
}
