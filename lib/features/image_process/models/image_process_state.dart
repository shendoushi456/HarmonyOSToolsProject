import 'dart:io';
import 'dart:typed_data';

import 'image_process_type.dart';

/// 图像处理页面状态：原图、结果图和处理过程彼此独立，便于替换 UI 层。
class ImageProcessState {
  const ImageProcessState({
    this.sourceFile,
    this.resultBytes,
    this.style = ImageStyleOption.cartoon,
    this.isProcessing = false,
    this.errorMessage,
  });

  final File? sourceFile;
  final Uint8List? resultBytes;
  final ImageStyleOption style;
  final bool isProcessing;
  final String? errorMessage;

  bool get hasSource => sourceFile != null;
  bool get hasResult => resultBytes != null;

  ImageProcessState copyWith({
    File? sourceFile,
    Uint8List? resultBytes,
    ImageStyleOption? style,
    bool? isProcessing,
    String? errorMessage,
    bool clearResult = false,
    bool clearError = false,
  }) {
    return ImageProcessState(
      sourceFile: sourceFile ?? this.sourceFile,
      resultBytes: clearResult ? null : resultBytes ?? this.resultBytes,
      style: style ?? this.style,
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
