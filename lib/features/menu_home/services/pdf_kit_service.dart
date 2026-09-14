import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../../../core/network/pdf_kit_native_channel.dart';

/// 压缩 PDF 结果：保存位置 + 压缩后文件大小。
/// 文件保存在用户通过系统保存选择器确认的公共目录（Dart 无法直接读 uri，
/// 大小取沙箱中间产物，内容与导出文件一致）。
class PdfCompressResult {
  final String savedUri;
  final int outputBytes;
  const PdfCompressResult(this.savedUri, this.outputBytes);
}

/// PDF Kit 业务 Service - 对齐 Android pic_toolslibrary/pdf/PdfFileUtils
/// 封装原生通道调用 + 输出路径构造
class PdfKitService {
  final PdfKitNativeChannel _channel = PdfKitNativeChannel.instance;

  /// 图片转 PDF
  /// 对齐 ImageToPdfProcessor.kt:20-103
  /// 返回值为原生侧用户通过系统保存选择器确认的位置（下载/文档等公共目录）。
  /// 用户取消保存时抛出 code 为 PDF_SAVE_CANCELED 的 PlatformException。
  Future<String> convertImagesToPdf(
    List<String> imagePaths, {
    List<int> widths = const [],
    List<int> heights = const [],
    String fileName = '',
  }) async {
    // 沙箱内仅作为中间产物；最终 PDF 通过 DocumentSavePicker 导出到公共目录
    final cacheDir = await getTemporaryDirectory();
    final outputPath =
        '${cacheDir.path}/images_to_pdf_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final result = await _channel.convertImagesToPdf(
      imagePaths: imagePaths,
      outputPath: outputPath,
      widths: widths,
      heights: heights,
      fileName: fileName,
    );
    if (result == null || result.isEmpty) {
      throw Exception('图片转 PDF 失败');
    }
    return result;
  }

  /// PDF 转图片。
  /// 输出目录每次使用独立临时目录，避免混入上一次转换的图片。
  Future<List<String>> convertPdfToImages(String pdfPath) async {
    final cacheDir = await getTemporaryDirectory();
    final outputDir =
        '${cacheDir.path}/pdf_to_images_${DateTime.now().millisecondsSinceEpoch}';
    await Directory(outputDir).create(recursive: true);
    return _channel.convertPdfToImages(
      pdfPath: pdfPath,
      outputDir: outputDir,
    );
  }

  /// 压缩 PDF
  /// 对齐 PdfCompressor.kt:28-149
  /// 用户取消保存时抛出 code 为 PDF_SAVE_CANCELED 的 PlatformException。
  Future<PdfCompressResult> compressPdf(String sourcePath, {String? password}) async {
    // 沙箱内仅作为中间产物；最终压缩 PDF 通过保存选择器导出到公共目录
    final cacheDir = await getTemporaryDirectory();
    final outputPath =
        '${cacheDir.path}/compressed_pdf_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final result = await _channel.compressPdf(
      sourcePath: sourcePath,
      outputPath: outputPath,
      password: password,
    );
    if (result == null || result.isEmpty) {
      throw Exception('压缩 PDF 失败');
    }
    final outputBytes = await File(outputPath).length();
    return PdfCompressResult(result, outputBytes);
  }

  /// 加密 PDF
  /// 对齐 PdfSecurityProcessor.kt:20-58
  /// 返回值为原生侧用户通过系统保存选择器确认的位置（下载/文档等公共目录）。
  /// 用户取消保存时抛出 code 为 PDF_SAVE_CANCELED 的 PlatformException。
  Future<String> encryptPdf(
      String sourcePath, String originalName, String password) async {
    // 沙箱内仅作为中间产物；最终加密 PDF 通过 DocumentSavePicker 导出到公共目录
    final cacheDir = await getTemporaryDirectory();
    final timestamp = _formatTimestamp(DateTime.now());
    String fileName;
    if (originalName.contains('.')) {
      final idx = originalName.lastIndexOf('.');
      final name = originalName.substring(0, idx);
      final ext = originalName.substring(idx);
      fileName = 'encrypted_${name}_$timestamp$ext';
    } else {
      fileName = 'encrypted_${originalName}_$timestamp.pdf';
    }
    final outputPath = '${cacheDir.path}/$fileName';
    final result = await _channel.encryptPdf(
      sourcePath: sourcePath,
      outputPath: outputPath,
      password: password,
    );
    if (result == null || result.isEmpty) {
      throw Exception('加密 PDF 失败');
    }
    return result;
  }

  String _formatTimestamp(DateTime dt) {
    final y = dt.year.toString();
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$y$m${d}_$h$min$s';
  }
}
