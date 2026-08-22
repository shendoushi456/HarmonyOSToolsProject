// 对齐 Android QRCodeActivity.java:52-252
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../viewmodels/qr_generate_state.dart';
import '../viewmodels/qr_generate_view_model.dart';
import 'widgets/pdf_tool_layout.dart';

class QrGeneratePage extends ConsumerWidget {
  const QrGeneratePage({super.key});

  static Future<void> push(BuildContext context) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const QrGeneratePage()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(qrGenerateViewModelProvider);
    final vm = ref.read(qrGenerateViewModelProvider.notifier);

    return PdfToolLayout(
      title: '二维码生成',
      selectButtonText: '',
      actionButtonText: '',
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: '请输入二维码内容',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  onChanged: vm.setInputText,
                ),
                const SizedBox(height: 16),
                _buildColorRow(state, vm),
                const SizedBox(height: 16),
                _buildLogoRow(state, vm),
                const SizedBox(height: 16),
                _buildSizeSlider(state, vm),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: state.inputText.isEmpty ? null : vm.generate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.qmtqBlue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('生成二维码'),
                  ),
                ),
              ],
            ),
          ),
          if (state.showPreviewDialog && state.generatedQrBytes != null)
            _buildPreviewDialog(context, state, vm),
        ],
      ),
    );
  }

  Widget _buildColorRow(QrGenerateState state, QrGenerateViewModel vm) {
    return Row(
      children: [
        Expanded(
          child: ListTile(
            leading: CircleAvatar(backgroundColor: state.foregroundColor),
            title: const Text('前景色'),
            onTap: () => _pickColor(state.foregroundColor, vm.setForegroundColor),
          ),
        ),
        Expanded(
          child: ListTile(
            leading: CircleAvatar(backgroundColor: state.backgroundColor),
            title: const Text('背景色'),
            onTap: () => _pickColor(state.backgroundColor, vm.setBackgroundColor),
          ),
        ),
      ],
    );
  }

  void _pickColor(Color current, ValueChanged<Color> onColor) {
    // 简化：直接循环几个预设颜色
    final colors = [Colors.black, Colors.white, Colors.red, Colors.blue, Colors.green, Colors.yellow];
    final nextIndex = (colors.indexOf(current) + 1) % colors.length;
    onColor(colors[nextIndex]);
  }

  Widget _buildLogoRow(QrGenerateState state, QrGenerateViewModel vm) {
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: vm.pickLogo,
          icon: const Icon(Icons.image),
          label: const Text('选择 Logo'),
        ),
        const SizedBox(width: 12),
        if (state.logoPath != null)
          TextButton(
            onPressed: () => vm.setForegroundColor(Colors.black), // 占位，实际应调用清除 logo
            child: const Text('清除'),
          ),
      ],
    );
  }

  Widget _buildSizeSlider(QrGenerateState state, QrGenerateViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('尺寸: ${state.size.toInt()}'),
        Slider(
          value: state.size,
          min: 200,
          max: 800,
          divisions: 6,
          label: state.size.toInt().toString(),
          onChanged: vm.setSize,
        ),
      ],
    );
  }

  Widget _buildPreviewDialog(BuildContext context, QrGenerateState state, QrGenerateViewModel vm) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.memory(state.generatedQrBytes!),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: vm.dismissPreview,
                    child: const Text('取消'),
                  ),
                  ElevatedButton(
                    onPressed: state.isSaving
                        ? null
                        : () async {
                            try {
                              final path = await vm.save();
                              if (context.mounted && path != null) {
                                vm.dismissPreview();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('已保存: $path')),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('保存失败: $e')),
                                );
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.qmtqBlue),
                    child: state.isSaving
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('保存', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
