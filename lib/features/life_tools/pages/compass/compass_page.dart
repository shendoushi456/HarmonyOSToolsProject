// 指南针页 - 对齐 Android CompassActivity.java + activity_compass.xml
// 黑色背景 + 黑色顶栏(返回+"指南针"白字) + ChaosCompassView 占满
// 3D 倾斜 + 弹性回弹(对齐 ChaosCompassView.java:577-684 onTouchEvent + startRestore)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../../viewmodels/compass_view_model.dart';
import 'widgets/chaos_compass_painter.dart';

class CompassPage extends ConsumerStatefulWidget {
  const CompassPage({super.key});

  static Future<void> push(BuildContext context) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CompassPage()),
    );
  }

  @override
  ConsumerState<CompassPage> createState() => _CompassPageState();
}

class _CompassPageState extends ConsumerState<CompassPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _restoreController;
  double _rotateX = 0;
  double _rotateY = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _restoreController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _restoreController.dispose();
    super.dispose();
  }

  /// 对齐 Android CompassActivity.onResume/onPause 的传感器注册/注销,
  /// 应用后台时停止传感器流,避免不可见状态下持续计算重绘(商店功耗审核要求)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final notifier = ref.read(compassViewModelProvider.notifier);
    switch (state) {
      case AppLifecycleState.resumed:
        notifier.resume();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        notifier.pause();
        break;
    }
  }

  /// 弹性回弹插值器 - 对齐 ChaosCompassView.java:623-684 startRestore
  /// 公式: f=0.571429f; (pow(2, -2*input) * sin((input - f/4) * 2π / f) + 1)
  double _elasticInterpolator(double input) {
    const f = 0.571429;
    return (math.pow(2, -2 * input) *
            math.sin((input - f / 4) * 2 * math.pi / f)) +
        1;
  }

  void _startRestore(double startX, double startY) {
    final startRotateX = _rotateX;
    final startRotateY = _rotateY;
    _restoreController.reset();
    _restoreController.addListener(() {
      final t = _elasticInterpolator(_restoreController.value);
      setState(() {
        _rotateX = startRotateX * (1 - t.clamp(0, 1.5));
        _rotateY = startRotateY * (1 - t.clamp(0, 1.5));
      });
    });
    _restoreController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(compassViewModelProvider);
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = Size(
                    constraints.maxWidth,
                    constraints.maxHeight,
                  );
                  return GestureDetector(
                    onPanUpdate: (details) {
                      // 对齐 ChaosCompassView.java:577-621 onTouchEvent
                      // cameraRotateX = -(y - h/2), cameraRotateY = (x - w/2)
                      setState(() {
                        _rotateX = -(details.delta.dy * 0.5);
                        _rotateY = (details.delta.dx * 0.5);
                      });
                    },
                    onPanEnd: (_) => _startRestore(_rotateX, _rotateY),
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateX(_rotateX * 0.01)
                        ..rotateY(_rotateY * 0.01),
                      child: CustomPaint(
                        painter: ChaosCompassPainter(azimuth: state.azimuth),
                        size: size,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 黑色顶栏 - 对齐 activity_compass.xml RelativeLayout(40dp 返回+"指南针"白字)
  Widget _buildTopBar(BuildContext context) {
    return Container(
      height: 50,
      color: Colors.black,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              '指南针',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
              ),
            ),
          ),
          const SizedBox(width: 48), // 平衡左侧返回按钮宽度
        ],
      ),
    );
  }
}
