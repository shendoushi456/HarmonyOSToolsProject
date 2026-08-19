import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:harmonyos_flutter_empty/features/translation/data/ocr_trans_api_client.dart';
import 'package:harmonyos_flutter_empty/features/translation/domain/ocr_translation_result.dart';
import 'package:harmonyos_flutter_empty/features/translation/presentation/providers/translation_provider.dart'
    show GlobalLanguageState, globalLanguageProvider;
import 'package:harmonyos_flutter_empty/features/translation/presentation/states/ocr_translation_ui_state.dart';

/// OCR 翻译 API 客户端 Provider
final Provider<OcrTransApiClient> ocrTransApiClientProvider =
    Provider<OcrTransApiClient>((Ref ref) {
  return OcrTransApiClient();
});

/// OCR 图片翻译 Notifier
///
/// 对应原 Android `OcrTranslationViewModel`，保真方法签名与行为。
/// 复用全局语言状态，保证与文本、文档翻译实时同步。
final NotifierProvider<OcrTranslationNotifier, OcrTranslationUiState>
    ocrTranslationNotifierProvider =
    NotifierProvider<OcrTranslationNotifier, OcrTranslationUiState>(
  OcrTranslationNotifier.new,
);

class OcrTranslationNotifier extends Notifier<OcrTranslationUiState> {
  @override
  OcrTranslationUiState build() {
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
    return const OcrTranslationUiState();
  }

  OcrTransApiClient get _apiClient => ref.read(ocrTransApiClientProvider);

  /// 重新读取持久化语言设置（供应用恢复时使用）。
  Future<void> reloadLanguages() async {
    await ref.read(globalLanguageProvider.notifier).reload();
  }

  /// 从文件翻译图片
  ///
  /// [file] XFile（由 file_selector 选择）
  Future<void> translateImageFromFile(XFile file) async {
    debugPrint('asdfasfcxv OCR source: fileName=${file.name}');
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      translationResult: null,
    );

    try {
      debugPrint('asdfasfcxv OCR reading source bytes');
      final bytes = await file.readAsBytes().timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('读取图片超时'),
          );
      debugPrint('asdfasfcxv OCR sourceBytes=${bytes.length}');
      if (bytes.isEmpty) {
        throw Exception('无法读取图片');
      }
      final base64Str = base64Encode(bytes);
      debugPrint('asdfasfcxv OCR base64Length=${base64Str.length}');
      // 有道图片翻译 API 限制：Base64 编码后 5MB 以内。
      // 拍照的原图可能较大（几 MB），Base64 后膨胀 ~33%，需提前拦截。
      if (base64Str.length > 5 * 1024 * 1024) {
        throw Exception(
            '图片过大（${(base64Str.length / 1024 / 1024).toStringAsFixed(1)}MB），请选择小于3.5MB的图片');
      }
      debugPrint('asdfasfcxv OCR calling API');
      final OcrTranslationResult result = await _apiClient
          .translateImage(
            base64Image: base64Str,
            fromLanguage: state.fromLanguage,
            toLanguage: state.toLanguage,
          )
          .timeout(
            const Duration(seconds: 90),
            onTimeout: () => throw Exception('图片识别超时，请检查网络后重试'),
          );
      debugPrint(
        'asdfasfcxv OCR API returned: '
        'originalLength=${result.originalText.length}, '
        'translatedLength=${result.translatedText.length}',
      );

      // 保真原 parseResult：原文和译文都为空时显示"未识别到文字"
      if (result.originalText.isEmpty && result.translatedText.isEmpty) {
        debugPrint('asdfasfcxv OCR result empty');
        state = state.copyWith(
          isLoading: false,
          errorMessage: '未识别到文字',
        );
        return;
      }

      debugPrint('asdfasfcxv OCR success');
      state = state.copyWith(
        isLoading: false,
        translationResult: result,
      );
    } on Object catch (error, stackTrace) {
      debugPrint('asdfasfcxv OCR translation failed: $error\n$stackTrace');
      final msg = error.toString();
      final message = msg.startsWith('Exception: ')
          ? msg.substring('Exception: '.length)
          : '翻译失败，请重试';
      state = state.copyWith(
        isLoading: false,
        errorMessage: message,
      );
    }
  }

  /// 清除错误消息
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// 清除翻译结果
  void clearResult() {
    state = state.copyWith(translationResult: null);
  }
}
