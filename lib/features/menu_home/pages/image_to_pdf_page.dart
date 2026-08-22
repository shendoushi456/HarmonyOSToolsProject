// 对齐 Android ImageToPdfActivity.kt:75-417 / ImageToPdfProcessor.kt:20-103
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/image_to_pdf_state.dart';
import '../viewmodels/image_to_pdf_view_model.dart';
import 'widgets/pdf_tool_layout.dart';
import 'widgets/pdf_type_badge.dart';
import 'widgets/selected_image_thumbnail.dart';

class ImageToPdfPage extends ConsumerWidget {
  const ImageToPdfPage({super.key});

  static Future<void> push(BuildContext context) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ImageToPdfPage()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(imageToPdfViewModelProvider);
    final vm = ref.read(imageToPdfViewModelProvider.notifier);

    return PdfToolLayout(
      title: '图片转PDF',
      selectButtonText: '添加图片',
      actionButtonText: state.isProcessing ? '处理中…' : '转换 PDF',
      onSelect: vm.pickImages,
      onAction: state.isProcessing ? null : vm.convert,
      child: _buildBody(context, state, vm),
    );
  }

  Widget _buildBody(BuildContext context, ImageToPdfState state, ImageToPdfViewModel vm) {
    if (state.selectedImagePaths.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const PdfTypeBadge(text: 'IMG\n→ PDF'),
            const SizedBox(height: 16),
            Text(
              state.errorMessage ?? '请先选择图片（最多30张）',
              style: TextStyle(
                color: state.errorMessage != null ? Colors.red : Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (state.errorMessage != null)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              state.errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        if (state.outputPath != null)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              '已保存：${state.outputPath}',
              style: const TextStyle(color: Colors.green),
            ),
          ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: state.selectedImagePaths.length,
              itemBuilder: (context, index) {
                return SelectedImageThumbnail(
                  path: state.selectedImagePaths[index],
                  onRemove: () => vm.removeImage(index),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
