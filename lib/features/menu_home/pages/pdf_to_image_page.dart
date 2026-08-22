// 对齐 Android PdfToImageActivity.kt:48-345 / PdfToImageProcessor.kt:17-96
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/pdf_to_image_state.dart';
import '../viewmodels/pdf_to_image_view_model.dart';
import 'widgets/pdf_password_dialog.dart';
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
      onAction: state.isProcessing || state.selectedPdfPath == null ? null : vm.convert,
      child: Stack(
        children: [
          _buildBody(context, state, vm),
          if (state.showPasswordDialog)
            PdfPasswordDialog(
              errorText: state.passwordError,
              onPasswordChanged: vm.setPassword,
              onConfirm: vm.confirmPasswordAndConvert,
              onCancel: vm.dismissPasswordDialog,
            ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, PdfToImageState state, PdfToImageViewModel vm) {
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
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: state.generatedImagePaths.length,
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(state.generatedImagePaths[index]),
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}
