import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

import '../../../scan_menu/services/document_export_service.dart';
import '../widgets/tool_top_bar.dart';

/// 离线涂鸦：点击封闭区域进行油漆桶填色（对齐 Android PaintActivity）。
class OfflineDrawPage extends StatefulWidget {
  const OfflineDrawPage({super.key, required this.background});
  final String background;

  static Future<void> push(BuildContext context, String background) =>
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => OfflineDrawPage(background: background)),
      );

  @override
  State<OfflineDrawPage> createState() => _OfflineDrawPageState();
}

class _OfflineDrawPageState extends State<OfflineDrawPage> {
  Uint8List? _initialBytes;
  Uint8List? _currentBytes;
  int _imageWidth = 1;
  int _imageHeight = 1;
  final _history = <Uint8List>[];
  final _redo = <Uint8List>[];
  Color _color = const Color(0xFFE53935);
  bool _loading = true;
  bool _filling = false;

  @override
  void initState() {
    super.initState();
    unawaited(_loadImage());
  }

  Future<void> _loadImage() async {
    try {
      final bytes =
          (await rootBundle.load(widget.background)).buffer.asUint8List();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) {
        throw StateError('图片解码失败');
      }
      // 统一为 PNG，避免 JPG 素材填色前后出现扩展名与实际编码不一致。
      final normalized = Uint8List.fromList(img.encodePng(decoded));
      if (mounted) {
        setState(() {
          _initialBytes = normalized;
          _currentBytes = Uint8List.fromList(normalized);
          _imageWidth = decoded.width;
          _imageHeight = decoded.height;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('图片加载失败：$e')));
      }
    }
  }

  Future<void> _fillAt(Offset local, Size viewport) async {
    final bytes = _currentBytes;
    if (bytes == null || _filling) return;
    final scale =
        (_imageWidth / viewport.width > _imageHeight / viewport.height)
            ? viewport.width / _imageWidth
            : viewport.height / _imageHeight;
    final displayed = Size(_imageWidth * scale, _imageHeight * scale);
    final left = (viewport.width - displayed.width) / 2;
    final top = (viewport.height - displayed.height) / 2;
    final x = ((local.dx - left) / scale).floor();
    final y = ((local.dy - top) / scale).floor();
    if (x < 0 || y < 0 || x >= _imageWidth || y >= _imageHeight) return;

    setState(() => _filling = true);
    try {
      final result = await compute(
        _fillImage,
        _FillRequest(
          bytes,
          _initialBytes!,
          x,
          y,
          // Flutter Color.r/g/b 为 0~1 浮点值；image 包需要 0~255 通道值。
          (_color.r * 255).round(),
          (_color.g * 255).round(),
          (_color.b * 255).round(),
        ),
      );
      if (!mounted) return;
      if (result == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('该位置不是可填充区域，请点击线稿内部')));
      } else {
        setState(() {
          _history.add(bytes);
          _currentBytes = result;
          _redo.clear();
        });
      }
    } finally {
      if (mounted) setState(() => _filling = false);
    }
  }

  void _undo() {
    if (_history.isEmpty || _filling) return;
    setState(() {
      _redo.add(_currentBytes!);
      _currentBytes = _history.removeLast();
    });
  }

  void _redoFill() {
    if (_redo.isEmpty || _filling) return;
    setState(() {
      _history.add(_currentBytes!);
      _currentBytes = _redo.removeLast();
    });
  }

  void _clear() {
    if (_initialBytes == null || _filling) return;
    setState(() {
      _history.add(_currentBytes!);
      _currentBytes = Uint8List.fromList(_initialBytes!);
      _redo.clear();
    });
  }

  Future<void> _save() async {
    final bytes = _currentBytes;
    if (bytes == null || _filling) return;
    try {
      await DocumentExportService().exportBytesToGallery(
        bytes,
        name: '离线涂鸦-${DateTime.now().millisecondsSinceEpoch}',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已保存到系统相册')),
        );
      }
    } on GalleryExportException catch (error) {
      if (mounted && !error.isCanceled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败：${error.message}')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败：$error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ToolTopBar(title: '涂鸦创作', actions: [
        IconButton(
            icon: const Icon(Icons.undo),
            onPressed: _history.isEmpty ? null : _undo),
        IconButton(
            icon: const Icon(Icons.redo),
            onPressed: _redo.isEmpty ? null : _redoFill),
        IconButton(icon: const Icon(Icons.save), onPressed: _save),
      ]),
      body: Column(children: [
        Expanded(
          child: LayoutBuilder(builder: (context, constraints) {
            final viewport = Size(constraints.maxWidth, constraints.maxHeight);
            return Stack(children: [
              Positioned.fill(
                child: Container(
                  color: Colors.white,
                  alignment: Alignment.center,
                  child: _loading
                      ? const CircularProgressIndicator()
                      : Image.memory(
                          _currentBytes!,
                          fit: BoxFit.contain,
                          // 解码新 PNG 时保留上一帧，避免每次填色出现白闪。
                          gaplessPlayback: true,
                        ),
                ),
              ),
              if (!_loading)
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapUp: (details) =>
                        _fillAt(details.localPosition, viewport),
                    child: const ColoredBox(color: Colors.transparent),
                  ),
                ),
              if (_filling)
                const Positioned(
                  top: 12,
                  right: 12,
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
            ]);
          }),
        ),
        const Padding(
          padding: EdgeInsets.only(bottom: 2),
          child: Text('选择颜色后再次点击区域，可重新填色',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
        ),
        _Tools(
            color: _color,
            onColor: (c) => setState(() => _color = c),
            onClear: _clear),
      ]),
    );
  }
}

class _Tools extends StatelessWidget {
  const _Tools(
      {required this.color, required this.onColor, required this.onClear});
  final Color color;
  final ValueChanged<Color> onColor;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    const colors = [
      Colors.black,
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.purple,
      Colors.pink
    ];
    return SizedBox(
      height: 76,
      child: Row(children: [
        Expanded(
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: colors
                .map((c) => GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onColor(c),
                      child: Container(
                        width: 46,
                        height: 46,
                        margin: const EdgeInsets.all(8),
                        alignment: Alignment.center,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                              color: c,
                              shape: BoxShape.circle,
                              border: c == color
                                  ? Border.all(width: 3, color: Colors.black54)
                                  : null),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
        IconButton(
            tooltip: '恢复原图',
            icon: const Icon(Icons.delete_outline),
            onPressed: onClear),
      ]),
    );
  }
}

class _FillRequest {
  const _FillRequest(
      this.bytes, this.originalBytes, this.x, this.y, this.r, this.g, this.b);
  final Uint8List bytes;
  final Uint8List originalBytes;
  final int x, y, r, g, b;
}

/// 在 isolate 中执行 Flood Fill，避免大图操作阻塞 UI。
Uint8List? _fillImage(_FillRequest request) {
  final image = img.decodeImage(request.bytes);
  final original = img.decodeImage(request.originalBytes);
  if (image == null || original == null) {
    return null;
  }
  final x0 = request.x, y0 = request.y;
  final originalTarget = original.getPixel(x0, y0);
  final originalIsBoundary = originalTarget.r.toInt() < 100 &&
      originalTarget.g.toInt() < 100 &&
      originalTarget.b.toInt() < 100;
  if (originalIsBoundary) {
    return null;
  }
  // 区域身份始终依据原始线稿判断，当前颜色只负责输出。这样同一区域
  // 在已经填过一次后，选择新颜色仍然可以再次填充。
  final tr = originalTarget.r.toInt(),
      tg = originalTarget.g.toInt(),
      tb = originalTarget.b.toInt();
  if ((tr - request.r).abs() < 4 &&
      (tg - request.g).abs() < 4 &&
      (tb - request.b).abs() < 4) {
    return request.bytes;
  }

  const tolerance = 24;
  bool matches(int x, int y) {
    final source = original.getPixel(x, y);
    final isBoundary = source.r.toInt() < 100 &&
        source.g.toInt() < 100 &&
        source.b.toInt() < 100;
    return !isBoundary &&
        (source.r.toInt() - tr).abs() <= tolerance &&
        (source.g.toInt() - tg).abs() <= tolerance &&
        (source.b.toInt() - tb).abs() <= tolerance;
  }

  final visited = Uint8List(image.width * image.height);
  final queue = <int>[y0 * image.width + x0];
  var head = 0;
  while (head < queue.length) {
    final index = queue[head++];
    if (visited[index] != 0) continue;
    visited[index] = 1;
    final x = index % image.width, y = index ~/ image.width;
    if (!matches(x, y)) continue;
    final pixel = image.getPixel(x, y);
    image.setPixelRgba(x, y, request.r, request.g, request.b, pixel.a.toInt());
    if (x > 0) queue.add(index - 1);
    if (x + 1 < image.width) queue.add(index + 1);
    if (y > 0) queue.add(index - image.width);
    if (y + 1 < image.height) queue.add(index + image.width);
  }
  return Uint8List.fromList(img.encodePng(image));
}
