// 颜色选择对话框 - 对齐 Android flask ColorPickerDialogBuilder(色轮)的 Flutter 简化还原
// 结构: 顶部当前色预览 + 饱和度/亮度面板 + 色相条 + 常用色快捷块 + 取消/确定
import 'package:flutter/material.dart';

/// 弹出色轮对话框,返回所选颜色(取消返回 null)
Future<Color?> showColorPickerDialog(
    BuildContext context, Color initial) {
  return showDialog<Color>(
    context: context,
    builder: (_) => _ColorPickerDialog(initial: initial),
  );
}

class _ColorPickerDialog extends StatefulWidget {
  final Color initial;
  const _ColorPickerDialog({required this.initial});

  @override
  State<_ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<_ColorPickerDialog> {
  late HSVColor _hsv = HSVColor.fromColor(widget.initial);
  final List<Color> _quickColors = const [
    Color(0xFF000000), Color(0xFFFFFFFF), Color(0xFFFF0000), Color(0xFF00FF00),
    Color(0xFF0000FF), Color(0xFFFFFF00), Color(0xFF00FFFF), Color(0xFFFF00FF),
    Color(0xFFF6C766), Color(0xFF6FBFFF), Color(0xFF373063), Color(0xFF5AC158),
  ];

  @override
  Widget build(BuildContext context) {
    final current = _hsv.toColor();
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 预览行(对齐 flask 顶部当前色)
            Row(children: [
              const Text('选择颜色',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const Spacer(),
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: current,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            // 饱和度/亮度面板
            _svPanel(),
            const SizedBox(height: 12),
            // 色相条
            _hueBar(),
            const SizedBox(height: 12),
            // 常用色快捷块
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _quickColors.map((c) => GestureDetector(
                onTap: () => setState(() => _hsv = HSVColor.fromColor(c)),
                child: Container(width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: c, shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFBDBDBD))),
                ),
              )).toList(),
            ),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('取消'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: current),
                onPressed: () => Navigator.of(context).pop(current),
                child: const Text('确定',
                    style: TextStyle(color: Colors.white)),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _svPanel() {
    return LayoutBuilder(builder: (context, constraints) {
      const panelH = 140.0;
      void update(Offset local) {
        final s = (local.dx / constraints.maxWidth).clamp(0.0, 1.0);
        final v = (1 - local.dy / panelH).clamp(0.0, 1.0);
        setState(() =>
            _hsv = HSVColor.fromAHSV(1, _hsv.hue, s, v));
      }

      return GestureDetector(
        onPanDown: (d) => update(d.localPosition),
        onPanUpdate: (d) => update(d.localPosition),
        onTapDown: (d) => update(d.localPosition),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CustomPaint(
            size: Size(constraints.maxWidth, panelH),
            painter: _SvPainter(
                hue: _hsv.hue,
                satPoint: _hsv.saturation,
                valPoint: _hsv.value),
          ),
        ),
      );
    });
  }

  Widget _hueBar() {
    return LayoutBuilder(builder: (context, constraints) {
      void update(Offset local) {
        final hue = (local.dx / constraints.maxWidth * 360).clamp(0.0, 360.0);
        setState(() =>
            _hsv = HSVColor.fromAHSV(1, hue, _hsv.saturation, _hsv.value));
      }

      return GestureDetector(
        onPanDown: (d) => update(d.localPosition),
        onPanUpdate: (d) => update(d.localPosition),
        onTapDown: (d) => update(d.localPosition),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: CustomPaint(
            size: Size(constraints.maxWidth, 24),
            painter: const _HuePainter(),
          ),
        ),
      );
    });
  }
}

/// 饱和度/亮度面板(HSV: 底色为当前色相全饱和色,向右饱和↑ 向下亮度↓)
class _SvPainter extends CustomPainter {
  final double hue;
  final double satPoint;
  final double valPoint;
  _SvPainter({required this.hue, required this.satPoint, required this.valPoint});

  @override
  void paint(Canvas canvas, Size size) {
    final base = HSVColor.fromAHSV(1, hue, 1, 1).toColor();
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = Colors.white);
    canvas.drawRect(
        rect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Colors.white, base],
          ).createShader(rect));
    canvas.drawRect(
        rect,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black],
          ).createShader(rect));
    // 当前选点圆圈指示
    final cx = satPoint * size.width;
    final cy = (1 - valPoint) * size.height;
    canvas.drawCircle(Offset(cx, cy), 8,
        Paint()..style = PaintingStyle.stroke..strokeWidth = 2..color = Colors.white);
  }

  @override
  bool shouldRepaint(_SvPainter oldDelegate) =>
      oldDelegate.hue != hue ||
      oldDelegate.satPoint != satPoint ||
      oldDelegate.valPoint != valPoint;
}

/// 色相条(HSV 色环 0~360)
class _HuePainter extends CustomPainter {
  const _HuePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final colors = <Color>[
      for (int i = 0; i <= 12; i++)
        HSVColor.fromAHSV(1, i * 30.0, 1, 1).toColor(),
    ];
    canvas.drawRect(
        rect,
        Paint()
          ..shader = LinearGradient(colors: colors).createShader(rect));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
