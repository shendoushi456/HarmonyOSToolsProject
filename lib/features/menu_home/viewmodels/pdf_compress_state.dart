import 'package:flutter/foundation.dart';

/// 压缩 PDF 页面状态 - 对齐 PdfCompressActivity.kt:61-352
@immutable
class PdfCompressState {
  final String? selectedPdfPath;
  final String? selectedPdfName;
  final int? sourceSize;
  final int? outputSize;
  /// 压缩结果保存位置（用户通过系统保存选择器确认的公共目录 uri）
  final String? outputPath;
  final bool isProcessing;
  final String? errorMessage;

  const PdfCompressState({
    this.selectedPdfPath,
    this.selectedPdfName,
    this.sourceSize,
    this.outputSize,
    this.outputPath,
    this.isProcessing = false,
    this.errorMessage,
  });

  PdfCompressState copyWith({
    String? selectedPdfPath,
    String? selectedPdfName,
    int? sourceSize,
    int? outputSize,
    String? outputPath,
    bool? isProcessing,
    String? errorMessage,
    bool clearError = false,
    bool clearOutput = false,
  }) {
    return PdfCompressState(
      selectedPdfPath: selectedPdfPath ?? this.selectedPdfPath,
      selectedPdfName: selectedPdfName ?? this.selectedPdfName,
      sourceSize: sourceSize ?? this.sourceSize,
      outputSize: clearOutput ? null : outputSize ?? this.outputSize,
      outputPath: clearOutput ? null : outputPath ?? this.outputPath,
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
