import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../life_tools/pages/widgets/tool_top_bar.dart';
import '../../scan_menu/services/document_export_service.dart';
import '../viewmodels/image_tool_view_model.dart';

/// 对齐 Android PicturePixelActivity：选图、像素块大小、预览与保存。
class PixelImagePage extends ConsumerStatefulWidget {
  const PixelImagePage({super.key});

  static Future<void> push(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PixelImagePage()),
      );

  @override
  ConsumerState<PixelImagePage> createState() => _PixelImagePageState();
}

class _PixelImagePageState extends ConsumerState<PixelImagePage> {
  double _blockSize = 20;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pixelImageToolViewModelProvider);
    final vm = ref.read(pixelImageToolViewModelProvider.notifier);
    return Scaffold(
      appBar: const ToolTopBar(title: '图片像素化'),
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
                        : const Center(
                            child: Text('请先选择图片',
                                style: TextStyle(color: Color(0xFF888888)))),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
          color: Colors.white,
          child: Column(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFD8D8D8)),
                  borderRadius: BorderRadius.circular(5)),
              child: Row(children: [
                const Text('像素块大小', style: TextStyle(fontSize: 16)),
                Expanded(
                    child: Slider(
                        value: _blockSize,
                        min: 12,
                        max: 40,
                        divisions: 28,
                        label: _blockSize.round().toString(),
                        onChanged: (value) =>
                            setState(() => _blockSize = value))),
              ]),
            ),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                  child: FilledButton(
                      onPressed: _pickImage,
                      style: _yellowButton,
                      child: const Text('选择图片'))),
              const SizedBox(width: 12),
              Expanded(
                  child: FilledButton(
                      onPressed: state.hasImage && !state.isProcessing
                          ? () => vm.convert(_blockSize.round())
                          : null,
                      style: _yellowButton,
                      child: const Text('生成像素图'))),
            ]),
            if (state.hasResult) ...[
              const SizedBox(height: 8),
              SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.download_outlined),
                      label: const Text('保存图片'))),
            ],
            if (state.errorMessage != null)
              Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(state.errorMessage!,
                      style: const TextStyle(color: Colors.red))),
          ]),
        ),
      ]),
    );
  }

  ButtonStyle get _yellowButton => FilledButton.styleFrom(
      backgroundColor: const Color(0xFFF6C766), foregroundColor: Colors.white);

  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      await ref
          .read(pixelImageToolViewModelProvider.notifier)
          .select(File(image.path));
    }
  }

  Future<void> _save() async {
    final bytes = ref.read(pixelImageToolViewModelProvider).resultBytes;
    if (bytes == null || bytes.isEmpty) return;
    try {
      await DocumentExportService().exportBytesToGallery(
        bytes,
        name: '像素图-${DateTime.now().millisecondsSinceEpoch}',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已保存到系统相册')),
        );
      }
    } on GalleryExportException catch (error) {
      if (mounted && !error.isCanceled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败：${error.message}')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败：$error')),
        );
      }
    }
  }
}
