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
    this.fromLanguage = '自动',
    this.toLanguage = '中文',
    this.ttsVoiceStrict = false,
    this.playingUrl,
    this.isPlaying = false,
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

  /// TTS 严格模式
  final bool ttsVoiceStrict;

  /// 当前正在播放的 URL
  final String? playingUrl;

  /// 播放状态
  final bool isPlaying;

  TranslationUiState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<TranslateData>? translateHistory,
    TranslateData? selectedTranslateData,
    String? fromLanguage,
    String? toLanguage,
    bool? ttsVoiceStrict,
    String? playingUrl,
    bool? isPlaying,
  }) {
    return TranslationUiState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      translateHistory: translateHistory ?? this.translateHistory,
      selectedTranslateData: selectedTranslateData ?? this.selectedTranslateData,
      fromLanguage: fromLanguage ?? this.fromLanguage,
      toLanguage: toLanguage ?? this.toLanguage,
      ttsVoiceStrict: ttsVoiceStrict ?? this.ttsVoiceStrict,
      playingUrl: playingUrl,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }
}
