import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/image_process_state.dart';
import '../models/image_process_type.dart';
import '../repositories/baidu_image_process_repository.dart';

final baiduImageProcessRepositoryProvider =
    Provider<BaiduImageProcessRepository>(
        (ref) => BaiduImageProcessRepository());

final imageProcessViewModelProvider = NotifierProvider.family<
    ImageProcessViewModel, ImageProcessState, ImageProcessType>(
  ImageProcessViewModel.new,
);

/// 图像处理业务状态机，页面仅负责相机/相册交互和状态展示。
class ImageProcessViewModel
    extends FamilyNotifier<ImageProcessState, ImageProcessType> {
  late ImageProcessType _type;

  @override
  ImageProcessState build(ImageProcessType arg) {
    _type = arg;
    return const ImageProcessState();
  }

  Future<void> select(File file) async {
    state = ImageProcessState(sourceFile: file);
    if (!_type.needsStyleSelection) await process();
  }

  void selectStyle(ImageStyleOption style) {
    state = state.copyWith(style: style, clearError: true);
  }

  Future<void> process() async {
    final source = state.sourceFile;
    if (source == null || state.isProcessing) return;
    state = state.copyWith(
      isProcessing: true,
      clearError: true,
      clearResult: true,
    );
    try {
      final result =
          await ref.read(baiduImageProcessRepositoryProvider).process(
                type: _type,
                image: source,
                style: state.style,
              );
      state = state.copyWith(resultBytes: result, isProcessing: false);
    } catch (e) {
      debugPrint('ImageProcess[$_type] error: $e');
      // 对齐安卓 DiscernViewMode：配额/频率类错误给出明确提示
      final message = e.toString();
      final String errorText;
      if (message.contains('daily request limit')) {
        errorText = '今日次数已经用完';
      } else if (message.contains('QPS') || message.contains('rate limit')) {
        errorText = '操作频繁，请您稍后。';
      } else {
        errorText = '图片处理失败，请稍后重试';
      }
      state = state.copyWith(isProcessing: false, errorMessage: errorText);
    }
  }
}
