// Android RulerActivity/RulerView 的 Flutter 实现。
import 'dart:math' as math;
import 'package:flutter/material.dart';

class RulerToolPage extends StatefulWidget {
  const RulerToolPage({super.key});

  @override
  State<RulerToolPage> createState() => _RulerToolPageState();
}

class _RulerToolPageState extends State<RulerToolPage> {
  final Map<int, Offset> _pointers = <int, Offset>{};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('尺子'),
        backgroundColor: const Color(0xFFF0FFB8),
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Listener(
        onPointerDown: (event) => setState(() {
          _pointers[event.pointer] = event.localPosition;
        }),
        onPointerMove: (event) => setState(() {
          if (_pointers.containsKey(event.pointer)) {
            _pointers[event.pointer] = event.localPosition;
          }
        }),
        onPointerUp: (event) => setState(() {
          _pointers.remove(event.pointer);
        }),
        onPointerCancel: (event) => setState(() {
          _pointers.remove(event.pointer);
        }),
        child: CustomPaint(
          painter: _RulerPainter(_pointers.values.toList()),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _RulerPainter extends CustomPainter {
  final List<Offset> pointers;
  _RulerPainter(this.pointers);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(const Color(0xFFF6C766), BlendMode.src);
    final scale = size.height / 35;
    final tickPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (var i = 0; i <= 350; i++) {
      final y = size.height - i * scale / 10;
      if (y < 0) break;
      final length = i % 10 == 0
          ? 46.0
          : i % 5 == 0
              ? 32.0
              : 20.0;
      canvas.drawLine(
          Offset(size.width - length, y), Offset(size.width, y), tickPaint);
      if (i % 10 == 0) {
        textPainter.text = TextSpan(
          text: '${i ~/ 10}',
          style: const TextStyle(color: Colors.white, fontSize: 14),
        );
        textPainter.layout();
        canvas.save();
        canvas.translate(size.width - length - 15, y + 4);
        canvas.rotate(-math.pi / 2);
        textPainter.paint(canvas, Offset.zero);
        canvas.restore();
      }
    }
    // Android RulerView 以两指在刻度方向上的垂直距离计算长度，
    // 而不是取两点的斜边距离，避免横向移动影响读数。
    final label = pointers.length >= 2
        ? '${(_verticalDistance(pointers[0], pointers[1]) / scale).toStringAsFixed(1)} cm'
        : '请用双指测量';
    textPainter.text = TextSpan(
      text: label,
      style: const TextStyle(color: Colors.white, fontSize: 34),
    );
    textPainter.layout();
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(-math.pi / 2);
    textPainter.paint(
        canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
    canvas.restore();
    final pointerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    for (final point in pointers) {
      canvas.drawCircle(point, 30, pointerPaint);
      canvas.drawLine(Offset(point.dx + 30, point.dy),
          Offset(size.width, point.dy), pointerPaint);
    }
  }

  double _verticalDistance(Offset a, Offset b) => (a.dy - b.dy).abs();

  @override
  bool shouldRepaint(covariant _RulerPainter oldDelegate) => true;
}
