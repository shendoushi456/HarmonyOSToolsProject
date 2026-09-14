import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
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
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _openCamera();
  }

  Future<void> _openCamera() async {
    try {
      final cameras = await availableCameras();
      final back = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller =
          CameraController(back, ResolutionPreset.high, enableAudio: false);
      await controller.initialize();
      if (mounted) setState(() => _camera = controller);
    } catch (error) {
      if (mounted) setState(() => _error = '相机不可用：$error');
    }
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
                  const SizedBox(width: 40),
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
          ],
        ),
      ),
    );
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
