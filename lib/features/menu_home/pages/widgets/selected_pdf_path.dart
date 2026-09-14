import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

/// 显示已选 PDF 路径/空态
class SelectedPdfPath extends StatelessWidget {
  final String? pdfName;
  final String? pdfPath;

  const SelectedPdfPath({super.key, this.pdfName, this.pdfPath});

  @override
  Widget build(BuildContext context) {
    if (pdfName == null || pdfName!.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          '尚未选择 PDF',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Icon(Icons.picture_as_pdf, size: 48, color: AppColors.qmtqBlue),
          const SizedBox(height: 8),
          Text(
            pdfName!,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (pdfPath != null)
            Text(
              pdfPath!,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }
}
