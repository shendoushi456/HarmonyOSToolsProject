// 毛玻璃 ViewModel - 对齐 Android ToolsPictureBlurActivity.java
// pickImage(image_picker) → decodeImage + 降采样 1024 → applyBoxBlur → 保存 PNG
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import '../pages/blur/widgets/box_blur.dart';
import 'blur_state.dart';

class BlurViewModel extends Notifier<BlurState> {
  @override
  BlurState build() => const BlurState();

  /// 设置模糊半径 - 对齐 seekbar1 onProgressChanged
  void setRadius(int r) {
    state = state.copyWith(radius: r);
    if (state.originalBytes != null) {
      _applyBlur();
    }
  }

  /// 选择图片 - 对齐 ToolsPictureBlurActivity.java:167-194
  Future<void> pickImage(Uint8List bytes) async {
    state = state.copyWith(originalBytes: bytes, isProcessing: true, clearError: true);
    await _applyBlur();
  }

  /// 应用模糊 - 在 isolate 跑 box-blur 避免卡 UI
  Future<void> _applyBlur() async {
    if (state.originalBytes == null) return;
    state = state.copyWith(isProcessing: true);
    try {
      final blurred = await compute(_blurInIsolate, _BlurInput(
        state.originalBytes!,
        state.radius,
      ));
      state = state.copyWith(blurredBytes: blurred, isProcessing: false);
    } catch (e) {
      state = state.copyWith(isProcessing: false, error: '模糊失败: $e');
    }
  }
}

/// isolate 入参
class _BlurInput {
  const _BlurInput(this.bytes, this.radius);
  final Uint8List bytes;
  final int radius;
}

/// 在 isolate 中执行(对齐 ToolsPictureBlurActivity.java:120 Blurry.async)
Uint8List _blurInIsolate(_BlurInput input) {
  var image = img.decodeImage(input.bytes);
  if (image == null) throw StateError('图片解码失败');
  // 降采样到 1024×1024 上限(对齐 decodeSampleBitmapFromPath)
  if (image.width > 1024 || image.height > 1024) {
    final scale = 1024 / image.width > 1024 / image.height
        ? 1024 / image.width
        : 1024 / image.height;
    image = img.copyResize(image,
        width: (image.width * scale).round(),
        height: (image.height * scale).round());
  }
  final blurred = applyBoxBlur(image, input.radius);
  return Uint8List.fromList(img.encodePng(blurred));
}

/// 毛玻璃 ViewModel Provider
final blurViewModelProvider =
    NotifierProvider<BlurViewModel, BlurState>(BlurViewModel.new);
