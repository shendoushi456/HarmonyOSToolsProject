// 对齐 Android PdfCompressActivity.kt:61-352 / PdfCompressor.kt:28-149
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/pdf_compress_state.dart';
import '../viewmodels/pdf_compress_view_model.dart';
import 'widgets/pdf_tool_layout.dart';
import 'widgets/pdf_type_badge.dart';
import 'widgets/selected_pdf_path.dart';

class PdfCompressPage extends ConsumerWidget {
  const PdfCompressPage({super.key});

  static Future<void> push(BuildContext context) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PdfCompressPage()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pdfCompressViewModelProvider);
    final vm = ref.read(pdfCompressViewModelProvider.notifier);

    return PdfToolLayout(
      title: '压缩PDF',
      selectButtonText: '选择 PDF',
      actionButtonText: state.isProcessing ? '处理中…' : '压缩 PDF',
      onSelect: vm.pickPdf,
      onAction: state.isProcessing || state.selectedPdfPath == null ? null : vm.compress,
      child: _buildBody(context, state, vm),
    );
  }

  Widget _buildBody(BuildContext context, PdfCompressState state, PdfCompressViewModel vm) {
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
                PdfTypeBadge(text: 'PDF\nZIP'),
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
        if (state.sourceSize != null)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              '原文件大小：${_formatSize(state.sourceSize!)}',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        if (state.outputSize != null)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              '压缩后大小：${_formatSize(state.outputSize!)}',
              style: const TextStyle(color: Colors.green),
            ),
          ),
        if (state.outputPath != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '已保存到：${state.outputPath}',
              style: const TextStyle(color: Colors.green, fontSize: 12),
            ),
          ),
        const Spacer(),
      ],
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}
