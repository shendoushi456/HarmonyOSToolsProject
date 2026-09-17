import 'dart:io';
import 'package:file_picker_ohos/file_picker_ohos.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../services/pdf_kit_service.dart';
import 'pdf_encrypt_state.dart';

final pdfEncryptViewModelProvider = NotifierProvider<PdfEncryptViewModel, PdfEncryptState>(
  PdfEncryptViewModel.new,
);

/// 加密 PDF ViewModel - 对齐 AddPasswordToPdfActivity.kt:64-321
class PdfEncryptViewModel extends Notifier<PdfEncryptState> {
  final PdfKitService _pdfService = PdfKitService();

  @override
  PdfEncryptState build() {
    return const PdfEncryptState();
  }

  /// 选择 PDF
  Future<void> pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: false,
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    final path = file.path;
    if (path == null || path.isEmpty) return;

    final cacheDir = await getTemporaryDirectory();
    final targetPath = '${cacheDir.path}/pdf_encrypt_${DateTime.now().millisecondsSinceEpoch}.pdf';
    await File(path).copy(targetPath);

    state = state.copyWith(
      selectedPdfPath: targetPath,
      selectedPdfName: file.name,
      clearError: true,
      clearOutput: true,
    );
  }

  /// 设置密码
  void setPassword(String value) {
    state = state.copyWith(password: value, clearError: true);
  }

  /// 切换密码可见性
  void togglePasswordVisibility() {
    state = state.copyWith(passwordVisible: !state.passwordVisible);
  }

  /// 加密 PDF
  Future<void> encrypt() async {
    if (state.selectedPdfPath == null) {
      state = state.copyWith(errorMessage: '请先选择 PDF');
      return;
    }
    if (state.password.isEmpty) {
      state = state.copyWith(errorMessage: '请输入密码');
      return;
    }
    state = state.copyWith(isProcessing: true, clearError: true, clearOutput: true);
    try {
      final output = await _pdfService.encryptPdf(
        state.selectedPdfPath!,
        state.selectedPdfName ?? 'document.pdf',
        state.password,
      );
      state = state.copyWith(isProcessing: false, outputPath: output);
    } on PlatformException catch (e) {
      if (e.code == 'PDF_SAVE_CANCELED') {
        // 用户在系统保存选择器点了取消，不当作错误
        state = state.copyWith(isProcessing: false);
        return;
      }
      state = state.copyWith(
        isProcessing: false,
        errorMessage: '加密失败：${e.message ?? e.code}',
      );
    } catch (e) {
      state = state.copyWith(isProcessing: false, errorMessage: '加密失败：$e');
    }
  }
}
