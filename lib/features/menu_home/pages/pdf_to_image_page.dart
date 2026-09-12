// 对齐 Android PdfToImageActivity.kt:48-345 / PdfToImageProcessor.kt:17-96
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../viewmodels/pdf_to_image_state.dart';
import '../viewmodels/pdf_to_image_view_model.dart';
import 'widgets/pdf_tool_layout.dart';
import 'widgets/pdf_type_badge.dart';
import 'widgets/selected_pdf_path.dart';

class PdfToImagePage extends ConsumerWidget {
  const PdfToImagePage({super.key});

  static Future<void> push(BuildContext context) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PdfToImagePage()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pdfToImageViewModelProvider);
    final vm = ref.read(pdfToImageViewModelProvider.notifier);

    return PdfToolLayout(
      title: 'PDF转图片',
      selectButtonText: '选择 PDF',
      actionButtonText: state.isProcessing ? '处理中…' : '转换为图片',
      onSelect: vm.pickPdf,
      onAction: state.isProcessing || state.selectedPdfPath == null
          ? null
          : vm.convert,
      actions: [
        if (state.generatedImagePaths.isNotEmpty)
          IconButton(
            icon: state.isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_alt),
            color: AppColors.toolsTitleText,
            tooltip: '保存到图库',
            onPressed: state.isSaving || state.isProcessing
                ? null
                : () => _saveAll(context, vm),
          ),
      ],
      child: _buildBody(context, state, vm),
    );
  }

  /// 保存全部生成图片到系统相册，SnackBar 反馈结果。
  Future<void> _saveAll(
      BuildContext context, PdfToImageViewModel vm) async {
    final count = await vm.saveAllToGallery();
    if (!context.mounted) return;
    if (count > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已保存 $count 张图片到系统相册')),
      );
    }
  }

  Widget _buildBody(
      BuildContext context, PdfToImageState state, PdfToImageViewModel vm) {
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
        if (state.selectedPdfPath == null)
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PdfTypeBadge(text: 'PDF\n→ IMG'),
                SizedBox(height: 16),
                Text('请先选择 PDF 文件', style: TextStyle(color: Colors.grey)),
              ],
            ),
          )
        else
          SelectedPdfPath(
            pdfName: state.selectedPdfName,
            pdfPath: state.selectedPdfPath,
          ),
        if (state.generatedImagePaths.isNotEmpty)
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: state.generatedImagePaths.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(state.generatedImagePaths[index]),
                      width: double.infinity,
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
