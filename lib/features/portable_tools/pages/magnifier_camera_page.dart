import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 工具页放大镜。
///
/// 与拍照存档的文档拍摄流程相互独立：这里只显示应用内实时相机预览，
/// 右侧滑杆和双指手势均会直接设置相机硬件变焦，不是放大已拍摄的图片。
class MagnifierCameraPage extends StatefulWidget {
  const MagnifierCameraPage({super.key});

  @override
  State<MagnifierCameraPage> createState() => _MagnifierCameraPageState();
}

class _MagnifierCameraPageState extends State<MagnifierCameraPage>
    with WidgetsBindingObserver {
  static const _permissionChannel = MethodChannel('toolbox.camera/permission');

  CameraController? _controller;
  bool _initializing = true;
  bool _opening = false;
  String? _error;
  double _minZoom = 1;
  double _maxZoom = 1;
  double _zoom = 1;
  double _scaleStartZoom = 1;

  /// 对齐安卓 NewCameraMagnifygActivity 的 cameraSelector，默认后置。
  CameraLensDirection _lensDirection = CameraLensDirection.back;

  /// 屏幕亮度(0~1)，对齐安卓 LIGHT_INIT 初始 0.5。
  double _brightness = 0.5;

  /// 进入页面前记录的窗口亮度，退出时恢复(安卓是独立窗口自动恢复)。
  double? _brightnessToRestore;

  bool get _previewReady => _controller?.value.isInitialized == true;

  /// 供滑杆使用的标准化进度，和 Android 的 0～100 线性变焦语义一致。
  double get _linearZoom {
    final range = _maxZoom - _minZoom;
    return range <= 0 ? 0 : (_zoom - _minZoom) / range;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_initBrightness());
    _initializeCamera();
  }

  /// 对齐安卓 onCreate 的 setWindowBrightness(LIGHT_INIT)：
  /// 进入时记录原窗口亮度并把屏幕调到 0.5，退出时恢复。
  Future<void> _initBrightness() async {
    try {
      final current =
          await _permissionChannel.invokeMethod<double>('getScreenBrightness');
      if (current != null && current >= 0 && current <= 1) {
        _brightnessToRestore = current;
      }
    } catch (_) {}
    await _applyBrightness(0.5);
    if (mounted) setState(() => _brightness = 0.5);
  }

  Future<void> _applyBrightness(double value) async {
    try {
      await _permissionChannel.invokeMethod<bool>(
        'setScreenBrightness',
        {'brightness': value.clamp(0.0, 1.0)},
      );
    } catch (_) {}
  }

  void _onBrightnessChanged(double value) {
    setState(() => _brightness = value);
    unawaited(_applyBrightness(value));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _controller = null;
      unawaited(controller.dispose());
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    // 安卓窗口关闭自动恢复亮度；Flutter 单窗口需手动恢复。
    final restore = _brightnessToRestore;
    if (restore != null) {
      _permissionChannel
          .invokeMethod<void>(
            'setScreenBrightness',
            {'brightness': restore},
          )
          .catchError((_) {});
    }
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    if (_opening) return;
    _opening = true;
    if (mounted) {
      setState(() {
        _initializing = true;
        _error = null;
      });
    }
    try {
      final granted = await _permissionChannel
          .invokeMethod<bool>('requestCameraPermission');
      if (granted != true) throw const _MagnifierException('未获得相机权限');

      final cameras = await availableCameras();
      final selected = cameras.where(
        (camera) => camera.lensDirection == _lensDirection,
      );
      if (selected.isEmpty) {
        throw _MagnifierException(
            '没有${_lensDirection == CameraLensDirection.front ? '前' : '后'}置相机');
      }
      // 鸿蒙 CameraKit 同一时刻只允许一个相机 session，
      // 必须先释放旧相机再创建新的，否则切换摄像头后预览黑屏。
      final previous = _controller;
      _controller = null;
      if (mounted) setState(() {});
      await previous?.dispose();

      final controller = CameraController(
        selected.first,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await controller.initialize();
      final minZoom = await controller.getMinZoomLevel();
      final maxZoom = await controller.getMaxZoomLevel();

      if (!mounted) {
        await controller.dispose();
        return;
      }
      _controller = controller;
      setState(() {
        _minZoom = minZoom;
        _maxZoom = maxZoom < minZoom ? minZoom : maxZoom;
        _zoom = minZoom;
      });
      await controller.setZoomLevel(_zoom);
    } on _MagnifierException catch (error) {
      _error = error.message;
    } on CameraException catch (error) {
      _error = error.description ?? '相机初始化失败';
    } on PlatformException catch (error) {
      _error = error.message ?? '相机权限申请失败';
    } catch (error) {
      debugPrint('MagnifierCameraPage openCamera($_lensDirection) failed: $error');
      _error = '相机初始化失败，请重试';
    } finally {
      if (mounted) setState(() => _initializing = false);
      _opening = false;
    }
  }

  /// 对齐安卓 camera_switch_button：切换前后摄像头并重启相机。
  Future<void> _switchCamera() async {
    if (_opening) return;
    final cameras = await availableCameras();
    final target = _lensDirection == CameraLensDirection.back
        ? CameraLensDirection.front
        : CameraLensDirection.back;
    if (!cameras.any((camera) => camera.lensDirection == target)) return;
    setState(() => _lensDirection = target);
    await _initializeCamera();
    // 打开失败时回退到后置相机，避免切换后一直黑屏。
    if (mounted &&
        _error != null &&
        _lensDirection != CameraLensDirection.back) {
      _lensDirection = CameraLensDirection.back;
      return _initializeCamera();
    }
  }

  void _changeLinearZoom(double linearZoom) {
    _setZoom(_minZoom + ((_maxZoom - _minZoom) * linearZoom));
  }

  void _setZoom(double value) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    final nextZoom = value.clamp(_minZoom, _maxZoom).toDouble();
    if ((nextZoom - _zoom).abs() < 0.001) return;
    setState(() => _zoom = nextZoom);
    // camera_ohos 会将此调用映射为当前应用相机的真实变焦级别。
    unawaited(controller.setZoomLevel(nextZoom).catchError((_) {}));
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildPreview(controller),
            Positioned(
              top: 8,
              left: 8,
              child: _RoundIconButton(
                tooltip: '返回',
                icon: Icons.arrow_back_ios_new_rounded,
                onPressed: () => Navigator.maybePop(context),
              ),
            ),
            // 对齐安卓 camera_switch_button：右上角切换前后摄像头。
            Positioned(
              top: 8,
              right: 8,
              child: _RoundIconButton(
                tooltip: '反转摄像头',
                icon: Icons.cameraswitch_rounded,
                onPressed: _switchCamera,
              ),
            ),
            const Positioned(
              top: 20,
              left: 72,
              right: 72,
              child: Text(
                '放大镜',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                ),
              ),
            ),
            // 对齐安卓 fangda_layout 左侧亮度滑杆：上"亮"下"暗"，
            // 调节屏幕亮度(setWindowBrightness)而非相机曝光。
            if (_previewReady)
              Positioned(
                top: 70,
                left: 8,
                bottom: 52,
                child: _BrightnessControl(
                  value: _brightness,
                  onChanged: _onBrightnessChanged,
                ),
              ),
            if (_previewReady && _maxZoom > _minZoom)
              Positioned(
                top: 70,
                right: 8,
                bottom: 52,
                child: _ZoomControl(
                  value: _linearZoom,
                  zoomText: '${_zoom.toStringAsFixed(1)}×',
                  onChanged: _changeLinearZoom,
                ),
              ),
            if (_previewReady)
              const Positioned(
                left: 82,
                right: 82,
                bottom: 28,
                child: Text(
                  '双指缩放或拖动两侧滑杆',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xCCFFFFFF),
                    fontSize: 14,
                    shadows: [Shadow(color: Colors.black87, blurRadius: 4)],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview(CameraController? controller) {
    if (_initializing) {
      return const _CameraLoading();
    }
    if (_error != null) {
      return _MagnifierError(message: _error!, onRetry: _initializeCamera);
    }
    if (controller == null || !controller.value.isInitialized) {
      return _MagnifierError(message: '相机未就绪', onRetry: _initializeCamera);
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onScaleStart: (_) => _scaleStartZoom = _zoom,
      onScaleUpdate: (details) => _setZoom(_scaleStartZoom * details.scale),
      child: Center(child: CameraPreview(controller)),
    );
  }
}

class _ZoomControl extends StatelessWidget {
  const _ZoomControl({
    required this.value,
    required this.zoomText,
    required this.onChanged,
  });

  final double value;
  final String zoomText;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      child: Column(children: [
        const _SideLabel('大'),
        const SizedBox(height: 8),
        Expanded(
          child: RotatedBox(
            quarterTurns: 3,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Colors.white,
                inactiveTrackColor: const Color(0x88FFFFFF),
                thumbColor: Colors.white,
                overlayColor: const Color(0x33FFFFFF),
                trackHeight: 3,
              ),
              child: Slider(value: value, onChanged: onChanged),
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xA6000000),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            child: Text(zoomText,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: 8),
        const _SideLabel('小'),
      ]),
    );
  }
}

/// 左侧屏幕亮度滑杆，对齐安卓 fangda_layout 的 light_zoom：
/// 上"亮"下"暗"，0~1 直接映射窗口亮度。
class _BrightnessControl extends StatelessWidget {
  const _BrightnessControl({
    required this.value,
    required this.onChanged,
  });

  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      child: Column(children: [
        const _SideLabel('亮'),
        const SizedBox(height: 8),
        Expanded(
          child: RotatedBox(
            quarterTurns: 3,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Colors.white,
                inactiveTrackColor: const Color(0x88FFFFFF),
                thumbColor: Colors.white,
                overlayColor: const Color(0x33FFFFFF),
                trackHeight: 3,
              ),
              child: Slider(value: value, onChanged: onChanged),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const _SideLabel('暗'),
      ]),
    );
  }
}

class _SideLabel extends StatelessWidget {
  const _SideLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration:
          const BoxDecoration(color: Color(0x99000000), shape: BoxShape.circle),
      child: SizedBox(
        width: 38,
        height: 38,
        child: Center(
          child: Text(text,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });
  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0x99000000),
      shape: const CircleBorder(),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white, size: 21),
      ),
    );
  }
}

class _CameraLoading extends StatelessWidget {
  const _CameraLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        CircularProgressIndicator(color: Colors.white),
        SizedBox(height: 14),
        Text('正在开启相机…', style: TextStyle(color: Color(0xCCFFFFFF))),
      ]),
    );
  }
}

class _MagnifierError extends StatelessWidget {
  const _MagnifierError({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xCCFFFFFF), fontSize: 16)),
        ),
        const SizedBox(height: 18),
        OutlinedButton(onPressed: onRetry, child: const Text('重新打开')),
      ]),
    );
  }
}

class _MagnifierException implements Exception {
  const _MagnifierException(this.message);
  final String message;
}
