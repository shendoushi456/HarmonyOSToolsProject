import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/article_correction_api_client.dart';
import '../../domain/correction_grades.dart';
import '../../domain/english_result.dart';
import 'package:harmonyos_flutter_empty/features/translation/presentation/states/article_correction_ui_state.dart';

/// 作文批改 API 客户端 Provider
final Provider<ArticleCorrectionApiClient> articleCorrectionApiClientProvider =
    Provider<ArticleCorrectionApiClient>((Ref ref) {
  return ArticleCorrectionApiClient();
});

/// 作文批改 Notifier
///
/// 对应原 Android `ArticleCorrectionViewModel`，保真方法签名与行为。
final NotifierProvider<ArticleCorrectionNotifier, ArticleCorrectionUiState>
    articleCorrectionNotifierProvider =
    NotifierProvider<ArticleCorrectionNotifier, ArticleCorrectionUiState>(
  ArticleCorrectionNotifier.new,
);

class ArticleCorrectionNotifier extends Notifier<ArticleCorrectionUiState> {
  @override
  ArticleCorrectionUiState build() => const ArticleCorrectionUiState();

  ArticleCorrectionApiClient get _apiClient =>
      ref.read(articleCorrectionApiClientProvider);

  /// 设置作文等级
  void setGrade(String grade) {
    state = state.copyWith(selectedGrade: grade);
  }

  /// 执行作文批改
  ///
  /// [text] 作文文本
  /// [title] 作文标题（可选）
  Future<void> correctArticle(String text, {String? title}) async {
    if (text.trim().isEmpty) {
      state = state.copyWith(errorMessage: '请输入要批改的作文');
      return;
    }

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      clearCorrectionResult: true,
    );

    try {
      final gradeCode = CorrectionGrades.getGradeCode(state.selectedGrade);
      final EnglishResult result = await _apiClient.correctArticle(
        text: text,
        grade: gradeCode,
        title: title,
      );
      state = state.copyWith(
        isLoading: false,
        correctionResult: result,
      );
    } on Object catch (error, stackTrace) {
      // JSON 类型错误等属于 Error 而不是 Exception；必须统一收口，
      // 否则 Loading 遮罩会一直显示，部分平台还会直接报未处理异常。
      debugPrint('Article correction failed: $error\n$stackTrace');
      final msg = error.toString();
      final message = msg.startsWith('Exception: ')
          ? msg.substring('Exception: '.length)
          : '批改失败，请重试';
      state = state.copyWith(
        isLoading: false,
        errorMessage: message,
      );
    }
  }

  /// 清除批改结果
  void clearResult() {
    state = state.copyWith(clearCorrectionResult: true);
  }

  /// 清除错误消息
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
