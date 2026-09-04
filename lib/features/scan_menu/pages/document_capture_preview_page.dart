import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../services/document_image_service.dart';
import 'document_camera_page.dart';
import 'document_crop_page.dart';
import 'document_save_page.dart';

/// 对齐 DisplayPicActivity：预览、裁剪、重拍、水印和下一步。
class DocumentCapturePreviewPage extends StatefulWidget {
  const DocumentCapturePreviewPage({super.key, required this.file});
  final File file;

  @override
  State<DocumentCapturePreviewPage> createState() =>
      _DocumentCapturePreviewPageState();
}

class _DocumentCapturePreviewPageState
    extends State<DocumentCapturePreviewPage> {
  late File _file;
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    _file = widget.file;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: const Text('拍照存档')),
      body: Column(children: [
        Expanded(child: Center(child: Image.file(_file, fit: BoxFit.contain))),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 22),
          child: Row(children: [
            _ActionButton(
                asset: AppAssets.scanCrop,
                label: '裁剪',
                onTap: _processing ? null : _crop),
            _ActionButton(
                asset: AppAssets.scanRetake,
                label: '重拍',
                onTap: _processing ? null : _retake),
            _ActionButton(
                asset: AppAssets.scanWatermark,
                label: '水印',
                onTap: _processing ? null : _watermark),
            const Spacer(),
            FilledButton(
                onPressed: _processing ? null : _next,
                child: Text(_processing ? '处理中...' : '下一步')),
          ]),
        ),
      ]),
    );
  }

  Future<void> _crop() async {
    final result = await Navigator.push<File>(context,
        MaterialPageRoute(builder: (_) => DocumentCropPage(file: _file)));
    if (result != null && mounted) setState(() => _file = result);
  }

  Future<void> _retake() async {
    final result = await DocumentCameraPage.capture(context);
    if (result != null && mounted) setState(() => _file = result);
  }

  Future<void> _watermark() async {
    final text = await showDialog<String>(
        context: context, builder: (_) => const _WatermarkDialog());
    if (text == null || text.trim().isEmpty) return;
    if (!mounted) return;
    setState(() => _processing = true);
    try {
      final result =
          await DocumentImageService().addWatermark(_file, text.trim());
      if (mounted) setState(() => _file = result);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('添加水印失败')));
      }
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  Future<void> _next() async {
    final saved = await Navigator.push<bool>(context,
        MaterialPageRoute(builder: (_) => DocumentSavePage(file: _file)));
    if (saved == true && mounted) Navigator.pop(context, true);
  }
}

/// 水印输入框自行管理控制器生命周期，避免弹框关闭时父页面提前释放
/// TextEditingController，导致鸿蒙 Flutter 引擎在 InheritedElement 销毁阶段
/// 触发 `_dependents.isEmpty` 断言。
class _WatermarkDialog extends StatefulWidget {
  const _WatermarkDialog();

  @override
  State<_WatermarkDialog> createState() => _WatermarkDialogState();
}

class _WatermarkDialogState extends State<_WatermarkDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '默认水印');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('设置水印文字'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(hintText: '输入要添加的水印'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('添加'),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton(
      {required this.asset, required this.label, required this.onTap});
  final String asset;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onTap,
        child: SizedBox(
            width: 58,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Image.asset(asset, width: 28, height: 28),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(fontSize: 12))
            ])));
  }
}
