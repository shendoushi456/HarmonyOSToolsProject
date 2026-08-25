import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:image/image.dart' as image;

/// 处理裁剪和水印，避免将像素处理逻辑耦合进页面。
class DocumentImageService {
  Future<File> crop(
    File source, {
    required double leftRatio,
    required double topRatio,
    required double widthRatio,
    required double heightRatio,
  }) async {
    final bytes = await source.readAsBytes();
    final decoded = image.decodeImage(bytes);
    if (decoded == null) throw StateError('无法读取图片');

    final left =
        (decoded.width * leftRatio).round().clamp(0, decoded.width - 1) as int;
    final top =
        (decoded.height * topRatio).round().clamp(0, decoded.height - 1) as int;
    final width = (decoded.width * widthRatio)
        .round()
        .clamp(1, decoded.width - left) as int;
    final height = (decoded.height * heightRatio)
        .round()
        .clamp(1, decoded.height - top) as int;
    final cropped =
        image.copyCrop(decoded, x: left, y: top, width: width, height: height);
    return _writePng(source, image.encodePng(cropped), 'crop');
  }

  Future<File> addWatermark(File source, String text) async {
    final bytes = await source.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final sourceImage = frame.image;
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    canvas.drawImage(sourceImage, ui.Offset.zero, ui.Paint());

    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: ui.Color(0x66FFFFFF), fontSize: 22),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    final stepX = painter.width + 80;
    const stepY = 110.0;
    for (var y = -stepY; y < sourceImage.height; y += stepY) {
      for (var x = -stepX; x < sourceImage.width; x += stepX) {
        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(-0.45);
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
    return _writePng(source, data.buffer.asUint8List(), 'watermark');
  }

  Future<File> _writePng(File source, Uint8List data, String suffix) async {
    final output = File(
        '${source.parent.path}/${DateTime.now().microsecondsSinceEpoch}_$suffix.png');
    await output.writeAsBytes(data, flush: true);
    return output;
  }
}
