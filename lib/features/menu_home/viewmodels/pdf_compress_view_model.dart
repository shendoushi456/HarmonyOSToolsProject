import 'dart:io';
import 'package:file_picker_ohos/file_picker_ohos.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../services/pdf_kit_service.dart';
import 'pdf_compress_state.dart';

final pdfCompressViewModelProvider = NotifierProvider<PdfCompressViewModel, PdfCompressState>(
  PdfCompressViewModel.new,
);

/// 压缩 PDF ViewModel - 对齐 PdfCompressActivity.kt:61-352
class PdfCompressViewModel extends Notifier<PdfCompressState> {
  final PdfKitService _pdfService = PdfKitService();

  @override
  PdfCompressState build() {
    return const PdfCompressState();
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
    final targetPath = '${cacheDir.path}/pdf_compress_${DateTime.now().millisecondsSinceEpoch}.pdf';
    await File(path).copy(targetPath);

    final sourceFile = File(targetPath);
    final sourceSize = await sourceFile.length();

    state = state.copyWith(
      selectedPdfPath: targetPath,
      selectedPdfName: file.name,
      sourceSize: sourceSize,
      clearError: true,
      clearOutput: true,
    );
  }

  /// 压缩 PDF
  Future<void> compress() async {
    if (state.selectedPdfPath == null) {
      state = state.copyWith(errorMessage: '请先选择 PDF');
      return;
    }
    state = state.copyWith(isProcessing: true, clearError: true, clearOutput: true);
    try {
      final output = await _pdfService.compressPdf(state.selectedPdfPath!);
      final outputSize = await File(output).length();
      state = state.copyWith(
        isProcessing: false,
        outputSize: outputSize,
      );
    } catch (e) {
      state = state.copyWith(isProcessing: false, errorMessage: '压缩失败：$e');
    }
  }
}
