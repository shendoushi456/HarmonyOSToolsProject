import 'package:flutter/foundation.dart';

/// PDF 转图片页面状态 - 对齐 PdfToImageActivity.kt:48-345
@immutable
class PdfToImageState {
  final String? selectedPdfPath;
  final String? selectedPdfName;
  final String password;
  final bool showPasswordDialog;
  final String? passwordError;
  final bool isProcessing;
  final List<String> generatedImagePaths;
  final String? errorMessage;

  const PdfToImageState({
    this.selectedPdfPath,
    this.selectedPdfName,
    this.password = '',
    this.showPasswordDialog = false,
    this.passwordError,
    this.isProcessing = false,
    this.generatedImagePaths = const [],
    this.errorMessage,
  });

  PdfToImageState copyWith({
    String? selectedPdfPath,
    String? selectedPdfName,
    String? password,
    bool? showPasswordDialog,
    String? passwordError,
    bool? isProcessing,
    List<String>? generatedImagePaths,
    String? errorMessage,
    bool clearError = false,
    bool clearPasswordError = false,
    bool clearImages = false,
  }) {
    return PdfToImageState(
      selectedPdfPath: selectedPdfPath ?? this.selectedPdfPath,
      selectedPdfName: selectedPdfName ?? this.selectedPdfName,
      password: password ?? this.password,
      showPasswordDialog: showPasswordDialog ?? this.showPasswordDialog,
      passwordError: clearPasswordError ? null : passwordError ?? this.passwordError,
      isProcessing: isProcessing ?? this.isProcessing,
      generatedImagePaths: clearImages ? const [] : generatedImagePaths ?? this.generatedImagePaths,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
