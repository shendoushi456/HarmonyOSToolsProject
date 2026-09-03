// 画板页 - 对齐 Android DrawActivity.java + activity_lib_draw_tool.xml
// 顶栏"画板" + 菜单(笔粗/颜色/保存) + CustomPaint + 底部 5 个按钮(撤销/重做/画笔/橡皮擦/清除)
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui' as ui;
import '../../viewmodels/draw_state.dart';
import '../../viewmodels/draw_view_model.dart';
import '../widgets/tool_top_bar.dart';
import 'widgets/palette_painter.dart';
import '../../../scan_menu/services/document_export_service.dart';

class DrawPage extends ConsumerStatefulWidget {
  const DrawPage({super.key});

  static Future<void> push(BuildContext context) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DrawPage()),
    );
  }

  @override
  ConsumerState<DrawPage> createState() => _DrawPageState();
}

class _DrawPageState extends ConsumerState<DrawPage> {
  final _currentPath = Path();
  final _repaintKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(drawViewModelProvider);
    final vm = ref.read(drawViewModelProvider.notifier);

    return Scaffold(
      appBar: ToolTopBar(
        title: '画板',
        actions: [
          IconButton(
            icon: const Icon(Icons.color_lens, color: Color(0xFF4C4C4C)),
            onPressed: () => _pickColor(context, vm, state.penColor),
          ),
          IconButton(
            icon: const Icon(Icons.save, color: Color(0xFF4C4C4C)),
            onPressed: _savePng,
          ),
        ],
      ),
      body: Column(
        children: [
          // 画布
          Expanded(
            child: RepaintBoundary(
              key: _repaintKey,
              child: Container(
                color: Colors.white,
                child: GestureDetector(
                  onPanStart: (details) {
                    _currentPath.reset();
                    _currentPath.moveTo(
                        details.localPosition.dx, details.localPosition.dy);
                  },
                  onPanUpdate: (details) {
                    // quadTo 取中点(对齐 PaletteView.java:648)
                    final p = details.localPosition;
                    final last = _currentPath.getBounds().bottomRight;
                    // 简化: lineTo(原版 quadTo 取中点, 这里用 lineTo 近似平滑)
                    _currentPath.lineTo(p.dx, p.dy);
                    // 实时绘制: 临时加入 paths 触发重绘
                    setState(() {});
                  },
                  onPanEnd: (_) {
                    // 保存到撤销栈 - 对齐 saveDrawingPath
                    vm.addPath(_currentPath);
                    _currentPath.reset();
                  },
                  child: CustomPaint(
                    painter: PalettePainter(
                      paths: [
                        ...state.paths,
                        if (_currentPath.getBounds().width > 0 ||
                            _currentPath.getBounds().height > 0)
                          PathDrawingInfo(
                            Path.from(_currentPath),
                            PaintData(
                              color: state.mode == DrawMode.draw
                                  ? state.penColor
                                  : const Color(0x00000000),
                              strokeWidth: state.mode == DrawMode.draw
                                  ? state.penSize
                                  : state.eraserSize,
                              blendMode: state.mode == DrawMode.draw
                                  ? ui.BlendMode.src
                                  : ui.BlendMode.clear,
                            ),
                          ),
                      ],
                    ),
                    size: Size.infinite,
                  ),
                ),
              ),
            ),
          ),
          // 底部 5 个按钮(对齐 activity_lib_draw_tool.xml)
          Container(
            height: 60,
            color: const Color(0xFFF5F5F5),
            child: Row(
              children: [
                _buildToolBtn(Icons.undo, '撤销', () => vm.undo()),
                _buildToolBtn(Icons.redo, '重做', () => vm.redo()),
                _buildToolBtn(
                  Icons.edit,
                  '画笔',
                  () => vm.setMode(DrawMode.draw),
                  selected: state.mode == DrawMode.draw,
                ),
                _buildToolBtn(
                  Icons.auto_fix_off,
                  '橡皮擦',
                  () => vm.setMode(DrawMode.eraser),
                  selected: state.mode == DrawMode.eraser,
                ),
                _buildToolBtn(Icons.delete, '清除', vm.clear),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolBtn(IconData icon, String label, VoidCallback onTap,
      {bool selected = false}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          color: selected ? const Color(0xFF7B68EE) : Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 24,
                  color: selected ? Colors.white : const Color(0xFF555555)),
              const SizedBox(height: 2),
              Text(label,
                  style: TextStyle(
                      fontSize: 10,
                      color:
                          selected ? Colors.white : const Color(0xFF555555))),
            ],
          ),
        ),
      ),
    );
  }

  /// 颜色选择 - 对齐 DrawActivity 颜色选择
  Future<void> _pickColor(
      BuildContext context, DrawViewModel vm, Color current) async {
    final colors = [
      Colors.black,
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.indigo,
      Colors.purple,
    ];
    final color = await showDialog<Color>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('选择颜色'),
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            children: colors
                .map((c) => GestureDetector(
                      onTap: () => Navigator.pop(ctx, c),
                      child: Container(
                          width: 40,
                          height: 40,
                          margin: const EdgeInsets.all(8),
                          color: c),
                    ))
                .toList(),
          ),
        ],
      ),
    );
    if (color != null) vm.setPenColor(color);
  }

  /// 保存 PNG - 对齐 DrawActivity.java:175-230 Util.SaveImage
  /// 写入应用文档目录(对齐 /工具箱/简易画板/)
  Future<void> _savePng() async {
    final boundary = _repaintKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null) return;
    final image = await boundary.toImage(pixelRatio: 2.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return;
    final bytes = byteData.buffer.asUint8List();
    final now = DateTime.now();
    final fileName =
        'Image-${now.hour.toString().padLeft(2, '0')}-${now.minute.toString().padLeft(2, '0')}-${now.second.toString().padLeft(2, '0')}.png';
    try {
      await DocumentExportService().exportBytesToGallery(
        bytes,
        name: fileName.replaceAll('.png', ''),
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已保存到系统相册')),
        );
      }
    } on GalleryExportException catch (e) {
      if (e.isCanceled) return;
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: ${e.message}')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e')),
        );
      }
    }
  }
}
