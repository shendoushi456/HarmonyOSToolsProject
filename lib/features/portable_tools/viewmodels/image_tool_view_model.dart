import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/image_tool_state.dart';
import '../services/portable_image_tool_service.dart';

final portableImageToolServiceProvider = Provider<PortableImageToolService>(
  (ref) => PortableImageToolService(),
);

final pixelImageToolViewModelProvider =
    NotifierProvider<PixelImageToolViewModel, ImageToolState>(
        PixelImageToolViewModel.new);
final watermarkImageToolViewModelProvider =
    NotifierProvider<WatermarkImageToolViewModel, ImageToolState>(
        WatermarkImageToolViewModel.new);

class PixelImageToolViewModel extends Notifier<ImageToolState> {
  @override
  ImageToolState build() => const ImageToolState();

  Future<void> select(File file) async {
    state = ImageToolState(sourceFile: file);
  }

  Future<void> convert(int blockSize) async {
    final source = state.sourceFile;
    if (source == null) return;
    state = state.copyWith(isProcessing: true, clearError: true);
    try {
      final result = await ref
          .read(portableImageToolServiceProvider)
          .pixelate(source, blockSize: blockSize);
      state = state.copyWith(resultBytes: result, isProcessing: false);
    } catch (_) {
      state = state.copyWith(isProcessing: false, errorMessage: '图片像素化失败');
    }
  }

  Future<File?> save() async {
    if (state.resultBytes == null) return null;
    return ref.read(portableImageToolServiceProvider).savePng(
          state.resultBytes!,
          directoryName: '图片像素化',
          prefix: 'pixel_',
        );
  }
}

class WatermarkImageToolViewModel extends Notifier<ImageToolState> {
  @override
  ImageToolState build() => const ImageToolState();

  Future<void> select(File file) async {
    state = ImageToolState(sourceFile: file);
  }

  Future<void> render({
    required String text,
    required int color,
    required int alpha,
    required double fontSize,
    required double angle,
    required int spacing,
  }) async {
    final source = state.sourceFile;
    if (source == null || text.trim().isEmpty) return;
    state = state.copyWith(isProcessing: true, clearError: true);
    try {
      final result =
          await ref.read(portableImageToolServiceProvider).addWatermark(
                source,
                text: text,
                color: color,
                alpha: alpha,
                fontSize: fontSize,
                angle: angle,
                spacing: spacing,
              );
      state = state.copyWith(resultBytes: result, isProcessing: false);
    } catch (_) {
      state = state.copyWith(isProcessing: false, errorMessage: '添加水印失败');
    }
  }

  Future<File?> save() async {
    if (state.resultBytes == null) return null;
    return ref.read(portableImageToolServiceProvider).savePng(
          state.resultBytes!,
          directoryName: '图片水印',
          prefix: 'watermark_',
        );
  }
}
