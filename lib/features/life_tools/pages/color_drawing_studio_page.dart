// ColorDrawFragment 的“跟图绘画 / 形状绘画”迁移版。
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/draw_state.dart';
import '../viewmodels/draw_view_model.dart';
import '../../scan_menu/services/document_export_service.dart';

enum ColorDrawingMode { trace, shape }

class ColorDrawingStudioPage extends ConsumerStatefulWidget {
  const ColorDrawingStudioPage({super.key, required this.mode});
  final ColorDrawingMode mode;

  static Future<void> push(BuildContext context, ColorDrawingMode mode) =>
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ColorDrawingStudioPage(mode: mode)),
      );

  @override
  ConsumerState<ColorDrawingStudioPage> createState() =>
      _ColorDrawingStudioPageState();
}

class _ColorDrawingStudioPageState
    extends ConsumerState<ColorDrawingStudioPage> {
  final _canvasKey = GlobalKey();
  Path? _activePath;
  int _selectedGuide = 0;
  int _selectedColor = 0;
  double _brushSize = 5;

  String get _title => widget.mode == ColorDrawingMode.trace ? '跟图绘画' : '形状绘画';
  List<String> get _guides => widget.mode == ColorDrawingMode.trace
      ? List.generate(
          6, (i) => 'assets/images/color_draw/trace/iv_gen_${i + 1}.png')
      : List.generate(
          6, (i) => 'assets/images/color_draw/shapes/iv_shape_${i + 1}.png');

  @override
  void initState() {
    super.initState();
    // Drawing3Activity 每次进入都会创建新的 PaintView，迁移版同样以空画布开始。
    ref.read(drawViewModelProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(drawViewModelProvider);
    final vm = ref.read(drawViewModelProvider.notifier);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Stack(children: [
          Positioned.fill(child: _canvas(state, vm)),
          Positioned(top: 0, left: 0, right: 0, child: _header()),
          Positioned(top: 52, left: 14, right: 14, child: _guideStrip()),
          Positioned(right: 20, bottom: 106, child: _quickActions(vm)),
          Positioned(left: 14, right: 14, bottom: 20, child: _colorStrip(vm)),
        ]),
      ),
    );
  }

  Widget _header() => SizedBox(
        height: 40,
        child: Stack(alignment: Alignment.center, children: [
          Positioned(
              left: 4,
              child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  onPressed: () => Navigator.maybePop(context))),
          Text(_title,
              style: const TextStyle(fontSize: 16, color: Color(0xFF111111))),
        ]),
      );

  Widget _guideStrip() => SizedBox(
        height: 72,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _guides.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (_, index) => GestureDetector(
            onTap: () => setState(() => _selectedGuide = index),
            child: Container(
              width: 66,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                    color: index == _selectedGuide
                        ? const Color(0xFF352570)
                        : Colors.transparent,
                    width: 2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: ColoredBox(
                color: const Color(0xFFFFFFFF),
                child: Image.asset(
                  _guides[index],
                  fit: BoxFit.contain,
                  // Android 跟图素材为白线透明图，预览必须使用深色底色。
                  errorBuilder: (_, error, __) => const Icon(
                    Icons.broken_image_outlined,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  Widget _canvas(DrawState state, DrawViewModel vm) => RepaintBoundary(
        key: _canvasKey,
        child: Stack(children: [
          Positioned.fill(
            child: IgnorePointer(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 145, 18, 95),
                child: ColoredBox(
                  color: const Color(0xFFF5F6FA),
                  child: Image.asset(
                    _guides[_selectedGuide],
                    fit: BoxFit.contain,
                    errorBuilder: (_, error, __) => const Center(
                      child:
                          Text('模板加载失败', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanStart: (event) {
                _activePath = Path()
                  ..moveTo(event.localPosition.dx, event.localPosition.dy);
                setState(() {});
              },
              onPanUpdate: (event) {
                _activePath?.lineTo(
                    event.localPosition.dx, event.localPosition.dy);
                setState(() {});
              },
              onPanEnd: (_) {
                final path = _activePath;
                if (path != null) vm.addPath(path);
                setState(() => _activePath = null);
              },
              child: CustomPaint(
                painter: _StudioPainter(
                  paths: state.paths,
                  activePath: _activePath,
                  color: state.penColor,
                  width: state.mode == DrawMode.draw
                      ? state.penSize
                      : state.eraserSize,
                  mode: state.mode,
                ),
                size: Size.infinite,
              ),
            ),
          ),
        ]),
      );

  Widget _quickActions(DrawViewModel vm) => Row(children: [
        _circleAction(Icons.undo, vm.undo),
        const SizedBox(width: 16),
        _circleAction(Icons.redo, vm.redo),
        const SizedBox(width: 16),
        _circleAction(Icons.delete_outline, vm.clear),
        const SizedBox(width: 16),
        _circleAction(Icons.save_outlined, _save),
      ]);

  Widget _circleAction(IconData icon, VoidCallback callback) => Material(
        color: Colors.white,
        shape: const CircleBorder(),
        elevation: 2,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: callback,
          child: Padding(
              padding: const EdgeInsets.all(10),
              child: Icon(icon, size: 20, color: const Color(0xFF352570))),
        ),
      );

  Widget _colorStrip(DrawViewModel vm) {
    const colors = [
      Color(0xFF000000),
      Color(0xFFFFFFFF),
      Color(0xFFF53131),
      Color(0xFFF531BB),
      Color(0xFFC031F5),
      Color(0xFF7B31F5),
      Color(0xFF313AF5),
      Color(0xFF3196F5),
      Color(0xFF31E0F5),
      Color(0xFF31F5BB),
      Color(0xFF31F57F),
      Color(0xFF36F531),
      Color(0xFFA4F531),
      Color(0xFFEEF531),
      Color(0xFFF5C531),
      Color(0xFFF58931)
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(color: Color(0x22000000), blurRadius: 4)
          ]),
      child: Row(children: [
        IconButton(
            icon: const Icon(Icons.line_weight, color: Color(0xFF352570)),
            onPressed: () => _chooseSize(vm)),
        Expanded(
            child: SizedBox(
                height: 33,
                child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: colors.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 7),
                    itemBuilder: (_, index) => GestureDetector(
                        onTap: () {
                          setState(() => _selectedColor = index);
                          vm.setPenColor(colors[index]);
                          vm.setMode(DrawMode.draw);
                        },
                        child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                                color: colors[index],
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: index == _selectedColor
                                        ? const Color(0xFF352570)
                                        : const Color(0x33000000),
                                    width:
                                        index == _selectedColor ? 3 : 1))))))),
      ]),
    );
  }

  Future<void> _chooseSize(DrawViewModel vm) async {
    await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
                title: const Text('画笔大小'),
                content: StatefulBuilder(
                    builder: (_, refresh) => Slider(
                        min: 2,
                        max: 30,
                        divisions: 14,
                        value: _brushSize,
                        label: _brushSize.round().toString(),
                        onChanged: (value) =>
                            refresh(() => _brushSize = value))),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('取消')),
                  FilledButton(
                      onPressed: () {
                        vm.setPenSize(_brushSize);
                        Navigator.pop(ctx);
                      },
                      child: const Text('确定'))
                ]));
  }

  Future<void> _save() async {
    final boundary =
        _canvasKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      return;
    }
    final image = await boundary.toImage(pixelRatio: 2);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    if (data == null) {
      return;
    }
    try {
      await DocumentExportService().exportBytesToGallery(
        data.buffer.asUint8List(),
        name: '$_title-${DateTime.now().millisecondsSinceEpoch}',
      );
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('已保存到系统相册')));
      }
    } on GalleryExportException catch (error) {
      if (mounted && !error.isCanceled) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('保存失败：${error.message}')));
      }
    }
  }
}

class _StudioPainter extends CustomPainter {
  const _StudioPainter(
      {required this.paths,
      required this.activePath,
      required this.color,
      required this.width,
      required this.mode});
  final List<PathDrawingInfo> paths;
  final Path? activePath;
  final Color color;
  final double width;
  final DrawMode mode;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Offset.zero & size, Paint());
    for (final info in paths) {
      _draw(canvas, info.path, info.paint.color, info.paint.strokeWidth,
          info.paint.blendMode);
    }
    if (activePath != null) {
      _draw(canvas, activePath!, color, width,
          mode == DrawMode.eraser ? ui.BlendMode.clear : ui.BlendMode.src);
    }
    canvas.restore();
  }

  void _draw(Canvas canvas, Path path, Color color, double width,
          ui.BlendMode blendMode) =>
      canvas.drawPath(
          path,
          Paint()
            ..color = color
            ..strokeWidth = width
            ..blendMode = blendMode
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round);
  @override
  bool shouldRepaint(covariant _StudioPainter oldDelegate) => true;
}
