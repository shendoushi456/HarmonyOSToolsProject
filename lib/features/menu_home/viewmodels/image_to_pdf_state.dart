import 'package:flutter/foundation.dart';

/// 图片转 PDF 页面状态 - 对齐 ImageToPdfActivity.kt:75-417
@immutable
class ImageToPdfState {
  final List<String> selectedImagePaths;
  final bool isProcessing;
  final String? errorMessage;
  final String? outputPath;

  const ImageToPdfState({
    this.selectedImagePaths = const [],
    this.isProcessing = false,
    this.errorMessage,
    this.outputPath,
  });

  ImageToPdfState copyWith({
    List<String>? selectedImagePaths,
    bool? isProcessing,
    String? errorMessage,
    String? outputPath,
    bool clearError = false,
    bool clearOutput = false,
  }) {
    return ImageToPdfState(
      selectedImagePaths: selectedImagePaths ?? this.selectedImagePaths,
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      outputPath: clearOutput ? null : outputPath ?? this.outputPath,
    );
  }
}
