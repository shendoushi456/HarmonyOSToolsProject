import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../models/recognition_type.dart';
import '../repositories/baidu_recognition_repository.dart';

/// 后置相机预览、拍照与相册入口；不含 Android 端的扫描和扫描动画。
class RecognitionPage extends StatefulWidget {
  final RecognitionType type;
  const RecognitionPage({super.key, required this.type});

  @override
  State<RecognitionPage> createState() => _RecognitionPageState();
}

class _RecognitionPageState extends State<RecognitionPage>
    with WidgetsBindingObserver {
  CameraController? _camera;
  bool _loading = false;
  bool _opening = false;
  String? _error;

  /// 对齐安卓 NewCameraMagnifygActivity 的 cameraSelector，默认后置。
  CameraLensDirection _lensDirection = CameraLensDirection.back;

  /// 对齐安卓 flashMode：OFF → ON → AUTO 三态循环，初始关闭。
  FlashMode _flashMode = FlashMode.off;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _openCamera();
  }

  Future<void> _openCamera() async {
    if (_opening) return;
    _opening = true;
    if (mounted) setState(() => _error = null);
    try {
      // 鸿蒙 CameraKit 同一时刻只允许一个相机 session，
      // 必须先释放旧相机再创建新的，否则新相机预览黑屏。
      final previous = _camera;
      _camera = null;
      if (mounted) setState(() {});
      await previous?.dispose();

      final cameras = await availableCameras();
      final selected = cameras.where(
        (camera) => camera.lensDirection == _lensDirection,
      );
      if (selected.isEmpty) {
        throw Exception('没有${_lensDirection == CameraLensDirection.front ? '前' : '后'}置相机');
      }
      final controller =
          CameraController(selected.first, ResolutionPreset.high,
              enableAudio: false);
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() => _camera = controller);
      // 安卓在 startCamera 时用 ImageCapture.Builder().setFlashMode(flashMode)
      // 重建拍照用例；这里在相机就绪后恢复当前闪光灯模式(前置不支持时忽略)。
      try {
        await controller.setFlashMode(_flashMode);
      } catch (_) {}
    } catch (error) {
      debugPrint('RecognitionPage openCamera($_lensDirection) failed: $error');
      // 打开失败时回退到后置相机，避免切换后一直黑屏。
      if (mounted && _lensDirection != CameraLensDirection.back) {
        _lensDirection = CameraLensDirection.back;
        _opening = false;
        return _openCamera();
      }
      if (mounted) setState(() => _error = '相机不可用：$error');
    } finally {
      _opening = false;
      if (mounted) setState(() {});
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
    await _openCamera();
  }

  /// 对齐安卓 flash_switch_button：OFF→ON→AUTO 三态循环，切换后重启相机。
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
      await _camera?.setFlashMode(_flashMode);
    } catch (_) {}
  }

  Future<void> _useImage(XFile? file) async {
    if (file == null || _loading) return;
    setState(() => _loading = true);
    try {
      final data =
          await BaiduRecognitionRepository().recognize(widget.type, file.path);
      if (mounted) {
        await showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          builder: (_) => _ResultSheet(type: widget.type, data: data),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('识别失败：$error')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.type.title),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        // 对齐安卓 camera_switch_button：右上角切换前后摄像头。
        actions: [
          IconButton(
            tooltip: '反转摄像头',
            onPressed: _switchCamera,
            icon: Image.asset(
              'assets/images/recognition/ic_switch.png',
              width: 26,
              height: 26,
            ),
          ),
        ],
      ),
      body: Stack(children: [
        Positioned.fill(
          child: _camera?.value.isInitialized == true
              ? CameraPreview(_camera!)
              : Center(
                  child: Text(_error ?? '正在打开相机…',
                      style: const TextStyle(color: Colors.white)),
                ),
        ),
        if (_loading) const Center(child: CircularProgressIndicator()),
        Align(
          alignment: Alignment.bottomCenter,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () async => _useImage(
                      await ImagePicker().pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 85,
                        maxWidth: 1920,
                      ),
                    ),
                    icon: const Icon(Icons.photo_library_outlined,
                        color: Colors.white, size: 32),
                  ),
                  GestureDetector(
                    onTap: () async => _useImage(await _camera?.takePicture()),
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 5),
                      ),
                    ),
                  ),
                  // 对齐安卓 flash_switch_button：拍照键右侧三态闪光灯。
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
        ),
      ]),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _camera?.dispose();
    super.dispose();
  }
}

class _ResultSheet extends StatelessWidget {
  final RecognitionType type;
  final Map<String, dynamic> data;
  const _ResultSheet({required this.type, required this.data});

  @override
  Widget build(BuildContext context) {
    final content = _resultText();
    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, 24 + MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(type.title,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SelectableText(content.isEmpty ? '未识别到有效信息' : content),
            // 对齐安卓 DiscernTipsDialog：文字识别结果底部提供"一键复制"。
            if (type == RecognitionType.text && content.isNotEmpty) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: Material(
                  color: const Color(0x811296DB),
                  child: InkWell(
                    onTap: () => _copyResult(context, content),
                    child: const Center(
                      child: Text(
                        '一键复制',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 对齐安卓 copy_tv：写入剪贴板并提示"复制成功"。
  Future<void> _copyResult(BuildContext context, String content) async {
    await Clipboard.setData(ClipboardData(text: content));
    if (!context.mounted) return;
    // 结果面板是 modal route，SnackBar 会被盖住，用全局 Overlay 模拟 Toast。
    final overlay = Overlay.of(context, rootOverlay: true);
    late final OverlayEntry toast;
    toast = OverlayEntry(
      builder: (_) => Positioned(
        bottom: 140,
        left: 48,
        right: 48,
        child: Center(
          child: Material(
            color: const Color(0xD9000000),
            borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Text(
                '复制成功',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ),
      ),
    );
    overlay.insert(toast);
    Future.delayed(const Duration(seconds: 2), toast.remove);
  }

  String _resultText() {
    if (type == RecognitionType.text) {
      return (data['words_result'] as List? ?? const [])
          .map((item) => item['words'])
          .join('\n');
    }
    if (type == RecognitionType.bankCard) {
      final result = data['result'] as Map? ?? const {};
      return '银行名称：${result['bank_name'] ?? '未知'}\n'
          '银行卡号：${result['bank_card_number'] ?? '未知'}\n'
          '有效期：${result['valid_date'] ?? '未知'}';
    }
    return (data['result'] as List? ?? const [])
        .map((item) => '${item['name'] ?? ''}  ${item['score'] ?? ''}')
        .join('\n');
  }
}
