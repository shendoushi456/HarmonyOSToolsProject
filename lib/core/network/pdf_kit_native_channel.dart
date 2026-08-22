import 'package:flutter/services.dart';

/// PDF Kit 原生通道 - 对齐 ohos/entry/src/main/ets/plugins/PdfKitPlugin.ets
/// 提供鸿蒙 pdfService 的 4 个 PDF 处理能力：
/// - 图片转 PDF
/// - PDF 转图片
/// - 压缩 PDF
/// - 加密 PDF
class PdfKitNativeChannel {
  PdfKitNativeChannel._();
  static final PdfKitNativeChannel _instance = PdfKitNativeChannel._();
  static PdfKitNativeChannel get instance => _instance;

  static const MethodChannel _channel = MethodChannel('qingman.pdf_kit/native');

  /// 图片转 PDF
  /// 对齐 ImageToPdfProcessor.kt:20-103
  Future<String?> convertImagesToPdf({
    required List<String> imagePaths,
    required String outputPath,
  }) async {
    return _channel.invokeMethod<String>('convertImagesToPdf', {
      'imagePaths': imagePaths,
      'outputPath': outputPath,
    });
  }

  /// PDF 转图片
  /// 对齐 PdfToImageProcessor.kt:17-96
  Future<List<String>> convertPdfToImages({
    required String pdfPath,
    required String outputDir,
    String? password,
  }) async {
    final result = await _channel.invokeMethod<List<dynamic>>('convertPdfToImages', {
      'pdfPath': pdfPath,
      'outputDir': outputDir,
      if (password != null && password.isNotEmpty) 'password': password,
    });
    return result?.cast<String>() ?? [];
  }

  /// 压缩 PDF
  /// 对齐 PdfCompressor.kt:28-149
  Future<String?> compressPdf({
    required String sourcePath,
    required String outputPath,
    String? password,
    int dpi = 120,
    double jpegQuality = 0.72,
  }) async {
    return _channel.invokeMethod<String>('compressPdf', {
      'sourcePath': sourcePath,
      'outputPath': outputPath,
      if (password != null && password.isNotEmpty) 'password': password,
      'dpi': dpi,
      'jpegQuality': jpegQuality,
    });
  }

  /// 加密 PDF
  /// 对齐 PdfSecurityProcessor.kt:20-58
  Future<String?> encryptPdf({
    required String sourcePath,
    required String outputPath,
    required String password,
  }) async {
    return _channel.invokeMethod<String>('encryptPdf', {
      'sourcePath': sourcePath,
      'outputPath': outputPath,
      'password': password,
    });
  }
}
