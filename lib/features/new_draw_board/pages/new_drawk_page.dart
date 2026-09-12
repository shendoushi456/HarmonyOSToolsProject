// NewDrawkFragment Flutter 迁移版 - 画板页
// 对齐 Android fragment_new_draw_tool.xml + NewDrawkFragment.kt
// 替换 HomeShellPage 的 Tab[1]（原 ScanToolsPage）
// 复用 DrawViewModel + DrawState + PalettePainter 画板逻辑
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../life_tools/pages/color_drawing_studio_page.dart';
import '../../life_tools/viewmodels/draw_state.dart';
import '../../life_tools/viewmodels/draw_view_model.dart';
import '../../scan_menu/services/document_export_service.dart';

class NewDrawkPage extends ConsumerStatefulWidget {
  const NewDrawkPage({super.key});

  @override
  ConsumerState<NewDrawkPage> createState() => _NewDrawkPageState();
}

class _NewDrawkPageState extends ConsumerState<NewDrawkPage> {
  final _canvasKey = GlobalKey();
  Path? _activePath;
  Offset? _lastPoint;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(drawViewModelProvider);
    final vm = ref.read(drawViewModelProvider.notifier);
    return Scaffold(
      backgroundColor: AppColors.homeBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(child: _buildCanvasArea(context, state, vm)),
            _buildBottomTools(context, state, vm),
          ],
        ),
      ),
    );
  }

  /// 顶栏（对齐 fragment_new_draw_tool.xml:27-50 mDrawToolTopBar）
  /// "画板"标题居中 + 保存按钮右对齐
  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      color: AppColors.homeBg,
      child: SizedBox(
        height: 38,
        child: Row(
          children: [
            const SizedBox(width: 42),
            const Expanded(
              child: Center(
                child: Text(
                  '画板',
                  style: TextStyle(fontSize: 22, color: Colors.black),
                ),
              ),
            ),
            // 保存按钮（对齐 paint_save_iv iv_save2 22x22 marginRight 20）
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: GestureDetector(
                onTap: _save,
                child: Image.asset(AppAssets.drawkSave, width: 22, height: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 画板区（对齐 :248-312 ShapeRelativeLayout 白色圆角 20dp）
  /// CustomPaint + 底部 card3(画笔)/card4(橡皮)
  Widget _buildCanvasArea(
      BuildContext context, DrawState state, DrawViewModel vm) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // 画布（对齐 :305-309 PaletteView marginBottom 50）
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: RepaintBoundary(
                key: _canvasKey,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanStart: (details) {
                    final local = details.localPosition;
                    _activePath = Path()..moveTo(local.dx, local.dy);
                    _lastPoint = local;
                    setState(() {});
                  },
                  onPanUpdate: (details) {
                    final local = details.localPosition;
                    final last = _lastPoint;
                    if (_activePath == null || last == null) return;
                    // cubicTo 贝塞尔平滑（对齐 PaletteView.java:620 quadTo 中点）
                    // quadTo 不可用，用 cubicTo 近似：控制点1=last，控制点2=mid，终点=mid
                    final midX = (last.dx + local.dx) / 2;
                    final midY = (last.dy + local.dy) / 2;
                    _activePath!
                        .cubicTo(last.dx, last.dy, midX, midY, midX, midY);
                    _lastPoint = local;
                    setState(() {});
                  },
                  onPanEnd: (_) {
                    final path = _activePath;
                    if (path != null) vm.addPath(path);
                    setState(() {
                      _activePath = null;
                      _lastPoint = null;
                    });
                  },
                  child: CustomPaint(
                    painter: _NewDrawkPainter(
                      paths: state.paths,
                      activePath: _activePath,
                      color: state.mode == DrawMode.draw
                          ? state.penColor
                          : const Color(0x00000000),
                      width: state.mode == DrawMode.draw
                          ? state.penSize
                          : state.eraserSize,
                      mode: state.mode,
                    ),
                    size: Size.infinite,
                  ),
                ),
              ),
            ),
          ),
          // 底部 card3(画笔) + card4(橡皮)（对齐 :259-304 centerHorizontal alignParentBottom）
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // card3 画笔（lhbicon 30x30 margin 10）
                _buildCanvasToolButton(
                  AppAssets.drawkPen,
                  () => vm.setMode(DrawMode.draw),
                ),
                const SizedBox(width: 20),
                // card4 橡皮（lxpcicon 30x30 margin 10）
                _buildCanvasToolButton(
                  AppAssets.drawkEraser,
                  () => vm.setMode(DrawMode.eraser),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCanvasToolButton(String icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.all(10),
        child: Image.asset(icon, width: 30, height: 30, fit: BoxFit.contain),
      ),
    );
  }

  /// 底部工具栏（对齐 :62-247 llBottom）
  /// 第一行 5 图标 + 第二行 3 卡片
  Widget _buildBottomTools(
      BuildContext context, DrawState state, DrawViewModel vm) {
    return Column(
      children: [
        // 第一行 5 图标（对齐 :74-167 ShapeLinearLayout 圆角 10dp #4DFFFFFF）
        Container(
          margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.homeRecognitionCard,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              _buildToolIcon(
                  AppAssets.drawkPenSize, () => _showBrushSizeDialog(vm)),
              _buildToolIcon(AppAssets.drawkPenColor, () => _pickColor(vm)),
              _buildToolIcon(AppAssets.drawkUndo, vm.undo),
              _buildToolIcon(AppAssets.drawkRedo, vm.redo),
              _buildToolIcon(AppAssets.drawkClear, vm.clear),
            ],
          ),
        ),
        // 第二行 3 卡片（对齐 :169-245 RelativeLayout marginTop 10 marginH 20）
        Container(
          margin: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // newDrawGthh 跟图绘画（左，newhomegthhdraw 52x52 + "跟图绘画" 12sp bold #333333）
              _buildBottomCard(
                icon: AppAssets.drawkTraceDraw,
                iconSize: 52,
                title: '跟图绘画',
                titleColor: const Color(0xFF333333),
                onTap: () => ColorDrawingStudioPage.push(
                    context, ColorDrawingMode.trace),
              ),
              // newDrawHb 画板大图（中，mtoolsl_hb_icon 86x86 + "画板" 12sp bold）
              _buildBottomCard(
                icon: AppAssets.drawkBoardIcon,
                iconSize: 86,
                title: '画板',
                titleColor: Colors.black,
                onTap: () {}, // 无点击（展示，对齐 NewDrawkFragment 无 newDrawHb 监听）
              ),
              // newDrawXzhh 形状绘画（右，newhomexzhhdraw 52x52 + "形状绘画" 12sp bold #333333）
              _buildBottomCard(
                icon: AppAssets.drawkShapeDraw,
                iconSize: 52,
                title: '形状绘画',
                titleColor: const Color(0xFF333333),
                onTap: () => ColorDrawingStudioPage.push(
                    context, ColorDrawingMode.shape),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 工具图标（对齐 :84-167 每个 LinearLayout weight 1，图标 30x30）
  Widget _buildToolIcon(String icon, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Image.asset(icon, width: 30, height: 30, fit: BoxFit.contain),
        ),
      ),
    );
  }

  /// 底部卡片（对齐 :176-244 ShapeLinearLayout 100dp vertical center）
  Widget _buildBottomCard({
    required String icon,
    required double iconSize,
    required String title,
    required Color titleColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(icon, width: iconSize, height: iconSize),
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 12),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 画笔大小对话框（对齐 :161-194 MaterialAlertDialogBuilder + DiscreteSeekBar）
  Future<void> _showBrushSizeDialog(DrawViewModel vm) async {
    var size = ref.read(drawViewModelProvider).penSize.round().clamp(1, 30);
    if (size < 1) size = 6; // 默认 6（对齐 hbdx=6）
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
                onChanged: (v) => setDialogState(() => size = v.round()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              vm.setPenSize(size.toDouble());
              Navigator.pop(dialogContext);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 颜色选择。使用基础色块避免鸿蒙端 HSV 色轮在弹窗合成时出现黑屏。
  Future<void> _pickColor(DrawViewModel vm) async {
    const colors = <Color>[
      Color(0xFF000000),
      Color(0xFFFFFFFF),
      Color(0xFFF53131),
      Color(0xFFFF8A00),
      Color(0xFFFFD400),
      Color(0xFF36B34A),
      Color(0xFF3196F5),
      Color(0xFF313AF5),
      Color(0xFF7B31F5),
      Color(0xFFC031F5),
      Color(0xFFF531BB),
      Color(0xFF795548),
    ];
    final selected = await showDialog<Color>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('选择颜色'),
        content: Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final color in colors)
              GestureDetector(
                onTap: () => Navigator.pop(dialogContext, color),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF666666)),
                  ),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
        ],
      ),
    );
    if (selected != null) {
      vm.setPenColor(selected);
      vm.setMode(DrawMode.draw);
    }
  }

  /// 保存图片到系统图库（原对齐 SaveImage 到 /工具箱/简易画板/，改为图库）
  Future<void> _save() async {
    final boundary =
        _canvasKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;
    final image = await boundary.toImage(pixelRatio: 2);
    final data = await image.toByteData(format: ImageByteFormat.png);
    if (data == null) return;
    final now = DateTime.now();
    try {
      await DocumentExportService().exportBytesToGallery(
        data.buffer.asUint8List(),
        name: '简易画板-${now.hour}-${now.minute}-${now.second}',
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
    }
  }
}

/// 画板 Painter（对齐 PaletteView onDraw + 支持当前绘制中的 path）
class _NewDrawkPainter extends CustomPainter {
  const _NewDrawkPainter({
    required this.paths,
    required this.activePath,
    required this.color,
    required this.width,
    required this.mode,
  });
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
        ..strokeJoin = StrokeJoin.round
        ..isAntiAlias = true;
      canvas.drawPath(info.path, paint);
    }
    if (activePath != null) {
      final paint = Paint()
        ..color = color
        ..strokeWidth = width
        ..blendMode =
            mode == DrawMode.eraser ? BlendMode.clear : BlendMode.srcOver
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..isAntiAlias = true;
      canvas.drawPath(activePath!, paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _NewDrawkPainter old) => true;
}
