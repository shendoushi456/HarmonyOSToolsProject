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
  /// [widths]/[heights] 为 Flutter 侧解码得到的真实图片尺寸；
  /// [fileName] 为保存到下载/文档目录时的建议文件名。
  /// 原生侧生成 PDF 后会弹出系统保存位置选择器，用户取消时抛出
  /// code 为 PDF_SAVE_CANCELED 的 PlatformException。
  Future<String?> convertImagesToPdf({
    required List<String> imagePaths,
    required String outputPath,
    List<int> widths = const [],
    List<int> heights = const [],
    String fileName = '',
  }) async {
    return _channel.invokeMethod<String>('convertImagesToPdf', {
      'imagePaths': imagePaths,
      'outputPath': outputPath,
      'widths': widths,
      'heights': heights,
      'fileName': fileName,
    });
  }

  /// PDF 转图片。
  /// 使用 HarmonyOS PDFKit 的普通 convertToImage() 模式。
  /// PDF 转图片不处理加密 PDF，也不向原生侧传递密码。
  Future<List<String>> convertPdfToImages({
    required String pdfPath,
    required String outputDir,
  }) async {
    final result =
        await _channel.invokeMethod<List<dynamic>>('convertPdfToImages', {
      'pdfPath': pdfPath,
      'outputDir': outputDir,
    });
    return result?.cast<String>() ?? [];
  }

  /// 压缩 PDF
  /// 对齐 PdfCompressor.kt:28-149
  /// 原生流程：每页渲染 PNG → ImagePacker 重编码 JPEG(jpegQuality) → 重建 PDF，
  /// 成功后弹出系统保存位置选择器，用户取消时抛出 code 为 PDF_SAVE_CANCELED
  /// 的 PlatformException。
  Future<String?> compressPdf({
    required String sourcePath,
    required String outputPath,
    String? password,
    int dpi = 120,
    double jpegQuality = 0.75,
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
