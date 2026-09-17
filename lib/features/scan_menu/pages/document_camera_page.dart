import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/document_capture_service.dart';

/// 应用内相机：复用 master_saolaisao 的 camera_ohos 方案，避免拉起系统相机 Ability。
class DocumentCameraPage extends StatefulWidget {
  const DocumentCameraPage({super.key, this.title = '拍照存档'});

  final String title;

  static Future<File?> capture(BuildContext context, {String title = '拍照存档'}) {
    return Navigator.push<File>(
      context,
      MaterialPageRoute(builder: (_) => DocumentCameraPage(title: title)),
    );
  }

  @override
  State<DocumentCameraPage> createState() => _DocumentCameraPageState();
}

class _DocumentCameraPageState extends State<DocumentCameraPage>
    with WidgetsBindingObserver {
  static const _permissionChannel = MethodChannel('toolbox.camera/permission');

  CameraController? _controller;
  bool _initializing = true;
  bool _capturing = false;
  bool _opening = false;
  String? _error;

  /// 对齐识别页相机控制：默认后置，可切换前置。
  CameraLensDirection _lensDirection = CameraLensDirection.back;

  /// 对齐识别页闪光灯：OFF → ALWAYS → AUTO 三态循环，初始关闭。
  FlashMode _flashMode = FlashMode.off;

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
      controller.dispose();
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
      if (granted != true) {
        throw const DocumentCaptureException('未获得相机权限');
      }
      // 鸿蒙 CameraKit 同一时刻只允许一个相机 session，
      // 必须先释放旧相机再创建新的，否则新相机预览黑屏。
      final previous = _controller;
      _controller = null;
      if (mounted) setState(() {});
      await previous?.dispose();

      final cameras = await availableCameras();
      final selected = cameras.where(
        (camera) => camera.lensDirection == _lensDirection,
      );
      if (selected.isEmpty) {
        throw DocumentCaptureException(
          '没有${_lensDirection == CameraLensDirection.front ? '前' : '后'}置相机',
        );
      }
      final controller = CameraController(
        selected.first,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() => _controller = controller);
      // 相机就绪后恢复当前闪光灯模式(前置不支持时忽略)。
      try {
        await controller.setFlashMode(_flashMode);
      } catch (_) {}
    } on DocumentCaptureException catch (error) {
      _error = error.message;
    } on CameraException catch (error) {
      _error = error.description ?? '相机初始化失败';
    } on PlatformException catch (error) {
      _error = error.message ?? '相机权限申请失败';
    } catch (_) {
      _error = '相机初始化失败，请重试';
    } finally {
      _opening = false;
      if (mounted) setState(() => _initializing = false);
    }
  }

  /// 对齐安卓 camera_switch_button：切换前后摄像头并重启相机。
  Future<void> _switchCamera() async {
    final cameras = await availableCameras();
    final target = _lensDirection == CameraLensDirection.back
        ? CameraLensDirection.front
        : CameraLensDirection.back;
    if (!cameras.any((camera) => camera.lensDirection == target)) return;
    setState(() => _lensDirection = target);
    await _initializeCamera();
  }

  /// 对齐安卓 flash_switch_button：OFF→ALWAYS→AUTO 三态循环。
  Future<void> _cycleFlashMode() async {
    setState(() {
      if (_flashMode == FlashMode.off) {
        _flashMode = FlashMode.always;
      } else if (_flashMode == FlashMode.always) {
        _flashMode = FlashMode.auto;
      } else {
        _flashMode = FlashMode.off;
      }
    });
    try {
      await _controller?.setFlashMode(_flashMode);
    } catch (_) {}
  }

  Future<void> _takePicture() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _capturing) {
      return;
    }
    setState(() => _capturing = true);
    try {
      final image = await controller.takePicture();
      if (mounted) Navigator.pop(context, File(image.path));
    } on CameraException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.description ?? '拍照失败，请重试')),
        );
      }
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final previewReady = controller?.value.isInitialized == true;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(children: [
          SizedBox(
            height: 52,
            // 左右等宽的独立区域，标题只在中间区域布局，避免与返回按钮重叠。
            child: Row(children: [
              SizedBox(
                width: 56,
                child: IconButton(
                  tooltip: '返回',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ),
              Expanded(
                child: Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
              // 对齐安卓 camera_switch_button：右上角切换前后摄像头。
              SizedBox(
                width: 56,
                child: IconButton(
                  tooltip: '反转摄像头',
                  onPressed: _switchCamera,
                  icon: Image.asset(
                    'assets/images/recognition/ic_switch.png',
                    width: 26,
                    height: 26,
                  ),
                ),
              ),
            ]),
          ),
          Expanded(
            child: Container(
              color: const Color(0xFF232323),
              alignment: Alignment.center,
              child: _initializing
                  ? const Column(mainAxisSize: MainAxisSize.min, children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 14),
                      Text('正在开启相机…',
                          style: TextStyle(color: Color(0xCCFFFFFF))),
                    ])
                  : _error != null
                      ? _CameraError(
                          message: _error!, onRetry: _initializeCamera)
                      : previewReady
                          ? Center(child: CameraPreview(controller!))
                          : _CameraError(
                              message: '相机未就绪', onRetry: _initializeCamera),
            ),
          ),
          SizedBox(
            height: 128,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 左侧占位，与闪光灯等宽，保持快门居中。
                  const SizedBox(width: 48),
                  Center(
                    child: GestureDetector(
                      onTap: previewReady && !_capturing ? _takePicture : null,
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        padding: const EdgeInsets.all(5),
                        child: DecoratedBox(
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle, color: Colors.white),
                          child: _capturing
                              ? const Padding(
                                  padding: EdgeInsets.all(14),
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                  // 对齐安卓 flash_switch_button：快门右侧三态闪光灯。
                  IconButton(
                    tooltip: '闪光灯',
                    onPressed: _cycleFlashMode,
                    icon: Image.asset(
                      _flashMode == FlashMode.always
                          ? 'assets/images/recognition/open_flash.png'
                          : _flashMode == FlashMode.auto
                              ? 'assets/images/recognition/auto_flash.png'
                              : 'assets/images/recognition/stop_flash.png',
                      width: 28,
                      height: 28,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _CameraError extends StatelessWidget {
  const _CameraError({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Text(message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xCCFFFFFF), fontSize: 16)),
      const SizedBox(height: 18),
      OutlinedButton(onPressed: onRetry, child: const Text('重新打开')),
    ]);
  }
}
