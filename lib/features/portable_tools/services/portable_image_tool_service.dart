import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:image/image.dart' as image;
import 'package:path_provider/path_provider.dart';

/// 便携工具图像能力：像素化、水印和应用文档目录保存。
class PortableImageToolService {
  Future<Uint8List> pixelate(File source, {required int blockSize}) async {
    final decoded = image.decodeImage(await source.readAsBytes());
    if (decoded == null) throw StateError('无法读取图片');
    final maxSide =
        decoded.width > decoded.height ? decoded.width : decoded.height;
    final scaled = maxSide > 1800
        ? image.copyResize(decoded,
            width: decoded.width * 1800 ~/ maxSide,
            height: decoded.height * 1800 ~/ maxSide)
        : decoded;
    final small = image.copyResize(scaled,
        width: (scaled.width / blockSize).ceil().clamp(1, scaled.width),
        height: (scaled.height / blockSize).ceil().clamp(1, scaled.height),
        interpolation: image.Interpolation.nearest);
    final pixelated = image.copyResize(small,
        width: scaled.width,
        height: scaled.height,
        interpolation: image.Interpolation.nearest);
    return Uint8List.fromList(image.encodePng(pixelated));
  }

  Future<Uint8List> addWatermark(
    File source, {
    required String text,
    required int color,
    required int alpha,
    required double fontSize,
    required double angle,
    required int spacing,
  }) async {
    final codec = await ui.instantiateImageCodec(await source.readAsBytes());
    final sourceImage = (await codec.getNextFrame()).image;
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder)
      ..drawImage(sourceImage, ui.Offset.zero, ui.Paint());
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: ui.Color(color).withAlpha(alpha.clamp(0, 255)),
          fontSize: fontSize,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    final stepX = painter.width + spacing.toDouble();
    final stepY = painter.height + spacing.toDouble();
    for (var y = -stepY; y < sourceImage.height; y += stepY) {
      for (var x = -stepX; x < sourceImage.width; x += stepX) {
        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(angle);
        painter.paint(canvas, ui.Offset.zero);
        canvas.restore();
      }
    }
    final result = await recorder
        .endRecording()
        .toImage(sourceImage.width, sourceImage.height);
    final data = await result.toByteData(format: ui.ImageByteFormat.png);
    sourceImage.dispose();
    result.dispose();
    if (data == null) throw StateError('生成水印失败');
    return data.buffer.asUint8List();
  }

  Future<File> savePng(Uint8List bytes,
      {required String directoryName, required String prefix}) async {
    final documents = await getApplicationDocumentsDirectory();
    final directory = Directory('${documents.path}/$directoryName');
    await directory.create(recursive: true);
    final output = File(
        '${directory.path}/$prefix${DateTime.now().millisecondsSinceEpoch}.png');
    await output.writeAsBytes(bytes, flush: true);
    return output;
  }
}
