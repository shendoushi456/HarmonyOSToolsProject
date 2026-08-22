import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../services/pdf_kit_service.dart';
import 'image_to_pdf_state.dart';

final imageToPdfViewModelProvider = NotifierProvider<ImageToPdfViewModel, ImageToPdfState>(
  ImageToPdfViewModel.new,
);

/// 图片转 PDF ViewModel - 对齐 ImageToPdfActivity.kt:75-417
class ImageToPdfViewModel extends Notifier<ImageToPdfState> {
  final PdfKitService _pdfService = PdfKitService();
  final ImagePicker _picker = ImagePicker();

  @override
  ImageToPdfState build() {
    return const ImageToPdfState();
  }

  /// 选择图片，最多 30 张 - 对齐 ImageToPdfActivity.kt:135-146
  Future<void> pickImages() async {
    final picked = await _picker.pickMultiImage();
    if (picked.isEmpty) return;

    // 限制 30 张
    final List<XFile> files = picked.length > 30 ? picked.sublist(0, 30) : picked;

    // 拷贝到沙箱临时目录
    final cacheDir = await getTemporaryDirectory();
    final targetDir = '${cacheDir.path}/image_to_pdf_${DateTime.now().millisecondsSinceEpoch}';
    await Directory(targetDir).create(recursive: true);

    final paths = <String>[];
    for (final file in files) {
      final targetPath = '$targetDir/${file.name}';
      await File(file.path).copy(targetPath);
      paths.add(targetPath);
    }

    state = state.copyWith(
      selectedImagePaths: [...state.selectedImagePaths, ...paths],
      clearError: true,
      clearOutput: true,
    );
  }

  /// 删除已选图片
  void removeImage(int index) {
    final paths = [...state.selectedImagePaths];
    if (index < 0 || index >= paths.length) return;
    paths.removeAt(index);
    state = state.copyWith(selectedImagePaths: paths);
  }

  /// 转换 PDF - 对齐 ImageToPdfActivity.kt:265-338
  Future<void> convert() async {
    if (state.selectedImagePaths.isEmpty) {
      state = state.copyWith(errorMessage: '请先选择图片');
      return;
    }
    state = state.copyWith(isProcessing: true, clearError: true, clearOutput: true);
    try {
      final output = await _pdfService.convertImagesToPdf(state.selectedImagePaths);
      state = state.copyWith(isProcessing: false, outputPath: output);
    } catch (e) {
      state = state.copyWith(isProcessing: false, errorMessage: '转换失败：$e');
    }
  }
}
