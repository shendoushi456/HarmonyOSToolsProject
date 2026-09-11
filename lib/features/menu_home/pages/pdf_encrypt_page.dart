// 对齐 Android AddPasswordToPdfActivity.kt:64-321 / PdfSecurityProcessor.kt:20-58
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/pdf_encrypt_state.dart';
import '../viewmodels/pdf_encrypt_view_model.dart';
import 'widgets/pdf_tool_layout.dart';
import 'widgets/pdf_type_badge.dart';
import 'widgets/selected_pdf_path.dart';

class PdfEncryptPage extends ConsumerWidget {
  const PdfEncryptPage({super.key});

  static Future<void> push(BuildContext context) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PdfEncryptPage()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pdfEncryptViewModelProvider);
    final vm = ref.read(pdfEncryptViewModelProvider.notifier);

    return PdfToolLayout(
      title: '加密PDF',
      selectButtonText: '选择 PDF',
      actionButtonText: state.isProcessing ? '处理中…' : '加密 PDF',
      onSelect: vm.pickPdf,
      onAction: state.isProcessing || state.selectedPdfPath == null || state.password.isEmpty
          ? null
          : vm.encrypt,
      child: _buildBody(context, state, vm),
    );
  }

  Widget _buildBody(BuildContext context, PdfEncryptState state, PdfEncryptViewModel vm) {
    return SingleChildScrollView(
      child: Column(
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
            const Column(
              children: [
                SizedBox(height: 40),
                PdfTypeBadge(text: 'PDF\nLOCK'),
                SizedBox(height: 16),
                Text('请先选择 PDF 文件', style: TextStyle(color: Colors.grey)),
              ],
            )
          else
            SelectedPdfPath(
              pdfName: state.selectedPdfName,
              pdfPath: state.selectedPdfPath,
            ),
          if (state.selectedPdfPath != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: TextField(
                obscureText: !state.passwordVisible,
                decoration: InputDecoration(
                  labelText: '设置打开密码',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(state.passwordVisible ? Icons.visibility_off : Icons.visibility),
                    onPressed: vm.togglePasswordVisibility,
                  ),
                ),
                onChanged: vm.setPassword,
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
        ],
      ),
    );
  }
}
