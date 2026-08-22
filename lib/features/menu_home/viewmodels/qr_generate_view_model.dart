import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'qr_generate_state.dart';

final qrGenerateViewModelProvider = NotifierProvider<QrGenerateViewModel, QrGenerateState>(
  QrGenerateViewModel.new,
);

/// 生成二维码 ViewModel - 对齐 QRCodeActivity.java:52-252
class QrGenerateViewModel extends Notifier<QrGenerateState> {
  final ImagePicker _picker = ImagePicker();

  @override
  QrGenerateState build() {
    return const QrGenerateState();
  }

  void setInputText(String value) {
    state = state.copyWith(inputText: value);
  }

  void setForegroundColor(Color color) {
    state = state.copyWith(foregroundColor: color);
  }

  void setBackgroundColor(Color color) {
    state = state.copyWith(backgroundColor: color);
  }

  void setSize(double value) {
    state = state.copyWith(size: value);
  }

  /// 选择 Logo 图片 - 对齐 QRCodeActivity.java:87-101
  Future<void> pickLogo() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final cacheDir = await getTemporaryDirectory();
    final targetPath = '${cacheDir.path}/qr_logo_${DateTime.now().millisecondsSinceEpoch}.png';
    await File(picked.path).copy(targetPath);
    state = state.copyWith(logoPath: targetPath);
  }

  /// 生成二维码
  Future<void> generate() async {
    if (state.inputText.isEmpty) {
      return;
    }
    final bytes = await _renderQr(
      data: state.inputText,
      size: state.size,
      foregroundColor: state.foregroundColor,
      backgroundColor: state.backgroundColor,
      logoPath: state.logoPath,
    );
    state = state.copyWith(generatedQrBytes: bytes, showPreviewDialog: true);
  }

  /// 关闭预览
  void dismissPreview() {
    state = state.copyWith(showPreviewDialog: false);
  }

  /// 保存二维码 - 对齐 QRCodeActivity.java:181-198
  Future<String?> save() async {
    if (state.generatedQrBytes == null) return null;
    state = state.copyWith(isSaving: true);
    try {
      final docDir = await getApplicationDocumentsDirectory();
      final dir = '${docDir.path}/工具箱/二维码生成';
      await Directory(dir).create(recursive: true);
      final now = DateTime.now();
      final fileName = 'Image-${now.hour.toString().padLeft(2, '0')}-${now.minute.toString().padLeft(2, '0')}-${now.second.toString().padLeft(2, '0')}.png';
      final path = '$dir/$fileName';
      await File(path).writeAsBytes(state.generatedQrBytes!);
      state = state.copyWith(isSaving: false);
      return path;
    } catch (e) {
      state = state.copyWith(isSaving: false);
      rethrow;
    }
  }

  Future<Uint8List> _renderQr({
    required String data,
    required double size,
    required Color foregroundColor,
    required Color backgroundColor,
    String? logoPath,
  }) async {
    final validation = QrValidator.validate(data: data, version: QrVersions.auto);
    if (validation.status != QrValidationStatus.valid || validation.qrCode == null) {
      throw Exception('二维码内容无效');
    }

    ui.Image? embeddedImage;
    if (logoPath != null) {
      final data = await File(logoPath).readAsBytes();
      final codec = await ui.instantiateImageCodec(data);
      final frame = await codec.getNextFrame();
      embeddedImage = frame.image;
    }

    final painter = QrPainter.withQr(
      qr: validation.qrCode!,
      gapless: true,
      embeddedImage: embeddedImage,
      embeddedImageStyle: embeddedImage != null
          ? const QrEmbeddedImageStyle(size: Size(60, 60))
          : null,
      eyeStyle: QrEyeStyle(
        eyeShape: QrEyeShape.square,
        color: foregroundColor,
      ),
      dataModuleStyle: QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.square,
        color: foregroundColor,
      ),
    );

    final imageData = await painter.toImageData(size, format: ui.ImageByteFormat.png);
    if (imageData == null) throw Exception('二维码渲染失败');
    return imageData.buffer.asUint8List();
  }
}
