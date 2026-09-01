// Android SmallLevelActivity/LevelView 的 Flutter 实现。
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LevelToolPage extends StatefulWidget {
  const LevelToolPage({super.key});

  @override
  State<LevelToolPage> createState() => _LevelToolPageState();
}

class _LevelToolPageState extends State<LevelToolPage>
    with WidgetsBindingObserver {
  static const _channel = MethodChannel('com.p.a_b/toolbox_heading');
  Timer? _timer;
  double _roll = 0;
  double _pitch = 0;
  bool _isPolling = false;
  bool _isReadInFlight = false;
  late AppLifecycleState _lifecycleState;

  @override
  void initState() {
    super.initState();
    _lifecycleState =
        WidgetsBinding.instance.lifecycleState ?? AppLifecycleState.resumed;
    WidgetsBinding.instance.addObserver(this);
    _syncPolling();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lifecycleState = state;
    _syncPolling();
  }

  void _syncPolling() {
    if (_lifecycleState == AppLifecycleState.resumed) {
      _startPolling();
    } else {
      _stopPolling();
    }
  }

  void _startPolling() {
    if (_isPolling) return;
    _isPolling = true;
    _readOrientation();
    _timer = Timer.periodic(
        const Duration(milliseconds: 120), (_) => _readOrientation());
  }

  void _stopPolling() {
    _isPolling = false;
    _timer?.cancel();
    _timer = null;
    _channel.invokeMethod<void>('stopHeading');
  }

  Future<void> _readOrientation() async {
    if (!_isPolling || _isReadInFlight) return;
    _isReadInFlight = true;
    try {
      final data =
          await _channel.invokeMapMethod<String, dynamic>('getOrientation');
      if (!mounted || !_isPolling || data == null) return;
      setState(() {
        _roll = _number(data['gamma']);
        _pitch = _number(data['beta']);
      });
    } on PlatformException {
      // 设备没有姿态传感器时保持零度，页面仍可展示。
    } finally {
      _isReadInFlight = false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopPolling();
    super.dispose();
  }

  double _number(dynamic value) =>
      value is num ? value.toDouble() : double.tryParse('$value') ?? 0;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('水平仪'),
          backgroundColor: const Color(0xFFF0FFB8),
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        backgroundColor: const Color(0xFFF6C766),
        body: Column(
          children: [
            Expanded(
              child: Center(
                child: CustomPaint(
                  size: const Size(250, 250),
                  painter: _LevelPainter(_roll, _pitch),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(30, 24, 30, 32),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFF4CAF50))),
              ),
              child: Row(
                children: [
                  Expanded(child: _AngleReadout('${_pitch.round()}°', '垂直')),
                  Expanded(child: _AngleReadout('${_roll.round()}°', '水平')),
                ],
              ),
            ),
          ],
        ),
      );
}

class _AngleReadout extends StatelessWidget {
  final String value;
  final String label;
  const _AngleReadout(this.value, this.label);
  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(value,
              style: const TextStyle(color: Colors.white, fontSize: 40)),
          Text(label,
              style: const TextStyle(color: Colors.white, fontSize: 20)),
        ],
      );
}

class _LevelPainter extends CustomPainter {
  final double roll;
  final double pitch;
  _LevelPainter(this.roll, this.pitch);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 6;
    // Android LevelView 只绘制限制圈轮廓，不填充整块红色区域。
    final isCentered = roll.abs() < 0.5 && pitch.abs() < 0.5;
    final limitColor =
        isCentered ? const Color(0xFF00FF00) : const Color(0xFFE03524);
    canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = limitColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6);
    canvas.drawCircle(
        center,
        25,
        Paint()
          ..color = const Color(0xFF757575)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1);
    final dx = (roll / 90).clamp(-1.0, 1.0) * (radius - 25);
    final dy = (pitch / 90).clamp(-1.0, 1.0) * (radius - 25);
    final bubble = Offset(center.dx + dx, center.dy + dy);
    canvas.drawCircle(bubble, 25, Paint()..color = limitColor);
  }

  @override
  bool shouldRepaint(covariant _LevelPainter oldDelegate) =>
      oldDelegate.roll != roll || oldDelegate.pitch != pitch;
}
