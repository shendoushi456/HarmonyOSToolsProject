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
  String? _error;
  double _minZoom = 1;
  double _maxZoom = 1;
  double _zoom = 1;
  double _scaleStartZoom = 1;

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
    _initializeCamera();
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
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    if (_previewReady) return;
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
      if (cameras.isEmpty) throw const _MagnifierException('未找到可用相机');
      final backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        backCamera,
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
      final previous = _controller;
      _controller = controller;
      await previous?.dispose();
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
    } catch (_) {
      _error = '相机初始化失败，请重试';
    } finally {
      if (mounted) setState(() => _initializing = false);
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
                left: 24,
                right: 82,
                bottom: 28,
                child: Text(
                  '双指缩放或拖动右侧滑杆',
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
