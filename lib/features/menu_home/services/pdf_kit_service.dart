import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../../../core/network/pdf_kit_native_channel.dart';

/// PDF Kit 业务 Service - 对齐 Android pic_toolslibrary/pdf/PdfFileUtils
/// 封装原生通道调用 + 输出路径构造
class PdfKitService {
  final PdfKitNativeChannel _channel = PdfKitNativeChannel.instance;

  /// 输出目录：应用文档目录/Documents/ALL IN ONE PDF/
  Future<String> _outputDir() async {
    final docDir = await getApplicationDocumentsDirectory();
    final dir = '${docDir.path}/Documents/ALL IN ONE PDF';
    await Directory(dir).create(recursive: true);
    return dir;
  }

  /// 图片转 PDF
  /// 对齐 ImageToPdfProcessor.kt:20-103
  Future<String> convertImagesToPdf(List<String> imagePaths) async {
    final dir = await _outputDir();
    final outputPath = '$dir/images_to_pdf_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final result = await _channel.convertImagesToPdf(
      imagePaths: imagePaths,
      outputPath: outputPath,
    );
    if (result == null || result.isEmpty) {
      throw Exception('图片转 PDF 失败');
    }
    return result;
  }

  /// PDF 转图片
  /// 对齐 PdfToImageProcessor.kt:17-96
  Future<List<String>> convertPdfToImages(String pdfPath, {String? password}) async {
    final cacheDir = await getTemporaryDirectory();
    final outputDir = '${cacheDir.path}/pdf_to_images_${DateTime.now().millisecondsSinceEpoch}';
    await Directory(outputDir).create(recursive: true);
    return _channel.convertPdfToImages(
      pdfPath: pdfPath,
      outputDir: outputDir,
      password: password,
    );
  }

  /// 压缩 PDF
  /// 对齐 PdfCompressor.kt:28-149
  Future<String> compressPdf(String sourcePath, {String? password}) async {
    final dir = await _outputDir();
    final outputPath = '$dir/compressed_pdf_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final result = await _channel.compressPdf(
      sourcePath: sourcePath,
      outputPath: outputPath,
      password: password,
    );
    if (result == null || result.isEmpty) {
      throw Exception('压缩 PDF 失败');
    }
    return result;
  }

  /// 加密 PDF
  /// 对齐 PdfSecurityProcessor.kt:20-58
  Future<String> encryptPdf(String sourcePath, String originalName, String password) async {
    final dir = await _outputDir();
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
    final outputPath = '$dir/$fileName';
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
