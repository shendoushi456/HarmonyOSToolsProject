import 'dart:io';
import 'dart:typed_data';

/// 图像工具共用状态，原图与处理结果始终分离，方便页面替换展示层。
class ImageToolState {
  const ImageToolState({
    this.sourceFile,
    this.resultBytes,
    this.isProcessing = false,
    this.errorMessage,
  });

  final File? sourceFile;
  final Uint8List? resultBytes;
  final bool isProcessing;
  final String? errorMessage;

  bool get hasImage => sourceFile != null;
  bool get hasResult => resultBytes != null;

  ImageToolState copyWith({
    File? sourceFile,
    Uint8List? resultBytes,
    bool? isProcessing,
    String? errorMessage,
    bool clearResult = false,
    bool clearError = false,
  }) {
    return ImageToolState(
      sourceFile: sourceFile ?? this.sourceFile,
      resultBytes: clearResult ? null : resultBytes ?? this.resultBytes,
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
