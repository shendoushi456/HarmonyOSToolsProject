import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../services/pdf_kit_service.dart';
import 'image_to_pdf_state.dart';

final imageToPdfViewModelProvider = NotifierProvider<ImageToPdfViewModel, ImageToPdfState>(
  ImageToPdfViewModel.new,
);

/// 图片转 PDF ViewModel - 对齐 ImageToPdfActivity.kt:75-417
/// 鸿蒙版按需求调整为：仅支持选择一张图片转换。
class ImageToPdfViewModel extends Notifier<ImageToPdfState> {
  final PdfKitService _pdfService = PdfKitService();
  final ImagePicker _picker = ImagePicker();

  @override
  ImageToPdfState build() {
    return const ImageToPdfState();
  }

  /// 选择图片（单张） - 对齐 ImageToPdfActivity.kt:135-146，按需求改为单选
  Future<void> pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    // 拷贝到沙箱临时目录，避免选择器清理临时文件
    final cacheDir = await getTemporaryDirectory();
    final targetPath =
        '${cacheDir.path}/image_to_pdf_${DateTime.now().millisecondsSinceEpoch}_${picked.name}';
    await File(picked.path).copy(targetPath);

    state = state.copyWith(
      selectedImagePaths: [targetPath],
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
  /// 转换后原生侧弹出系统保存位置选择器（默认下载目录）。
  Future<void> convert() async {
    if (state.selectedImagePaths.isEmpty) {
      state = state.copyWith(errorMessage: '请先选择图片');
      return;
    }
    state = state.copyWith(isProcessing: true, clearError: true, clearOutput: true);
    try {
      final imagePath = state.selectedImagePaths.first;
      // 用 image 包读取真实宽高，原生侧据此做 A4 等比缩放（横向图不再被错误压缩）
      final size = await _readImageSize(imagePath);
      // 保存文件名沿用所选图片名（.pdf 扩展名）
      final base = imagePath.substring(imagePath.lastIndexOf('/') + 1);
      final dot = base.lastIndexOf('.');
      final fileName = dot > 0 ? '${base.substring(0, dot)}.pdf' : '$base.pdf';

      final output = await _pdfService.convertImagesToPdf(
        [imagePath],
        widths: [size.width],
        heights: [size.height],
        fileName: fileName,
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
        errorMessage: '转换失败：${e.message ?? e.code}',
      );
    } catch (e) {
      state = state.copyWith(isProcessing: false, errorMessage: '转换失败：$e');
    }
  }

  /// 读取图片真实宽高。
  /// 只解码文件头（findDecoderForData + startDecode），不整图解码。
  /// 解析失败时抛出友好错误。
  Future<_ImageSize> _readImageSize(String path) async {
    final bytes = await File(path).readAsBytes();
    final decoder = img.findDecoderForData(bytes);
    if (decoder != null) {
      final info = decoder.startDecode(bytes);
      if (info != null && info.width > 0 && info.height > 0) {
        return _ImageSize(info.width, info.height);
      }
    }
    throw Exception('无法识别所选图片格式');
  }
}

/// 图片真实尺寸（项目语言版本不支持 records，用简单类）
class _ImageSize {
  final int width;
  final int height;

  const _ImageSize(this.width, this.height);
}
