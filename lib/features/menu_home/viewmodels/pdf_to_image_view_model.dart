import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker_ohos/file_picker_ohos.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../../scan_menu/services/document_export_service.dart';
import '../services/pdf_kit_service.dart';
import 'pdf_to_image_state.dart';

final pdfToImageViewModelProvider =
    NotifierProvider<PdfToImageViewModel, PdfToImageState>(
  PdfToImageViewModel.new,
);

/// PDF 转图片 ViewModel - 对齐 PdfToImageActivity.kt:48-345
class PdfToImageViewModel extends Notifier<PdfToImageState> {
  final PdfKitService _pdfService = PdfKitService();

  @override
  PdfToImageState build() {
    return const PdfToImageState();
  }

  /// 选择 PDF 文件 - 对齐 PdfFileUtils.createOpenPdfIntent
  Future<void> pickPdf() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: false,
      );
      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      final path = file.path;
      if (path == null || path.isEmpty) {
        state = state.copyWith(errorMessage: '无法读取所选 PDF 文件路径');
        return;
      }

      // file_picker_ohos 已将系统 URI 缓存为应用可读路径；再复制到本功能的临时文件，
      // 避免后续原生 PDF 服务访问到已被选择器清理的临时文件。
      final cacheDir = await getTemporaryDirectory();
      final targetPath =
          '${cacheDir.path}/pdf_to_image_${DateTime.now().millisecondsSinceEpoch}.pdf';
      await File(path).copy(targetPath);

      state = state.copyWith(
        selectedPdfPath: targetPath,
        selectedPdfName: file.name,
        clearError: true,
        clearImages: true,
      );
    } catch (e) {
      // 选择器异常此前没有反馈，用户会看到“点击无反应”。将异常展示在页面上，
      // 同时保留可重试状态。
      state = state.copyWith(errorMessage: '选择 PDF 失败：$e');
    }
  }

  /// 开始转换
  Future<void> convert() async {
    if (state.selectedPdfPath == null) {
      state = state.copyWith(errorMessage: '请先选择 PDF');
      return;
    }

    state = state.copyWith(
      isProcessing: true,
      clearError: true,
      clearImages: true,
    );

    try {
      final images =
          await _pdfService.convertPdfToImages(state.selectedPdfPath!);
      if (images.isEmpty) {
        throw Exception('PDF 未生成图片');
      }
      state = state.copyWith(
        isProcessing: false,
        generatedImagePaths: images,
      );
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        errorMessage: '转换失败：$e',
      );
    }
  }

  /// 保存全部生成图片到系统相册。
  /// 返回成功保存的张数；用户取消返回 -1；失败时错误已写入 errorMessage 并返回 0。
  Future<int> saveAllToGallery() async {
    final paths = state.generatedImagePaths;
    if (paths.isEmpty || state.isSaving || state.isProcessing) return 0;

    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final bytesList = <Uint8List>[];
      for (final path in paths) {
        bytesList.add(await File(path).readAsBytes());
      }
      // 以所选 PDF 文件名（去扩展名）作为相册图片名前缀。
      final pdfName = state.selectedPdfName ?? '';
      final name = pdfName.toLowerCase().endsWith('.pdf')
          ? pdfName.substring(0, pdfName.length - 4)
          : (pdfName.isEmpty ? 'PDF转图片' : pdfName);
      await DocumentExportService()
          .exportBytesListToGallery(bytesList, name: name);
      state = state.copyWith(isSaving: false);
      return bytesList.length;
    } on GalleryExportException catch (e) {
      state = state.copyWith(isSaving: false);
      // 用户主动取消不当作错误提示。
      if (!e.isCanceled) {
        state = state.copyWith(errorMessage: '保存失败：${e.message}');
      }
      return -1;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: '保存失败：$e',
      );
      return 0;
    }
  }
}
