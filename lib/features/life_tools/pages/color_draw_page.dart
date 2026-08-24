// ColorDrawFragment Flutter 版：简易画板。
// 排除 Android 中已注释的“跟图绘画”和“形状绘画”，保留画笔、橡皮擦、撤销/恢复、清除、保存。
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/constants/app_assets.dart';
import '../viewmodels/draw_state.dart';
import '../viewmodels/draw_view_model.dart';

class ColorDrawPage extends ConsumerStatefulWidget {
  const ColorDrawPage({super.key});

  static Future<void> push(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ColorDrawPage()),
      );

  @override
  ConsumerState<ColorDrawPage> createState() => _ColorDrawPageState();
}

class _ColorDrawPageState extends ConsumerState<ColorDrawPage> {
  final _canvasKey = GlobalKey();
  Path? _activePath;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(drawViewModelProvider);
    final vm = ref.read(drawViewModelProvider.notifier);
    return Scaffold(
      backgroundColor: const Color(0xFFEAE5FF),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 46, 20, 16),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border:
                        Border.all(color: const Color(0xFF352570), width: 5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 66),
                          child: _canvas(state, vm),
                        ),
                      ),
                      Positioned(
                        top: 20,
                        left: 0,
                        right: 0,
                        child: _topActions(state, vm),
                      ),
                      Positioned(
                        right: 10,
                        bottom: 12,
                        child: _sideActions(state, vm),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(top: 0, left: 0, right: 0, child: _topBar(context)),
          ],
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Text(
            '画板',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: Color(0xFF222222)),
          ),
          Positioned(
            right: 16,
            child: GestureDetector(
              onTap: _save,
              child:
                  Image.asset(AppAssets.colorDrawSave, width: 28, height: 28),
            ),
          ),
        ],
      ),
    );
  }

  Widget _canvas(DrawState state, DrawViewModel vm) {
    return RepaintBoundary(
      key: _canvasKey,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: (details) {
          _activePath = Path()
            ..moveTo(details.localPosition.dx, details.localPosition.dy);
          setState(() {});
        },
        onPanUpdate: (details) {
          final path = _activePath;
          if (path == null) return;
          path.lineTo(details.localPosition.dx, details.localPosition.dy);
          setState(() {});
        },
        onPanEnd: (_) {
          final path = _activePath;
          if (path != null) vm.addPath(path);
          setState(() => _activePath = null);
        },
        child: CustomPaint(
          painter: _ColorDrawPainter(
            paths: state.paths,
            activePath: _activePath,
            color: state.mode == DrawMode.draw
                ? state.penColor
                : Colors.transparent,
            width:
                state.mode == DrawMode.draw ? state.penSize : state.eraserSize,
            mode: state.mode,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }

  Widget _topActions(DrawState state, DrawViewModel vm) {
    final items = [
      _ActionItem(
          AppAssets.colorDrawPenSize, '画笔大小', () => _showSizeDialog(vm)),
      _ActionItem(
          AppAssets.colorDrawPencil, '铅笔', () => vm.setMode(DrawMode.draw)),
      _ActionItem(AppAssets.colorDrawUndo, '撤销', vm.undo),
      _ActionItem(AppAssets.colorDrawRedo, '恢复', vm.redo),
      _ActionItem(AppAssets.colorDrawClear, '一键清除', vm.clear),
    ];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
              color: Color(0x24000000), blurRadius: 2, offset: Offset(0, 1))
        ],
      ),
      child: Row(
          children:
              items.map((item) => Expanded(child: _action(item))).toList()),
    );
  }

  Widget _action(_ActionItem item) {
    return GestureDetector(
      onTap: item.onTap,
      child: SizedBox(
        height: 73,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(item.asset, width: 32, height: 32),
            const SizedBox(height: 4),
            Text(item.label,
                style: const TextStyle(fontSize: 10, color: Color(0xFF1E1E1E))),
          ],
        ),
      ),
    );
  }

  Widget _sideActions(DrawState state, DrawViewModel vm) {
    return Container(
      width: 50,
      height: 100,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
              color: Color(0x24000000), blurRadius: 2, offset: Offset(0, 1))
        ],
      ),
      child: Column(
        children: [
          Expanded(
              child: _sideItem(
                  AppAssets.colorDrawPen, '画笔', () => _pickColor(vm))),
          const SizedBox(height: 2),
          Expanded(
              child: _sideItem(AppAssets.colorDrawEraser, '橡皮擦',
                  () => vm.setMode(DrawMode.eraser))),
        ],
      ),
    );
  }

  Widget _sideItem(String asset, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(asset, width: 26, height: 26),
          Text(label,
              style: const TextStyle(fontSize: 10, color: Color(0xFF1E1E1E))),
        ],
      ),
    );
  }

  Future<void> _showSizeDialog(DrawViewModel vm) async {
    var size = ref.read(drawViewModelProvider).penSize.round().clamp(1, 30);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('画笔大小'),
        content: StatefulBuilder(
          builder: (_, setDialogState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$size'),
              Slider(
                  min: 1,
                  max: 30,
                  divisions: 29,
                  value: size.toDouble(),
                  onChanged: (v) => setDialogState(() => size = v.round())),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('取消')),
          FilledButton(
              onPressed: () {
                vm.setPenSize(size.toDouble());
                Navigator.pop(dialogContext);
              },
              child: const Text('确定')),
        ],
      ),
    );
  }

  Future<void> _pickColor(DrawViewModel vm) async {
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
    final selected = await showDialog<Color>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('画笔颜色'),
        content: Wrap(
          alignment: WrapAlignment.center,
          children: colors
              .map((c) => GestureDetector(
                    onTap: () => Navigator.pop(dialogContext, c),
                    child: Container(
                        width: 42,
                        height: 42,
                        margin: const EdgeInsets.all(7),
                        decoration:
                            BoxDecoration(color: c, shape: BoxShape.circle)),
                  ))
              .toList(),
        ),
      ),
    );
    if (selected != null) {
      vm.setPenColor(selected);
      vm.setMode(DrawMode.draw);
    }
  }

  Future<void> _save() async {
    final boundary =
        _canvasKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;
    final image = await boundary.toImage(pixelRatio: 2);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    if (data == null) {
      return;
    }
    final dir = await getApplicationDocumentsDirectory();
    final saveDir = Directory('${dir.path}/工具箱/简易画板');
    await saveDir.create(recursive: true);
    final file = File(
        '${saveDir.path}/Image-${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(data.buffer.asUint8List());
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('保存成功：${file.path}')));
    }
  }
}

class _ActionItem {
  const _ActionItem(this.asset, this.label, this.onTap);
  final String asset;
  final String label;
  final VoidCallback onTap;
}

class _ColorDrawPainter extends CustomPainter {
  const _ColorDrawPainter(
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
      final paint = Paint()
        ..color = info.paint.color
        ..strokeWidth = info.paint.strokeWidth
        ..blendMode = info.paint.blendMode
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(info.path, paint);
    }
    if (activePath != null) {
      final paint = Paint()
        ..color = color
        ..strokeWidth = width
        ..blendMode =
            mode == DrawMode.eraser ? ui.BlendMode.clear : ui.BlendMode.src
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(activePath!, paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ColorDrawPainter oldDelegate) => true;
}
