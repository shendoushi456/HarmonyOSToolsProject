import 'package:flutter/foundation.dart';

/// PDF 转图片页面状态 - 对齐 PdfToImageActivity.kt:48-345
@immutable
class PdfToImageState {
  final String? selectedPdfPath;
  final String? selectedPdfName;
  final bool isProcessing;
  final bool isSaving;
  final List<String> generatedImagePaths;
  final String? errorMessage;

  const PdfToImageState({
    this.selectedPdfPath,
    this.selectedPdfName,
    this.isProcessing = false,
    this.isSaving = false,
    this.generatedImagePaths = const [],
    this.errorMessage,
  });

  PdfToImageState copyWith({
    String? selectedPdfPath,
    String? selectedPdfName,
    bool? isProcessing,
    bool? isSaving,
    List<String>? generatedImagePaths,
    String? errorMessage,
    bool clearError = false,
    bool clearImages = false,
  }) {
    return PdfToImageState(
      selectedPdfPath: selectedPdfPath ?? this.selectedPdfPath,
      selectedPdfName: selectedPdfName ?? this.selectedPdfName,
      isProcessing: isProcessing ?? this.isProcessing,
      isSaving: isSaving ?? this.isSaving,
      generatedImagePaths: clearImages
          ? const []
          : generatedImagePaths ?? this.generatedImagePaths,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
