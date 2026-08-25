import 'dart:io';

import 'package:flutter/material.dart';

import '../services/document_image_service.dart';

/// 可操作的裁剪页：以缩放和位置控制裁剪框，并将结果写入临时 PNG。
class DocumentCropPage extends StatefulWidget {
  const DocumentCropPage({super.key, required this.file});
  final File file;

  @override
  State<DocumentCropPage> createState() => _DocumentCropPageState();
}

class _DocumentCropPageState extends State<DocumentCropPage> {
  double _scale = .82;
  double _horizontal = .5;
  double _vertical = .5;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final widthRatio = _scale;
    final heightRatio = _scale;
    final left = (1 - widthRatio) * _horizontal;
    final top = (1 - heightRatio) * _vertical;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: const Text('图片裁剪')),
      body: SafeArea(
        top: false,
        child: Column(children: [
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 3 / 4,
                child: LayoutBuilder(builder: (context, box) {
                  return Stack(fit: StackFit.expand, children: [
                    Image.file(widget.file, fit: BoxFit.contain),
                    Positioned(
                      left: box.maxWidth * left,
                      top: box.maxHeight * top,
                      width: box.maxWidth * widthRatio,
                      height: box.maxHeight * heightRatio,
                      child: IgnorePointer(
                          child: DecoratedBox(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.white, width: 2)))),
                    ),
                  ]);
                }),
              ),
            ),
          ),
          Container(
            color: const Color(0xFF202020),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(children: [
              _Slider(
                  label: '裁剪范围',
                  value: _scale,
                  min: .35,
                  max: 1,
                  onChanged: (value) => setState(() => _scale = value)),
              _Slider(
                  label: '左右位置',
                  value: _horizontal,
                  min: 0,
                  max: 1,
                  onChanged: (value) => setState(() => _horizontal = value)),
              _Slider(
                  label: '上下位置',
                  value: _vertical,
                  min: 0,
                  max: 1,
                  onChanged: (value) => setState(() => _vertical = value)),
              const SizedBox(height: 8),
              SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                      onPressed: _saving
                          ? null
                          : () => _crop(left, top, widthRatio, heightRatio),
                      child: Text(_saving ? '处理中...' : '确认裁剪'))),
            ]),
          ),
        ]),
      ),
    );
  }

  Future<void> _crop(
      double left, double top, double width, double height) async {
    setState(() => _saving = true);
    try {
      final file = await DocumentImageService().crop(widget.file,
          leftRatio: left,
          topRatio: top,
          widthRatio: width,
          heightRatio: height);
      if (mounted) Navigator.pop(context, file);
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('裁剪失败，请重试')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _Slider extends StatelessWidget {
  const _Slider(
      {required this.label,
      required this.value,
      required this.min,
      required this.max,
      required this.onChanged});
  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      SizedBox(
          width: 72,
          child: Text(label, style: const TextStyle(color: Colors.white))),
      Expanded(
          child:
              Slider(value: value, min: min, max: max, onChanged: onChanged)),
    ]);
  }
}
