import 'dart:io';
import 'package:file_picker_ohos/file_picker_ohos.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../services/pdf_kit_service.dart';
import 'pdf_to_image_state.dart';

final pdfToImageViewModelProvider = NotifierProvider<PdfToImageViewModel, PdfToImageState>(
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
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: false,
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    final path = file.path;
    if (path == null || path.isEmpty) return;

    // 拷贝到沙箱
    final cacheDir = await getTemporaryDirectory();
    final targetPath = '${cacheDir.path}/pdf_to_image_${DateTime.now().millisecondsSinceEpoch}.pdf';
    await File(path).copy(targetPath);

    state = state.copyWith(
      selectedPdfPath: targetPath,
      selectedPdfName: file.name,
      clearError: true,
      clearImages: true,
    );
  }

  /// 设置密码
  void setPassword(String value) {
    state = state.copyWith(password: value, clearPasswordError: true);
  }

  /// 显示密码输入弹窗
  void showPasswordDialog() {
    state = state.copyWith(showPasswordDialog: true, clearPasswordError: true);
  }

  /// 关闭密码输入弹窗
  void dismissPasswordDialog() {
    state = state.copyWith(showPasswordDialog: false, clearPasswordError: true);
  }

  /// 确认密码并转换
  Future<void> confirmPasswordAndConvert() async {
    if (state.password.isEmpty) {
      state = state.copyWith(passwordError: '请输入密码');
      return;
    }
    state = state.copyWith(showPasswordDialog: false);
    await _convert(password: state.password);
  }

  /// 开始转换
  Future<void> convert() async {
    await _convert();
  }

  Future<void> _convert({String? password}) async {
    if (state.selectedPdfPath == null) {
      state = state.copyWith(errorMessage: '请先选择 PDF');
      return;
    }
    state = state.copyWith(isProcessing: true, clearError: true, clearImages: true);
    try {
      final images = await _pdfService.convertPdfToImages(
        state.selectedPdfPath!,
        password: password,
      );
      state = state.copyWith(isProcessing: false, generatedImagePaths: images);
    } catch (e) {
      final msg = e.toString();
      // 如果提示密码相关错误，弹出密码框
      if (msg.contains('密码') || msg.contains('加密') || msg.contains('Security')) {
        state = state.copyWith(
          isProcessing: false,
          showPasswordDialog: true,
          passwordError: '该 PDF 需要密码',
        );
      } else {
        state = state.copyWith(isProcessing: false, errorMessage: '转换失败：$msg');
      }
    }
  }
}
