// 毛玻璃页 - 对齐 Android ToolsPictureBlurActivity.java + activity_picture_blur.xml
// 顶栏"毛玻璃图片生成" + 空状态/模糊后图 + Slider(1-25) + 选择图片/保存按钮
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../viewmodels/blur_view_model.dart';
import '../widgets/tool_top_bar.dart';

class BlurPage extends ConsumerWidget {
  const BlurPage({super.key});

  static Future<void> push(BuildContext context) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BlurPage()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(blurViewModelProvider);
    final vm = ref.read(blurViewModelProvider.notifier);

    return Scaffold(
      appBar: const ToolTopBar(title: '毛玻璃图片生成'),
      body: Column(
        children: [
          Expanded(
            child: state.blurredBytes == null
                ? const Center(child: Text('请先选择图片', style: TextStyle(color: Colors.grey)))
                : state.isProcessing
                    ? const Center(child: CircularProgressIndicator())
                    : Image.memory(state.blurredBytes!),
          ),
          // 模糊程度滑块(对齐 seekbar1, min 1 max 25 默认 12)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text('模糊程度'),
                Expanded(
                  child: Slider(
                    value: state.radius.toDouble(),
                    min: 1,
                    max: 25,
                    divisions: 24,
                    label: state.radius.toString(),
                    onChanged: state.originalBytes == null
                        ? null
                        : (v) => vm.setRadius(v.round()),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _pickImage(vm),
                    child: const Text('选择图片'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: state.blurredBytes == null ? null : () => _savePng(context, state.blurredBytes!),
                    child: const Text('保存图片'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 选图 - 对齐 ToolsPictureBlurActivity.java:167-194
  Future<void> _pickImage(BlurViewModel vm) async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.gallery);
    if (xFile == null) return;
    final bytes = await xFile.readAsBytes();
    await vm.pickImage(bytes);
  }

  /// 保存 - 对齐 ToolsPictureBlurActivity.java:91-104
  /// 写入应用文档目录(对齐 /噬/毛玻璃图片/)
  Future<void> _savePng(BuildContext context, Uint8List bytes) async {
    final now = DateTime.now();
    final fileName = 'Image-${now.hour.toString().padLeft(2, '0')}-${now.minute.toString().padLeft(2, '0')}-${now.second.toString().padLeft(2, '0')}.png';
    try {
      final dir = await getApplicationDocumentsDirectory();
      final saveDir = Directory('${dir.path}/毛玻璃图片');
      if (!await saveDir.exists()) {
        await saveDir.create(recursive: true);
      }
      final file = File('${saveDir.path}/$fileName');
      await file.writeAsBytes(bytes);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已保存: ${file.path}')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e')),
        );
      }
    }
  }
}
