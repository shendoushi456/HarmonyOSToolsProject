import 'package:harmonyos_flutter_empty/features/translation/domain/translate_data.dart';

/// 翻译 UI 状态
///
/// 对应原 Android `TranslationUiState`。
/// 保真字段与默认值。
class TranslationUiState {
  const TranslationUiState({
    this.isLoading = false,
    this.errorMessage,
    this.translateHistory = const [],
    this.selectedTranslateData,
    this.fromLanguage = '中文',
    this.toLanguage = '英文',
  });

  /// 是否正在加载
  final bool isLoading;

  /// 错误消息
  final String? errorMessage;

  /// 翻译历史列表
  final List<TranslateData> translateHistory;

  /// 当前选中的翻译结果（用于详情页）
  final TranslateData? selectedTranslateData;

  /// 源语言（中文名）
  final String fromLanguage;

  /// 目标语言（中文名）
  final String toLanguage;

  TranslationUiState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<TranslateData>? translateHistory,
    TranslateData? selectedTranslateData,
    String? fromLanguage,
    String? toLanguage,
  }) {
    return TranslationUiState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      translateHistory: translateHistory ?? this.translateHistory,
      selectedTranslateData: selectedTranslateData ?? this.selectedTranslateData,
      fromLanguage: fromLanguage ?? this.fromLanguage,
      toLanguage: toLanguage ?? this.toLanguage,
    );
  }
}
