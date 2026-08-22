import 'package:flutter/foundation.dart';

/// 加密 PDF 页面状态 - 对齐 AddPasswordToPdfActivity.kt:64-321
@immutable
class PdfEncryptState {
  final String? selectedPdfPath;
  final String? selectedPdfName;
  final String password;
  final bool passwordVisible;
  final bool isProcessing;
  final String? errorMessage;
  final String? outputPath;

  const PdfEncryptState({
    this.selectedPdfPath,
    this.selectedPdfName,
    this.password = '',
    this.passwordVisible = false,
    this.isProcessing = false,
    this.errorMessage,
    this.outputPath,
  });

  PdfEncryptState copyWith({
    String? selectedPdfPath,
    String? selectedPdfName,
    String? password,
    bool? passwordVisible,
    bool? isProcessing,
    String? errorMessage,
    String? outputPath,
    bool clearError = false,
    bool clearOutput = false,
  }) {
    return PdfEncryptState(
      selectedPdfPath: selectedPdfPath ?? this.selectedPdfPath,
      selectedPdfName: selectedPdfName ?? this.selectedPdfName,
      password: password ?? this.password,
      passwordVisible: passwordVisible ?? this.passwordVisible,
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      outputPath: clearOutput ? null : outputPath ?? this.outputPath,
    );
  }
}
