import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:harmonyos_flutter_empty/shared/audio/audio_player_service.dart';
import 'package:harmonyos_flutter_empty/features/translation/data/translation_repository.dart';
import 'package:harmonyos_flutter_empty/features/translation/data/youdao_api_client.dart';
import 'package:harmonyos_flutter_empty/features/translation/domain/domain_type.dart';
import 'package:harmonyos_flutter_empty/features/translation/domain/language_list.dart';
import 'package:harmonyos_flutter_empty/features/translation/domain/translate_data.dart';
import 'package:harmonyos_flutter_empty/features/translation/presentation/states/lang_switch_ui_state.dart';
import 'package:harmonyos_flutter_empty/features/translation/presentation/states/translation_ui_state.dart';

/// 翻译仓库 Provider
final Provider<TranslationRepository> translationRepositoryProvider =
    Provider<TranslationRepository>((Ref ref) {
  return TranslationRepository();
});

/// 全应用共享的翻译语言状态。
///
/// 文本、拍照和文档翻译都订阅此 Provider。持久化仅作为应用重启后的恢复手段，
/// 不再由各功能页各自维护一份彼此滞后的语言状态。
final NotifierProvider<GlobalLanguageNotifier, GlobalLanguageState>
    globalLanguageProvider =
    NotifierProvider<GlobalLanguageNotifier, GlobalLanguageState>(
  GlobalLanguageNotifier.new,
);

class GlobalLanguageState {
  const GlobalLanguageState({
    this.fromLanguage = '自动',
    this.toLanguage = '中文',
  });

  final String fromLanguage;
  final String toLanguage;

  GlobalLanguageState copyWith({String? fromLanguage, String? toLanguage}) {
    return GlobalLanguageState(
      fromLanguage: fromLanguage ?? this.fromLanguage,
      toLanguage: toLanguage ?? this.toLanguage,
    );
  }
}

class GlobalLanguageNotifier extends Notifier<GlobalLanguageState> {
  @override
  GlobalLanguageState build() {
    Future<void>(reload);
    return const GlobalLanguageState();
  }

  TranslationRepository get _repo => ref.read(translationRepositoryProvider);

  Future<void> reload() async {
    final from = await _repo.getFromLanguage();
    final to = await _repo.getToLanguage();
    state = GlobalLanguageState(fromLanguage: from, toLanguage: to);
  }

  Future<void> setFromLanguage(String language) async {
    state = state.copyWith(fromLanguage: language);
    await _repo.saveFromLanguage(language);
  }

  Future<void> setToLanguage(String language) async {
    state = state.copyWith(toLanguage: language);
    await _repo.saveToLanguage(language);
  }

  Future<void> swapLanguages() async {
    if (state.fromLanguage == '自动') {
      return;
    }
    final from = state.toLanguage;
    final to = state.fromLanguage;
    state = GlobalLanguageState(fromLanguage: from, toLanguage: to);
    await Future.wait<void>([
      _repo.saveFromLanguage(from),
      _repo.saveToLanguage(to),
    ]);
  }
}

/// 有道 API 客户端 Provider
final Provider<YoudaoApiClient> youdaoApiClientProvider =
    Provider<YoudaoApiClient>((Ref ref) {
  return YoudaoApiClient();
});

/// 音频播放服务 Provider（单例，自动释放）
final Provider<AudioPlayerService> audioPlayerServiceProvider =
    Provider<AudioPlayerService>((Ref ref) {
  final service = AudioPlayerService();
  ref.onDispose(service.release);
  return service;
});

/// 翻译 Notifier
///
/// 对应原 Android `TranslationViewModel`，保真方法签名与行为。
/// 使用 riverpod 2.x 的 Notifier（非注解方式，避免代码生成依赖）。
final NotifierProvider<TranslationNotifier, TranslationUiState>
    translationNotifierProvider =
    NotifierProvider<TranslationNotifier, TranslationUiState>(
  TranslationNotifier.new,
);

class TranslationNotifier extends Notifier<TranslationUiState> {
  @override
  TranslationUiState build() {
    ref.listen<GlobalLanguageState>(
      globalLanguageProvider,
      (previous, next) {
        state = state.copyWith(
          fromLanguage: next.fromLanguage,
          toLanguage: next.toLanguage,
        );
      },
      fireImmediately: true,
    );
    return const TranslationUiState();
  }

  YoudaoApiClient get _apiClient => ref.read(youdaoApiClientProvider);
  AudioPlayerService get _audio => ref.read(audioPlayerServiceProvider);

  /// 重新读取持久化语言设置（供应用恢复时使用）。
  Future<void> reloadLanguages() async {
    await ref.read(globalLanguageProvider.notifier).reload();
  }

  /// 设置源语言
  Future<void> setFromLanguage(String language) {
    return ref.read(globalLanguageProvider.notifier).setFromLanguage(language);
  }

  /// 设置目标语言
  Future<void> setToLanguage(String language) {
    return ref.read(globalLanguageProvider.notifier).setToLanguage(language);
  }

  /// 设置 TTS 严格模式
  void setTtsVoiceStrict(bool strict) {
    state = state.copyWith(ttsVoiceStrict: strict);
  }

  /// 执行翻译
  ///
  /// [inputText] 输入文本
  /// [domainType] 领域类型，默认通用
  Future<void> translate(
    String inputText, {
    DomainType domainType = DomainType.general,
  }) async {
    if (inputText.trim().isEmpty) {
      state = state.copyWith(errorMessage: '请输入要翻译的文本');
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final fromCode = LanguageList.getCodeByName(state.fromLanguage);
      final toCode = LanguageList.getCodeByName(state.toLanguage);

      final response = await _apiClient.translate(
        q: inputText,
        from: fromCode,
        to: toCode,
        domainType: domainType,
      );

      if (!response.isSuccess) {
        // 保真原 onError：统一显示"翻译繁忙"
        state = state.copyWith(
          isLoading: false,
          errorMessage: '翻译繁忙',
        );
        return;
      }

      final translateData = TranslateData(
        createTime: DateTime.now().millisecondsSinceEpoch,
        query: response.query ?? inputText,
        translation: response.translation.join('\n'),
        speakUrl: response.speakUrl,
        tSpeakUrl: response.tSpeakUrl,
      );

      state = state.copyWith(
        isLoading: false,
        translateHistory: [...state.translateHistory, translateData],
        errorMessage: null,
      );
    } on Exception catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '翻译繁忙',
      );
    }
  }

  /// 选择翻译结果（用于详情页显示）
  void selectTranslateData(TranslateData data) {
    state = state.copyWith(selectedTranslateData: data);
  }

  /// 清除选中的翻译结果
  void clearSelectedData() {
    state = state.copyWith(selectedTranslateData: null);
  }

  /// 播放语音（TTS）
  Future<void> playVoice(String? speakUrl) async {
    if (speakUrl == null || !speakUrl.startsWith('http')) {
      state = state.copyWith(errorMessage: '无效的语音URL');
      return;
    }

    state = state.copyWith(playingUrl: speakUrl, isPlaying: true);

    await _audio.startPlayVoice(
      speakUrl,
      onPlayOver: () {
        state = state.copyWith(playingUrl: null, isPlaying: false);
      },
      onError: (error) {
        state = state.copyWith(
          playingUrl: null,
          isPlaying: false,
          errorMessage: '播放失败: $error',
        );
      },
    );
  }

  /// 停止播放
  Future<void> stopVoice() async {
    await _audio.stop();
    state = state.copyWith(playingUrl: null, isPlaying: false);
  }

  /// 清除错误消息
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// 清除翻译历史
  void clearHistory() {
    state = state.copyWith(translateHistory: const []);
  }
}

/// 语言切换 Notifier
///
/// 对应原 Android `LangSwitchViewModel`，保真方法签名与行为。
final NotifierProvider<LangSwitchNotifier, LangSwitchUiState>
    langSwitchNotifierProvider =
    NotifierProvider<LangSwitchNotifier, LangSwitchUiState>(
  LangSwitchNotifier.new,
);

class LangSwitchNotifier extends Notifier<LangSwitchUiState> {
  @override
  LangSwitchUiState build() {
    ref.listen<GlobalLanguageState>(
      globalLanguageProvider,
      (previous, next) {
        state = state.copyWith(
          fromLanguage: next.fromLanguage,
          toLanguage: next.toLanguage,
        );
      },
      fireImmediately: true,
    );
    return const LangSwitchUiState();
  }

  /// 设置选择类型
  ///
  /// [type] 0=源语言, 1=目标语言
  void setSelectionType(int type) {
    state = state.copyWith(selectionType: type);
  }

  /// 设置源语言并持久化
  Future<void> setFromLanguage(String language) async {
    await ref.read(globalLanguageProvider.notifier).setFromLanguage(language);
  }

  /// 设置目标语言并持久化
  Future<void> setToLanguage(String language) async {
    await ref.read(globalLanguageProvider.notifier).setToLanguage(language);
  }

  /// 交换源语言和目标语言
  ///
  /// 保真：源语言为"自动"时不交换。
  Future<void> swapLanguages() async {
    await ref.read(globalLanguageProvider.notifier).swapLanguages();
  }

  /// 更新搜索关键词
  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// 获取源语言列表（包含"自动"）
  List<String> getSourceLanguages() {
    final languages = List<String>.from(LanguageList.languages);
    if (!languages.contains('自动')) {
      languages.insert(0, '自动');
    }
    return languages;
  }

  /// 获取目标语言列表（不包含"自动"）
  List<String> getTargetLanguages() {
    return LanguageList.languages.where((l) => l != '自动').toList();
  }

  /// 根据搜索关键词过滤语言列表
  List<String> getFilteredLanguages() {
    final languages =
        state.selectionType == 0 ? getSourceLanguages() : getTargetLanguages();
    if (state.searchQuery.isEmpty) {
      return languages;
    }
    return languages.where((l) => l.contains(state.searchQuery)).toList();
  }

  /// 获取当前选中的语言
  String getSelectedLanguage() {
    return state.selectionType == 0 ? state.fromLanguage : state.toLanguage;
  }

  /// 选择语言
  Future<void> selectLanguage(String language) async {
    if (state.selectionType == 0) {
      await setFromLanguage(language);
    } else {
      await setToLanguage(language);
    }
  }
}
