import 'package:harmonyos_flutter_empty/features/translation/domain/english_result.dart';

/// 作文批改 UI 状态
///
/// 对应原 Android `ArticleCorrectionUiState`，保真字段与默认值。
class ArticleCorrectionUiState {
  const ArticleCorrectionUiState({
    this.isLoading = false,
    this.errorMessage,
    this.correctionResult,
    this.selectedGrade = '默认',
  });

  /// 是否正在批改中
  final bool isLoading;

  /// 错误消息
  final String? errorMessage;

  /// 批改结果
  final EnglishResult? correctionResult;

  /// 选中的等级（中文名）
  final String selectedGrade;

  ArticleCorrectionUiState copyWith({
    bool? isLoading,
    String? errorMessage,
    EnglishResult? correctionResult,
    bool clearCorrectionResult = false,
    String? selectedGrade,
  }) {
    return ArticleCorrectionUiState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      correctionResult: clearCorrectionResult
          ? null
          : correctionResult ?? this.correctionResult,
      selectedGrade: selectedGrade ?? this.selectedGrade,
    );
  }
}
