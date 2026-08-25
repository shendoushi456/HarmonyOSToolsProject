import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../life_tools/pages/widgets/tool_top_bar.dart';
import '../viewmodels/image_tool_view_model.dart';

/// 对齐 Android ToolsWaterMarkActivity：文字、密度、大小、角度、透明度和保存。
class WatermarkImagePage extends ConsumerStatefulWidget {
  const WatermarkImagePage({super.key});

  static Future<void> push(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const WatermarkImagePage()),
      );

  @override
  ConsumerState<WatermarkImagePage> createState() => _WatermarkImagePageState();
}

class _WatermarkImagePageState extends ConsumerState<WatermarkImagePage> {
  final _textController = TextEditingController();
  double _fontSize = 20;
  double _angle = 45;
  double _alpha = 150;
  int _color = 0xFFFFFFFF;
  int _spacing = 36;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(watermarkImageToolViewModelProvider);
    final vm = ref.read(watermarkImageToolViewModelProvider.notifier);
    return Scaffold(
      appBar: ToolTopBar(
        title: '水印魔法',
        actions: state.hasResult
            ? [
                IconButton(
                    tooltip: '保存图片',
                    icon: const Icon(Icons.download_outlined),
                    onPressed: () => _save(vm))
              ]
            : null,
      ),
      body: Column(children: [
        Expanded(
          child: Container(
            width: double.infinity,
            color: const Color(0xFFF4F5F6),
            child: state.isProcessing
                ? const Center(child: CircularProgressIndicator())
                : state.hasResult
                    ? InteractiveViewer(
                        child: Image.memory(state.resultBytes!,
                            fit: BoxFit.contain))
                    : state.hasImage
                        ? InteractiveViewer(
                            child: Image.file(state.sourceFile!,
                                fit: BoxFit.contain))
                        : Center(
                            child: FilledButton(
                                onPressed: _pickImage,
                                child: const Text('选择图片'))),
          ),
        ),
        Container(
          color: Colors.white,
          constraints: const BoxConstraints(maxHeight: 390),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(children: [
              TextField(
                  controller: _textController,
                  maxLength: 60,
                  decoration: const InputDecoration(
                      labelText: '请输入水印内容',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.text_fields))),
              const SizedBox(height: 6),
              _settingsRow(
                '水印颜色',
                Wrap(
                  spacing: 8,
                  children: [
                    0xFFFFFFFF,
                    0xFF000000,
                    0xFFF44336,
                    0xFF2196F3,
                    0xFF4CAF50,
                  ].map(_colorChoice).toList(),
                ),
              ),
              _slider('水印大小', _fontSize, 4, 40,
                  (v) => setState(() => _fontSize = v),
                  valueLabel: '${_fontSize.round()}'),
              _slider('水印角度', _angle, 0, 360, (v) => setState(() => _angle = v),
                  valueLabel: '${_angle.round()}°'),
              _slider(
                  '文字透明度', _alpha, 80, 255, (v) => setState(() => _alpha = v),
                  valueLabel: '${_alpha.round()}'),
              _slider('水印间距', _spacing.toDouble(), 12, 100,
                  (v) => setState(() => _spacing = v.round()),
                  valueLabel: '$_spacing'),
              const SizedBox(height: 4),
              Row(children: [
                Expanded(
                    child: OutlinedButton(
                        onPressed: _pickImage,
                        child: Text(state.hasImage ? '重新选择' : '选择图片'))),
                const SizedBox(width: 12),
                Expanded(
                    child: FilledButton(
                        onPressed: state.hasImage && !state.isProcessing
                            ? () => _render(vm)
                            : null,
                        child: const Text('生成水印'))),
              ]),
              if (state.errorMessage != null)
                Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(state.errorMessage!,
                        style: const TextStyle(color: Colors.red))),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _colorChoice(int value) {
    return InkWell(
      onTap: () => setState(() => _color = value),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Color(value),
          shape: BoxShape.circle,
          border: Border.all(
            color: _color == value
                ? const Color(0xFFF6C766)
                : const Color(0xFFBBBBBB),
            width: 3,
          ),
        ),
      ),
    );
  }

  Widget _settingsRow(String label, Widget control) => Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFD8D8D8)),
            borderRadius: BorderRadius.circular(5)),
        child: Row(children: [
          SizedBox(width: 84, child: Text(label)),
          Expanded(child: control)
        ]),
      );

  Widget _slider(String title, double value, double min, double max,
          ValueChanged<double> onChanged, {required String valueLabel}) =>
      _settingsRow(
          title,
          Slider(
              value: value,
              min: min,
              max: max,
              label: valueLabel,
              onChanged: onChanged));

  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      await ref
          .read(watermarkImageToolViewModelProvider.notifier)
          .select(File(image.path));
    }
  }

  Future<void> _render(WatermarkImageToolViewModel vm) async {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('请输入水印内容')));
      return;
    }
    await vm.render(
        text: _textController.text.trim(),
        color: _color,
        alpha: _alpha.round(),
        fontSize: _fontSize,
        angle: _angle * 3.14159265359 / 180,
        spacing: _spacing);
  }

  Future<void> _save(WatermarkImageToolViewModel vm) async {
    final file = await vm.save();
    if (mounted && file != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('已保存到 ${file.path}')));
    }
  }
}
