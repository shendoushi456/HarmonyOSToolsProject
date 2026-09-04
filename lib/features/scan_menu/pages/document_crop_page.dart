import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../services/document_image_service.dart';

/// 对齐 Android UCrop 默认界面：
///   工具栏 + 带 9 宫格 / 4 角控点的裁剪框 + 底部 [取消 / 完成] 操作栏。
///
/// 自由比例裁剪 (`setFreeStyleCropEnabled(true)`)，行为与 Android
/// `withMaxResultSize(800, 800)` 默认保持一致，但允许用户拖动四角与中部
/// 自由调整。
class DocumentCropPage extends StatefulWidget {
  const DocumentCropPage({super.key, required this.file});
  final File file;

  @override
  State<DocumentCropPage> createState() => _DocumentCropPageState();
}

class _DocumentCropPageState extends State<DocumentCropPage> {
  ui.Image? _decoded;
  Object? _decodeError;

  Size? _lastBoxSize; // 上次 LayoutBuilder 的尺寸，避免重置裁剪框
  Rect _imageRect = Rect.zero; // 图片在视口中的实际绘制区域
  Rect _cropRect = Rect.zero; // 当前裁剪框
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      final bytes = await widget.file.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      if (!mounted) return;
      setState(() => _decoded = frame.image);
    } catch (error) {
      if (!mounted) return;
      setState(() => _decodeError = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildToolbar(),
            Expanded(
              child: LayoutBuilder(builder: (context, box) {
                if (_decoded == null) {
                  return Center(
                    child: _decodeError != null
                        ? const Text('图片加载失败',
                            style: TextStyle(color: Colors.white))
                        : const CircularProgressIndicator(color: Colors.white),
                  );
                }
                // 仅在 BoxFit 容器尺寸变化时重新计算目标矩形，避免拖拽重置裁剪框
                if (_lastBoxSize != box.biggest || _imageRect.isEmpty) {
                  _lastBoxSize = box.biggest;
                  _imageRect = _computeContainRect(_decoded!, box.biggest);
                  _cropRect = _initialCropRect(_imageRect);
                }
                return _buildCropStage(_imageRect, _cropRect);
              }),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildToolbar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(50),
      child: Container(
        color: const Color(0xFF168EC6),
        height: 50,
        child: Stack(
          children: [
            const Center(
              child: Text(
                '图片裁剪',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                tooltip: '返回',
                onPressed: () => Navigator.maybePop(context),
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCropStage(Rect imageRect, Rect cropRect) {
    return Stack(
      children: [
        // 原图
        Positioned.fromRect(
          rect: imageRect,
          child: RawImage(image: _decoded, fit: BoxFit.fill),
        ),
        // 裁剪层(暗色遮罩 + 网格 + 4 角控点 + 拖拽手势)
        Positioned.fill(
          child: _CropLayer(
            imageRect: imageRect,
            cropRect: cropRect,
            onChanged: (next) => setState(() => _cropRect = next),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      color: const Color(0xFF202020),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.maybePop(context),
              child: Container(
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white24),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Text(
                  '取消',
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: GestureDetector(
              onTap: _saving ? null : _confirm,
              child: Container(
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF168EC6),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Text(
                  _saving ? '处理中...' : '完成',
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// BoxFit.contain 目标矩形计算，与 Flutter Image widget 内部逻辑一致。
  Rect _computeContainRect(ui.Image image, Size box) {
    if (box.isEmpty) return Rect.zero;
    final imgW = image.width.toDouble();
    final imgH = image.height.toDouble();
    final scale =
        imgW / imgH > box.width / box.height ? box.width / imgW : box.height / imgH;
    final drawW = imgW * scale;
    final drawH = imgH * scale;
    final left = (box.width - drawW) / 2;
    final top = (box.height - drawH) / 2;
    return Rect.fromLTWH(left, top, drawW, drawH);
  }

  Rect _initialCropRect(Rect imageRect) {
    final inset = imageRect.width * 0.1;
    return Rect.fromLTRB(
      imageRect.left + inset,
      imageRect.top + imageRect.height * 0.1,
      imageRect.right - inset,
      imageRect.bottom - imageRect.height * 0.1,
    );
  }

  Future<void> _confirm() async {
    if (_imageRect.isEmpty) return;
    final leftRatio = (_cropRect.left - _imageRect.left) / _imageRect.width;
    final topRatio = (_cropRect.top - _imageRect.top) / _imageRect.height;
    final widthRatio = _cropRect.width / _imageRect.width;
    final heightRatio = _cropRect.height / _imageRect.height;
    if (widthRatio <= 0.05 || heightRatio <= 0.05) return;
    setState(() => _saving = true);
    try {
      final file = await DocumentImageService().crop(
        widget.file,
        leftRatio: leftRatio,
        topRatio: topRatio,
        widthRatio: widthRatio,
        heightRatio: heightRatio,
      );
      if (mounted) Navigator.pop(context, file);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('裁剪失败，请重试')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

/// 裁剪层：暗色遮罩 + 裁剪框 + 9 宫格 + 4 角控点 + 拖拽手势。
class _CropLayer extends StatelessWidget {
  const _CropLayer({
    required this.imageRect,
    required this.cropRect,
    required this.onChanged,
  });

  final Rect imageRect;
  final Rect cropRect;
  final ValueChanged<Rect> onChanged;

  static const _handleSize = 28.0;
  static const _minCropSide = 60.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanUpdate: (details) {
        final next = _clamp(cropRect.shift(details.delta), imageRect);
        onChanged(next);
      },
      child: CustomPaint(
        size: Size.infinite,
        painter: _CropPainter(
          imageRect: imageRect,
          cropRect: cropRect,
          handleSize: _handleSize,
        ),
        child: Stack(
          children: [
            _cornerHandle(
              _Corner.topLeft,
              onDrag: (delta) =>
                  onChanged(_resize(_Corner.topLeft, delta, imageRect)),
            ),
            _cornerHandle(
              _Corner.topRight,
              onDrag: (delta) =>
                  onChanged(_resize(_Corner.topRight, delta, imageRect)),
            ),
            _cornerHandle(
              _Corner.bottomLeft,
              onDrag: (delta) =>
                  onChanged(_resize(_Corner.bottomLeft, delta, imageRect)),
            ),
            _cornerHandle(
              _Corner.bottomRight,
              onDrag: (delta) =>
                  onChanged(_resize(_Corner.bottomRight, delta, imageRect)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cornerHandle(_Corner corner,
      {required ValueChanged<Offset> onDrag}) {
    final dx = _cornerX(corner, cropRect);
    final dy = _cornerY(corner, cropRect);
    return Positioned(
      left: dx,
      top: dy,
      width: _handleSize,
      height: _handleSize,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: (details) => onDrag(details.delta),
        child: ColoredBox(
          color: Colors.transparent,
          child: Align(
            alignment: _cornerAlign(corner),
            child: Container(
              width: 14,
              height: 14,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _cornerX(_Corner corner, Rect r) {
    if (corner == _Corner.topLeft || corner == _Corner.bottomLeft) {
      return r.left - _handleSize / 2;
    }
    return r.right - _handleSize / 2;
  }

  double _cornerY(_Corner corner, Rect r) {
    if (corner == _Corner.topLeft || corner == _Corner.topRight) {
      return r.top - _handleSize / 2;
    }
    return r.bottom - _handleSize / 2;
  }

  Alignment _cornerAlign(_Corner corner) {
    if (corner == _Corner.topLeft) return Alignment.bottomRight;
    if (corner == _Corner.topRight) return Alignment.bottomLeft;
    if (corner == _Corner.bottomLeft) return Alignment.topRight;
    return Alignment.topLeft;
  }

  Rect _resize(_Corner corner, Offset delta, Rect image) {
    Rect r = cropRect;
    if (corner == _Corner.topLeft) {
      r = Rect.fromLTRB(
        r.left + delta.dx,
        r.top + delta.dy,
        r.right,
        r.bottom,
      );
    } else if (corner == _Corner.topRight) {
      r = Rect.fromLTRB(
        r.left,
        r.top + delta.dy,
        r.right + delta.dx,
        r.bottom,
      );
    } else if (corner == _Corner.bottomLeft) {
      r = Rect.fromLTRB(
        r.left + delta.dx,
        r.top,
        r.right,
        r.bottom + delta.dy,
      );
    } else {
      r = Rect.fromLTRB(
        r.left,
        r.top,
        r.right + delta.dx,
        r.bottom + delta.dy,
      );
    }
    return _clamp(r, image);
  }

  Rect _clamp(Rect r, Rect image) {
    const minSide = _minCropSide;
    var l = r.left;
    var t = r.top;
    var rr = r.right;
    var bb = r.bottom;
    if (rr - l < minSide) {
      rr = l + minSide;
    }
    if (bb - t < minSide) {
      bb = t + minSide;
    }
    if (l < image.left) {
      final dx = image.left - l;
      l += dx;
      rr += dx;
    }
    if (rr > image.right) {
      final dx = rr - image.right;
      l -= dx;
      rr -= dx;
    }
    if (t < image.top) {
      final dy = image.top - t;
      t += dy;
      bb += dy;
    }
    if (bb > image.bottom) {
      final dy = bb - image.bottom;
      t -= dy;
      bb -= dy;
    }
    return Rect.fromLTRB(l, t, rr, bb);
  }
}

enum _Corner { topLeft, topRight, bottomLeft, bottomRight }

/// 绘制：图片外的暗色遮罩 + 裁剪框白边 + 9 宫格分割线 + 4 个角的加粗白线。
class _CropPainter extends CustomPainter {
  _CropPainter({
    required this.imageRect,
    required this.cropRect,
    required this.handleSize,
  });

  final Rect imageRect;
  final Rect cropRect;
  final double handleSize;

  @override
  void paint(Canvas canvas, Size size) {
    // 1) 整张暗色遮罩
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0x99000000),
    );

    // 2) 在 imageRect 内裁剪框以外的区域保持更暗
    canvas.drawRect(
      imageRect,
      Paint()..color = const Color(0xCC000000),
    );

    // 3) 裁剪框内部挖空(clear)
    canvas.drawRect(
      cropRect,
      Paint()..blendMode = BlendMode.clear,
    );

    // 4) 白边
    final border = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(cropRect, border);

    // 5) 9 宫格分割线(对齐 UCrop setShowCropGrid(true))
    final grid = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..strokeWidth = 1;
    final w = cropRect.width / 3;
    final h = cropRect.height / 3;
    for (var i = 1; i < 3; i++) {
      final dx = cropRect.left + w * i;
      canvas.drawLine(
        Offset(dx, cropRect.top),
        Offset(dx, cropRect.bottom),
        grid,
      );
    }
    for (var i = 1; i < 3; i++) {
      final dy = cropRect.top + h * i;
      canvas.drawLine(
        Offset(cropRect.left, dy),
        Offset(cropRect.right, dy),
        grid,
      );
    }

    // 6) 4 个角的加粗白线(对应 UCrop 角控点视觉)
    final cornerPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.square;
    final cs = handleSize / 2;
    void drawCorner(Offset c, Offset hDir, Offset vDir) {
      canvas.drawLine(c, c + hDir * cs, cornerPaint);
      canvas.drawLine(c, c + vDir * cs, cornerPaint);
    }

    drawCorner(cropRect.topLeft, const Offset(1, 0), const Offset(0, 1));
    drawCorner(cropRect.topRight, const Offset(-1, 0), const Offset(0, 1));
    drawCorner(cropRect.bottomLeft, const Offset(1, 0), const Offset(0, -1));
    drawCorner(cropRect.bottomRight, const Offset(-1, 0), const Offset(0, -1));
  }

  @override
  bool shouldRepaint(covariant _CropPainter old) =>
      old.imageRect != imageRect || old.cropRect != cropRect;
}